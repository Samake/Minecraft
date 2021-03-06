--[[
	Name: Minecraft
	Filename: MainClassC.lua
	Authors: Sam@ke
--]]

local Instance = nil

MainClassC = {}

function MainClassC:constructor()
	mainOutput("MainClassC was loaded.")
	
	self.isDebug = "false"
	self.debugKey = "M"
	
	self.m_ToggleDebug = bind(self.toogleDebug, self)
	bindKey(self.debugKey, "down", self.m_ToggleDebug)
	
	self.m_Update = bind(self.update, self)
	addEventHandler("onClientRender", root, self.m_Update)
	
	self:init()
end


function MainClassC:init()
	if (not self.modelHandler) then
		self.modelHandler = new(ModelHandlerC, self)
	end
	
	if (not self.actionHandler) then
		self.actionHandler = new(ActionHandlerC, self)
	end
	
	if (not self.inventoryHandler) then
		self.inventoryHandler = new(InventoryHandlerC, self)
	end
	
	if (not self.guiManager) then
		self.guiManager = new(GUIManagerC, self)
	end
	
	if (not self.shaderManager) then
		self.shaderManager = new(ShaderManagerC, self)
	end
	
	if (not self.blockCursor) then
		self.blockCursor = new(BlockCursorC, self)
	end
	
	if (not self.blockEvents) then
		self.blockEvents = new(BlockEventsC, self)
	end
	
	if (self.isDebug == "true") then
		if (not self.debugClass) then
			self.debugClass = new(DebugClassC, self)
		end
	end
	
	if (not self.testClass) then
		self.testClass = new(TestClassC, self)
	end
end


function MainClassC:toogleDebug()
	if (self.isDebug == "false") then
		if (not self.debugClass) then
			self.debugClass = new(DebugClassC, self)
		end
		
		self.isDebug = "true"
	elseif (self.isDebug == "true") then
		if (self.debugClass) then
			delete(self.debugClass)
			self.debugClass = nil
		end
	
		self.isDebug = "false"
	end
	
	mainOutput("Debug Client enabled: " .. self.isDebug)
	triggerServerEvent("enableDebugStats", root, self.isDebug)
end


function MainClassC:update()
	setPlayerHudComponentVisible("all", false)
	
	if (self.actionHandler) then
		self.actionHandler:update()
	end
	
	if (self.guiManager) then
		self.guiManager:update()
	end
	
	if (self.shaderManager) then
		self.shaderManager:update()
	end
	
	if (self.blockCursor) then
		self.blockCursor:update()
	end
	
	if (self.debugClass) then
		self.debugClass:update()
	end
end


function MainClassC:clear()
	if (self.modelHandler) then
		delete(self.modelHandler)
		self.modelHandler = nil
	end
	
	if (self.actionHandler) then
		delete(self.actionHandler)
		self.actionHandler = nil
	end
	
	if (self.inventoryHandler) then
		delete(self.inventoryHandler)
		self.inventoryHandler = nil
	end
	
	if (self.guiManager) then
		delete(self.guiManager)
		self.guiManager = nil
	end
	
	if (self.shaderManager) then
		delete(self.shaderManager)
		self.shaderManager = nil
	end
	
	if (self.blockCursor) then
		delete(self.blockCursor)
		self.blockCursor = nil
	end
	
	if (self.blockEvents) then
		delete(self.blockEvents)
		self.blockEvents = nil
	end
	
	if (self.debugClass) then
		delete(self.debugClass)
		self.debugClass = nil
	end
	
	if (self.testClass) then
		delete(self.testClass)
		self.testClass = nil
	end
end


function MainClassC:destructor()
	removeEventHandler("onClientRender", root, self.m_Update)
	unbindKey(self.debugKey, "down", self.m_ToggleDebug)
	
	self:clear()
	
	setPlayerHudComponentVisible("all", true)
	
	mainOutput("MainClassC was deleted.")
end


addEventHandler("onClientResourceStart", resourceRoot,
function()
	Instance = new(MainClassC)
end)


addEventHandler("onClientResourceStop", resourceRoot,
function()
	if (Instance) then
		delete(Instance)
		Instance = nil
	end
end)