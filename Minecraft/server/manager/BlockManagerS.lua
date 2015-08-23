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
	self.blockModelIDs["doorWood"] = 1830
	
	self.blockTypeAttributes = {}
	self.blockTypeAttributes["stoneBlock"] = {life = 3000, needsUpdate = "false", color = {r = 90, g = 90, b = 90, a = 200}}
	self.blockTypeAttributes["dirtBlock"] = {life = 1000, needsUpdate = "true", color = {r = 80, g = 35, b = 5, a = 200}}
	self.blockTypeAttributes["grassBlock"] = {life = 1000, needsUpdate = "true", color = {r = 35, g = 128, b = 35, a = 200}}
	self.blockTypeAttributes["grassPlant"] = {life = 100, needsUpdate = "true", color = {r = 35, g = 128, b = 35, a = 200}}
	self.blockTypeAttributes["sandBlock"] = {life = 900, needsUpdate = "true", color = {r = 160, g = 140, b = 25, a = 200}}
	self.blockTypeAttributes["glassWhiteBlock"] = {life = 250, needsUpdate = "false", color = {r = 100, g = 100, b = 130, a = 90}}
	self.blockTypeAttributes["doorWood"] = {life = 10000, needsUpdate = "true", color = {r = 80, g = 35, b = 5, a = 200}}
	
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


function BlockManagerS:createBlock(player, type, x, y, z, parent)
	if (player) and (type) and (x) and (y) and (z) then
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
		blockProperties.color = self.blockTypeAttributes[type].color
		blockProperties.parent = parent
		
		if (blockProperties.type == "doorWood") and (isElement(player)) then
			blockProperties.id2 = tostring(hash("md5", x .. y .. z + 1))
			
			local playerPos = player:getPosition()
			local rotZ = findRotation(playerPos.x, playerPos.y, x, y)
			rotZ = (rotZ - 90)%360
			
			if (rotZ >= 0) and (rotZ <= 44) then
				rotZ = 0
			elseif (rotZ <= 360) and (rotZ >= 315) then
				rotZ = 0
			elseif (rotZ >= 45) and (rotZ <= 134) then
				rotZ = 90
			elseif (rotZ >= 135) and (rotZ <= 224) then
				rotZ = 180
			elseif (rotZ >= 225) and (rotZ <= 314) then
				rotZ = 270
			end
			
			blockProperties.rx = 90
			blockProperties.ry = 90
			blockProperties.rz = rotZ
			
			if (not self.blocks[blockProperties.id]) and (not self.blocks[blockProperties.id2]) then
				self.blocks[blockProperties.id] = new(DoorS, self, blockProperties)
				self.blocks[blockProperties.id2] = self.blocks[blockProperties.id]
			end
		else
			if (not self.blocks[blockProperties.id]) then
				self.blocks[blockProperties.id] = new(BlockS, self, blockProperties)
			else
				if (self.blocks[blockProperties.id].type == "grassPlant") then
					self:deleteBlock(blockProperties.id)
					self.blocks[blockProperties.id] = new(BlockS, self, blockProperties)
				end
			end
			
			if (self.blocks[blockProperties.id]) then
				-- remove item count on player
			end
		end
		
		blockProperties = nil
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


function BlockManagerS:addGrassPlant(type, x, y, z, parent)
	if (type) and (x) and (y) and (z) and (parent) then
		self:createBlock("system", type, x, y, z, parent)
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