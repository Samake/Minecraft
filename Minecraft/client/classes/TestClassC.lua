--[[
	Name: Minecraft
	Filename: TestClassC.lua
	Authors: Sam@ke
--]]


TestClassC = {}

function TestClassC:constructor(parent)
	mainOutput("TestClassC was loaded.")
	
	self.mainClass = parent

	self.streamKey = "N"
	self.layerKey = "B"
	self.isStreamed = "true"
	
	self.m_ToggleStreaming = bind(self.toggleStreaming, self)
	bindKey(self.streamKey, "down", self.m_ToggleStreaming)
	
	self.m_CreateLayer = bind(self.createLayer, self)
	bindKey(self.layerKey, "down", self.m_CreateLayer)
end


function TestClassC:createLayer()
	triggerServerEvent("CreateLayer", root)
end


function TestClassC:toggleStreaming()
	if (self.isStreamed == "true") then
		self:disableStreaming()
		self.isStreamed = "false"
	elseif (self.isStreamed == "false") then
		self:enableStreaming()
		self.isStreamed = "true"
	end
end


function TestClassC:enableStreaming()
	local id = 0
	
	for index, object in pairs(getElementsByType("object")) do
		if (object) then
			local type = object:getData("OBJECTTYPE")
			if (type) then
				if (type == "MCBLOCK") or (type == "MCDOOR") then
					object:setStreamable(false)
					id = id + 1
				end
			end
		end
	end
	
	mainOutput("CLIENT // Objects with enabled streaming: " .. id)
end


function TestClassC:disableStreaming()
	local id = 0
	
	for index, object in pairs(getElementsByType("object")) do
		if (object) then
			local type = object:getData("OBJECTTYPE")
			if (type) then
				if (type == "MCBLOCK") or (type == "MCDOOR") then
					object:setStreamable(false)
					id = id + 1
				end
			end
		end
	end
	
	mainOutput("CLIENT // Objects with disabled streaming: " .. id)
end


function TestClassC:destructor()
	unbindKey(self.streamKey, "down", self.m_ToggleStreaming)
	unbindKey(self.layerKey, "down", self.m_CreateLayer)
	
	mainOutput("TestClassC was deleted.")
end