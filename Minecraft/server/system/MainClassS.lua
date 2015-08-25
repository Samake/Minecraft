--[[
	Name: Minecraft
	Filename: MainClassS.lua
	Authors: Sam@ke
--]]

local Instance = nil

MainClassS = {}


function MainClassS:constructor()
	mainOutput("SERVER // ***** Minecraft was started *****")
	mainOutput("MainClassS was loaded.")
	
	setFPSLimit(60)
	
	self:init()
end


function MainClassS:init()
	if (not self.debugClass) then
		self.debugClass = new(DebugClassS, self)
	end
	
	if (not self.terrainHandler) then
		self.terrainHandler = new(TerrainHandlerS, self)
	end
	
	if (not self.playerManager) then
		self.playerManager = new(PlayerManagerS, self)
	end
	
	if (not self.blockManager) then
		self.blockManager = new(BlockManagerS, self)
	end
	
	if (not self.testClass) then
		self.testClass = new(TestClassS, self)
	end
end


function MainClassS:clear()
	if (self.terrainHandler) then
		delete(self.terrainHandler)
		self.terrainHandler = nil
	end
	
	if (self.playerManager) then
		delete(self.playerManager)
		self.playerManager = nil
	end
	
	if (self.blockManager) then
		delete(self.blockManager)
		self.blockManager = nil
	end
	
	if (self.testClass) then
		delete(self.testClass)
		self.testClass = nil
	end
	
	if (self.debugClass) then
		delete(self.debugClass)
		self.debugClass = nil
	end
end


function MainClassS:destructor()
	self:clear()

	mainOutput("MainClassS was deleted.")
	mainOutput("SERVER // ***** Minecraft was closed *****")
end


addEventHandler("onResourceStart", resourceRoot,
function()
	Instance = new(MainClassS)
end)


addEventHandler("onResourceStop", resourceRoot,
function()
	if (Instance) then
		delete(Instance)
		Instance = nil
	end
end)