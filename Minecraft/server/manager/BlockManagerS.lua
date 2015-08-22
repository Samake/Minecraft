--[[
	Name: Minecraft
	Filename: BlockManagerS.lua
	Authors: Sam@ke
--]]


BlockManagerS = {}

function BlockManagerS:constructor(parent)
	mainOutput("BlockManagerS was loaded.")
	
	self.mainClass = parent
	self.updateInterval = 50
		
	self.blocks = {}
	
	self.blockModelIDs = {}
	self.blockModelIDs["stoneBlock"] = 1851
	self.blockModelIDs["dirtBlock"] = 1852
	self.blockModelIDs["grassBlock"] = 1853
	self.blockModelIDs["grassPlant"] = 1854
	self.blockModelIDs["sandBlock"] = 1855
	self.blockModelIDs["glassWhiteBlock"] = 1856
	
	self.blockTypeAttributes = {}
	self.blockTypeAttributes["stoneBlock"] = {life = 3000, needsUpdate = "false"}
	self.blockTypeAttributes["dirtBlock"] = {life = 1000, needsUpdate = "true"}
	self.blockTypeAttributes["grassBlock"] = {life = 1000, needsUpdate = "true"}
	self.blockTypeAttributes["grassPlant"] = {life = 100, needsUpdate = "true"}
	self.blockTypeAttributes["sandBlock"] = {life = 900, needsUpdate = "true"}
	self.blockTypeAttributes["glassWhiteBlock"] = {life = 250, needsUpdate = "false"}
	
	self.m_Update = bind(self.update, self)
	self.updateTimer = setTimer(self.m_Update, self.updateInterval, 0)
	
	self.m_CreateBlock = bind(self.createBlock, self)
	addEvent("onBlockCreate", true)
	addEventHandler("onBlockCreate", root, self.m_CreateBlock)
	
	self.m_DeleteBlock = bind(self.deleteBlock, self)
	addEvent("onBlockDelete", true)
	addEventHandler("onBlockDelete", root, self.m_DeleteBlock)
end


function BlockManagerS:update()
	for index, blockInstance in pairs(self.blocks) do
        if (blockInstance) then
			blockInstance:update()
        end
    end
end


function BlockManagerS:createBlock(player, type, x, y, z)
	if (player) and (x) and (y) and (z) then
		local blockProperties = {}
		blockProperties.id = tostring(hash("md5", x .. y .. z))
		blockProperties.modelID = self.blockModelIDs[type]
		blockProperties.type = type
		blockProperties.life = self.blockTypeAttributes[type].life
		blockProperties.needsUpdate = self.blockTypeAttributes[type].needsUpdate
		blockProperties.owner = player
		blockProperties.x = x
		blockProperties.y = y
		blockProperties.z = z

		if (not self.blocks[blockProperties.id]) then
			self.blocks[blockProperties.id] = new(BlockS, self, blockProperties)
		end
		
		if (self.blocks[blockProperties.id]) then
			-- remove item count on player
		end
	end
end


function BlockManagerS:deleteBlock(id)
	if (id) then
		if (self.blocks[id]) then
			delete(self.blocks[id])
			self.blocks[id] = nil
		end
	end
end


function BlockManagerS:addGrassPlant(type, x, y, z)
	if (x) and (y) and (z) then
		local blockProperties = {}
		blockProperties.id = tostring(hash("md5", x .. y .. z))
		blockProperties.modelID = self.blockModelIDs[type]
		blockProperties.type = type
		blockProperties.life = self.blockTypeAttributes[type].life
		blockProperties.needsUpdate = self.blockTypeAttributes[type].needsUpdate
		blockProperties.owner = "system"
		blockProperties.x = x
		blockProperties.y = y
		blockProperties.z = z
		
		if (not self.blocks[blockProperties.id]) then
			self.blocks[blockProperties.id] = new(BlockS, self, blockProperties)
		end
	end
end


function BlockManagerS:destructor()

	removeEventHandler("onBlockCreate", root, self.m_CreateBlock)
	removeEventHandler("onBlockDelete", root, self.m_DeleteBlock)
	
	if (self.updateTimer) then
		self.updateTimer:destroy()
		self.updateTimer = nil
	end

	for index, blockInstance in pairs(self.blocks) do
        if (blockInstance) then
            delete(blockInstance)
			blockInstance = nil
        end
    end
	
	mainOutput("BlockManagerS was deleted.")
end