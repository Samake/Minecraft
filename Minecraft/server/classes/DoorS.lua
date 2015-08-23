--[[
	Name: Minecraft
	Filename: DoorS.lua
	Authors: Sam@ke
--]]


DoorS = {}

function DoorS:constructor(parent, blockProperties)
	
	self.blockManager = parent
	self.id = blockProperties.id
	self.modelID = blockProperties.modelID
	self.type = blockProperties.type
	self.life = blockProperties.life
	self.needsUpdate = blockProperties.needsUpdate
	self.owner = blockProperties.owner
	self.x = blockProperties.x
	self.y = blockProperties.y
	self.z = blockProperties.z - 0.5
	self.color = blockProperties.color
	self.parent = blockProperties.parent
	self.rx = blockProperties.rx
	self.ry = blockProperties.ry
	self.rz = blockProperties.rz
	
	if (self.rz == 0) then
		self.x = blockProperties.x
		self.y = blockProperties.y - 0.5
	elseif (self.rz == 90) then
		self.x = blockProperties.x + 0.5
		self.y = blockProperties.y
	elseif (self.rz == 180) then
		self.x = blockProperties.x
		self.y = blockProperties.y + 0.5
	elseif (self.rz == 270) then
		self.x = blockProperties.x - 0.5
		self.y = blockProperties.y
	end
	
	self.isDoorOpen = "false"
	self.closedRZ = self.rz
	self.openRZ = (self.rz - 90)%360
	
	self.hasBlockTop = "false"
	self.hasBlockBottom = "false"
	
	self.m_OnClientDoorAction = bind(self.onClientDoorAction, self)
	addEvent("onClientDoorAction", true)
	addEventHandler("onClientDoorAction", root, self.m_OnClientDoorAction)
	
	self:init()
	
	mainOutput("DoorS " .. self.type .. " with id " .. self.id .. " was created.")
end


function DoorS:init()
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
		
		self.blockModel:setData("OBJECTTYPE", "MCDOOR", true)
		self.blockModel:setData("ID", self.id, true)
	end
end


function DoorS:onClientDoorAction(door)
	if (door == self.blockModel) then
		if (self.isDoorOpen == "false") then
			if (self.blockModel) and (self.blockModelLOD) then
				self.rz = self.openRZ
				
				self.blockModel:setRotation(self.rx, self.ry, self.rz)
				self.blockModelLOD:setRotation(self.rx, self.ry, self.rz)
				self.isDoorOpen = "true"
			end
		elseif (self.isDoorOpen == "true") then
			if (self.blockModel) and (self.blockModelLOD) then
				self.rz = self.closedRZ
				
				self.blockModel:setRotation(self.rx, self.ry, self.rz)
				self.blockModelLOD:setRotation(self.rx, self.ry, self.rz)
				self.isDoorOpen = "false"
			end
		end
	end
end


function DoorS:update()
	if (self.needsUpdate == "true") then
		self:checkIfBlockBottom()
	
		
	end
end



function DoorS:checkIfBlockBottom()
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


function DoorS:clear()
	if (self.blockModel) then
		self.blockModel:destroy()
		self.blockModel= nil
	end
	
	if (self.blockModelLOD) then
		self.blockModelLOD:destroy()
		self.blockModelLOD= nil
	end
end


function DoorS:destructor()

	removeEventHandler("onClientDoorAction", root, self.m_OnClientDoorAction)

	self:clear()
	
	triggerClientEvent("onBlockDestroyed", root, self.x, self.y, self.z, self.color.r, self.color.g, self.color.b, self.color.a, 0.015, 10)
	
	mainOutput("DoorS " .. self.type .. " with id " .. self.id .. " was destroyed.")
end