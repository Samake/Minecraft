--[[
	Name: Minecraft
	Filename: TerrainHandlerS.lua
	Authors: Sam@ke
--]]


TerrainHandlerS = {}

function TerrainHandlerS:constructor(parent)
	mainOutput("TerrainHandlerS was loaded.")
	
	self.mainClass = parent
	self.terrainID = 15049
	self.x = -3000
	self.y = -3000
	self.z = 5
	self.size = 1
	
	self:init()
	
end


function TerrainHandlerS:init()
	if (not self.terrain) then
		self.terrain = createObject(self.terrainID, self.x, self.y, self.z, 0, 0, 0, false)
		self.terrainLOD = createObject(self.terrainID, self.x, self.y, self.z, 0, 0, 0, true)
		
		if (self.terrain) and (self.terrainLOD) then
			self.terrainLOD:attach(self.terrain)
		else
			mainOutput("FAIL // Couldnt create terrain")
		end
	end
end


function TerrainHandlerS:clear()
	if (self.terrain) then
		self.terrain:destroy()
		self.terrain = nil
	end
	
	if (self.terrainLOD) then
		self.terrainLOD:destroy()
		self.terrainLOD = nil
	end
end


function TerrainHandlerS:destructor()

	self:clear()
	
	mainOutput("TerrainHandlerS was deleted.")
end