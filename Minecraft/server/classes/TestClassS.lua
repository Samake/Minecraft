--[[
	Name: Minecraft
	Filename: TestClassS.lua
	Authors: Sam@ke
--]]


TestClassS = {}

function TestClassS:constructor(parent)
	mainOutput("TestClassS was loaded.")
	
	self.mainClass = parent
	self.blockManager = self.mainClass.blockManager
	
	self.x = -3000
	self.y = -3000
	self.z = 4
	
	self.terrainOwner = "system"
	self.terrainTypes = {"stoneBlock", "dirtBlock"}
	
	self.terrainSize = 12
	self.currentLayer = 0
	self.maxLayers = 8
	
	self.m_CreateLayer = bind(self.createLayer, self)
	addEvent("CreateLayer", true)
	addEventHandler("CreateLayer", root, self.m_CreateLayer)
end


function TestClassS:createLayer()
	if (self.blockManager) then
		if (self.currentLayer < self.maxLayers) then
			self.z = self.z + 1
			self:startTerrainCreation()
			self.currentLayer = self.currentLayer + 1
		end
	end
end


function TestClassS:startTerrainCreation()
	self.startX = self.x - self.terrainSize / 2
	self.startY = self.y - self.terrainSize / 2
	
	for i = 0, self.terrainSize - 1, 1 do
		for j = 0, self.terrainSize - 1, 1 do
			local x = self.startX + 1 * i
			local y = self.startY + 1 * j
			local z = self.z + 0.5
			local randomType = math.random(1, #self.terrainTypes)
			local randomIsBlock = math.random(10, 50)
			
			if (randomIsBlock < 26 - self.currentLayer * 3) then
				self.blockManager:createBlock(self.terrainOwner, self.terrainTypes[randomType], x, y, z)
			end
		end
	end
end

function TestClassS:destructor()

	removeEventHandler("CreateLayer", root, self.m_CreateLayer)

	mainOutput("TestClassS was deleted.")
end