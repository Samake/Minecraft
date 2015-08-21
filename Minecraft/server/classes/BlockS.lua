--[[
	Name: Minecraft
	Filename: BlockS.lua
	Authors: Sam@ke
--]]


BlockS = {}

function BlockS:constructor(parent, id, modelID, type, life, owner, x, y, z)
	mainOutput("BlockS " .. type .. " with id " .. id .. " was loaded.")
	
	self.blockManager = parent
	self.id = id
	self.newID = nil
	self.modelID = modelID
	self.type = type
	self.life = life
	self.owner = owner
	self.x = x
	self.y = y
	self.z = z - 0.5
	self.rx = 0
	self.ry = 0
	self.rz = 0
	self.moveDistance = 0.1
	
	--dirt block parameters
	self.isGrowing = "false"
	self.isSeeded = math.random(1, 2) -- 1 lets growing grass
	self.hasGrass = "false"
	self.m_GrowBlock = bind(self.growBlock, self)
	self.m_GrowGrass = bind(self.growGrass, self)
	self.growTime = math.random(900, 9000)
	self.grassSeedTime = math.random(300, 5000)
	self.seedFactor = 0
	self.seedValue = math.random(10, 50) / 100000
	
	if (self.type == "grassPlant") then
		self.rx = 90
		self.z = z - 1.0
	end
	
	self.hasBlockBottom = "true"
	self.hasBlockTop = "false"
	
	self:init()
end


function BlockS:init()
	if (not self.blockModel) then
		self.blockModel = createObject(self.modelID, self.x, self.y, self.z, self.rx, self.ry, self.rz, false)
	end
	
	if (not self.blockModelLOD) then
		self.blockModelLOD = createObject(self.modelID, self.x, self.y, self.z, self.rx, self.ry, self.rz, true)
	end
	
	if (self.blockModel) and (self.blockModelLOD) then
		self.blockModelLOD:attach(self.blockModel)
		
		self.blockModel:setDoubleSided(true)
		self.blockModelLOD:setDoubleSided(true)
		
		self.blockModel:setData("OBJECTTYPE", "MCBLOCK", true)
		self.blockModel:setData("ID", self.id, true)
	end
end


function BlockS:update()
	self:checkIfBlockBottom()
	
	if (self.type == "grassPlant") then
		if (self.seedFactor < 0.9) then
			self.seedFactor = self.seedFactor + self.seedValue
			
			self.newZ = self.z + self.seedFactor
			
			if (self.blockModel) and (self.blockModelLOD) then
				self.blockModel:setPosition(self.x, self.y, self.newZ)
				self.blockModelLOD:setPosition(self.x, self.y, self.newZ)
			end
		end
	end
	
	if (self.hasBlockTop == "false") then
		if (self.type == "dirtBlock") or (self.type == "grassBlock") then
			setTimer(self.m_GrowBlock, self.growTime, 1)
		end
	elseif (self.hasBlockTop == "true") then
		if (self.type == "dirtBlock") or (self.type == "grassBlock") then
			if (self.hasGrass == "false") then
				self:unGrowBlock()
			end
		end
	end
	
	if (self.hasBlockBottom == "false") then
		if (self.type == "sandBlock") then
			self.z = self.z - self.moveDistance
			
			if (self.blockModel) and (self.blockModelLOD) then
				self.blockModel:setPosition(self.x, self.y, self.z)
				self.blockModelLOD:setPosition(self.x, self.y, self.z)
			end
		end
	end
end


function BlockS:growBlock()
	if (self.isGrowing == "false") then
		if (self.blockModel) and (self.blockModelLOD) then
			self.blockModel:setModel(1853)
			self.blockModelLOD:setModel(1853)
			self.isGrowing = "true"
			
			if (self.isSeeded == 1) then
				setTimer(self.m_GrowGrass, self.grassSeedTime, 1)
			end
		end
	end
end


function BlockS:unGrowBlock()
	if (self.isGrowing == "true") then
		if (self.blockModel) and (self.blockModelLOD) then
			self.blockModel:setModel(1852)
			self.blockModelLOD:setModel(1852)
			self.isGrowing = "false"
		end
	end
end


function BlockS:growGrass()
	self.blockManager:addGrassPlant("grassPlant", self.x, self.y, self.z + 1.5)
	self.hasGrass = "true"
end


function BlockS:checkIfBlockBottom()
	-- // check if block in top // --
	local topID = tostring(hash("md5", self.x .. self.y .. self.z + 1.5))
	
	if (self.blockManager.blocks[topID]) then
		self.hasBlockTop = "true"
	else
		self.hasBlockTop = "false"
	end
	
	-- // check if block in bottom // --
	local bottomID = tostring(hash("md5", self.x .. self.y .. self.z - 0.5))
	
	if (self.blockManager.blocks[bottomID]) then
		self.hasBlockBottom = "true"
	else
		self.hasBlockBottom = "false"
	end

	if (self.z <= 5) then
		self.hasBlockBottom = "true" -- hack to detect terrain plane
	end
end


function BlockS:clear()
	if (self.blockModel) then
		self.blockModel:destroy()
		self.blockModel= nil
	end
	
	if (self.blockModelLOD) then
		self.blockModelLOD:destroy()
		self.blockModelLOD= nil
	end
end


function BlockS:destructor()

	self:clear()
	
	mainOutput("BlockS " .. self.type .. " with id " .. self.id .. " was deleted.")
end