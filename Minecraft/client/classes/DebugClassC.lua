--[[
	Name: Minecraft
	Filename: DebugClassC.lua
	Authors: Sam@ke
--]]


DebugClassC = {}

function DebugClassC:constructor(parent)
	mainOutput("DebugClassC was loaded.")
	
	self.mainClass = parent
	self.applicationName = "Minecraft"
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	
	self.postGUI = false
	self.subPixelPositioning = false
	self.fontSize = 0.85
	
	self.showEventParamaters = "false"
	self.showFunctionParamaters = "false"
	self.showRenderParamaters = "false"
	
	self.serverStats = {}
	
	self.m_ReceiveServerDebugStats = bind(self.receiveServerDebugStats, self)
	addEvent("receiveServerDebugStats", true)
	addEventHandler("receiveServerDebugStats", root, self.m_ReceiveServerDebugStats)
	
	self.m_OnPreEvent = bind(self.onPreEvent, self)
	addDebugHook("preEvent", self.m_OnPreEvent)
	
	self.m_OnPreFunction = bind(self.onPreFunction, self)
	addDebugHook("preFunction", self.m_OnPreFunction)
end


function DebugClassC:update()
	self:drawBG()
	
	dxDrawText(self.applicationName .. " Stats", self.screenWidth * 0.5, self.screenHeight * 0.14, self.screenWidth * 0.5, self.screenHeight * 0.14, tocolor(200, 90, 50, 180), 2, "default-bold", "center", "center", false, false, self.postGUI, true)

	self:drawLUATimingsClient()
	self:drawLUAMemoryClient()
	self:drawLibMemoryClient()
	self:drawPacketUsageClient()
end


function DebugClassC:drawBG()
	dxDrawRectangle(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.8, self.screenHeight * 0.8, tocolor(0, 0, 0, 180), self.postGUI, self.subPixelPositioning)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.1, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.1, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.9, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.9, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
end


function DebugClassC:drawLUATimingsClient()
	local arg1, arg2, arg3 = self:getLUATimings()
	local data = tostring(arg2) .. " / " .. tostring(arg3)
	
	local x1, y1 = self.screenWidth * 0.12, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.18
	
	dxDrawText("Lua Timings: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUAMemoryClient()
	local arg1, arg2, arg3, arg4 = self:getLUAMemory()
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.25, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.31, self.screenHeight * 0.18
	
	dxDrawText("Lua Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLibMemoryClient()
	local arg1, arg2, arg3, arg4 = self:getLibMemory()
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.12, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.2
	
	dxDrawText("Lib Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPacketUsageClient()
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = self:getPacketUsage()
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4) .. " / " .. tostring(arg5) .. " / " .. tostring(arg6) .. " / " .. tostring(arg7)
	
	local x1, y1 = self.screenWidth * 0.25, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.31, self.screenHeight * 0.2	
	
	dxDrawText("Packet Usage: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:getLUATimings()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lua timing", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3]
	end
end


function DebugClassC:getLUAMemory()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lua memory", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4]
	end
end


function DebugClassC:getLibMemory()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lib memory", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4]
	end
end


function DebugClassC:getPacketUsage()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Packet usage", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4], results[5], results[6], results[7]
	end
end


function DebugClassC:onPreEvent(sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
	if (self.showEventParamaters == "true") then
		if (self.showRenderParamaters == "false") then
			if (eventName) then
				if (eventName == "onClientRender") or (eventName == "onClientPreRender") or (eventName == "onClientHUDRender") then
					return
				end
			end
		end
		
		local args = { ... }
		local srctype = eventSource and getElementType(eventSource)
		local resname = sourceResource and getResourceName(sourceResource)
		local plrname = eventClient and getPlayerName(eventClient)
		
		mainOutput( "preEvent"
					.. " " .. tostring(resname)
					.. " " .. tostring(eventName)
					.. " source: " .. tostring(srctype)
					.. " player: " .. tostring(plrname)
					.. " file: " .. tostring(luaFilename)
					.. "(" .. tostring(luaLineNumber) .. ")"
					.. " numArgs: " .. tostring(#args)
					.. " arg1: " .. tostring(args[1])
					.. " arg2: " .. tostring(args[2])
					.. " arg3: " .. tostring(args[3])
					.. " arg4: " .. tostring(args[4])
					)

	end
end


function DebugClassC:onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
	if (self.showFunctionParamaters == "true") then
		if (self.showRenderParamaters == "false") then
			if (functionName) then
				if (string.find(functionName, "dxDraw")) then
					return
				end
			end
		end
		
		local args = { ... }
		local resname = sourceResource and getResourceName(sourceResource)
		
		mainOutput( "preFunction"
					.. " " .. tostring(resname)
					.. " " .. tostring(functionName)
					.. " allowed:" .. tostring(isAllowedByACL)
					.. " file:" .. tostring(luaFilename)
					.. "(" .. tostring(luaLineNumber) .. ")"
					.. " numArgs:" .. tostring(#args)
					.. " arg1: " .. tostring(args[1])
					.. " arg2: " .. tostring(args[2])
					.. " arg3: " .. tostring(args[3])
					.. " arg4: " .. tostring(args[4])
					)

	end
end


function DebugClassC:receiveServerDebugStats(serverStats)
	if (serverStats) then
		self.serverStats = serverStats
	end
end


function DebugClassC:destructor()
	removeEventHandler("receiveServerDebugStats", root, self.m_ReceiveServerDebugStats)

	removeDebugHook("preEvent", self.m_OnPreEvent)
	removeDebugHook("preFunction", self.m_OnPreFunction)
	
	mainOutput("DebugClassC was deleted.")
end