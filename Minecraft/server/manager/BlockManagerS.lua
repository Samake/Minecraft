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
	
	self.blockTypeAttributes = {}
	self.blockTypeAttributes["stoneBlock"] = {life = 3000}
	self.blockTypeAttributes["dirtBlock"] = {life = 1000}
	self.blockTypeAttributes["grassBlock"] = {life = 1000}
	self.blockTypeAttributes["grassPlant"] = {life = 100}
	self.blockTypeAttributes["sandBlock"] = {life = 900}
	
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
		local modelID = self.blockModelIDs[type]
		local life = self.blockTypeAttributes[type].life
		local bx, by, bz = x, y, z
		local id = tostring(hash("md5", bx .. by .. bz))
		
		if (not self.blocks[id]) then
			self.blocks[id] = new(BlockS, self, id, modelID, type, life, player, bx, by, bz)
		end
		
		if (self.blocks[id]) then
			-- remove item count on player
		end
	end
end


function BlockManagerS:deleteBlock(id)
	if (id) then
		if (self.blocks[id]) then
			delete(self.blocks[id])
			self.blocks[id] = nil
			--table.remove(self.blocks, id)
		end
	end
end


function BlockManagerS:addGrassPlant(type, x, y, z)
	if (x) and (y) and (z) then
		local modelID = self.blockModelIDs[type]
		local life = self.blockTypeAttributes[type].life
		local bx, by, bz = x, y, z
		local id = tostring(hash("md5", bx .. by .. bz))
		
		if (not self.blocks[id]) then
			self.blocks[id] = new(BlockS, self, id, modelID, type, life, "system", bx, by, bz)
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