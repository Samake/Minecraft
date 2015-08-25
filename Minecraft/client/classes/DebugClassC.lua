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
	
	self.clientDebugStats = {}
	self.clientDebugStats.luaTimings = {arg1 = "-", arg2 = "-", arg3 = "-"}
	self.clientDebugStats.luaMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-"}
	self.clientDebugStats.libMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-",}
	self.clientDebugStats.packetUsage = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-", arg5 = "-", arg6 = "-", arg7 = "-"}
	
	self.serverDebugStats = {}
	self.serverDebugStats.luaTimings = {arg1 = "-", arg2 = "-", arg3 = "-"}
	self.serverDebugStats.luaMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-"}
	self.serverDebugStats.libMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-",}
	self.serverDebugStats.packetUsage = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-", arg5 = "-", arg6 = "-", arg7 = "-"}
	
	self.clientNetworkStats = {}
	self.serverNetworkStats = {}
	
	self.updateInterval = 500
	
	self.m_UpdateSlowly = bind(self.updateSlowly, self)
	self.updateTimer = setTimer(self.m_UpdateSlowly, self.updateInterval, 0)
	
	self.m_ReceiveServerDebugStats = bind(self.receiveServerDebugStats, self)
	addEvent("receiveServerDebugStats", true)
	addEventHandler("receiveServerDebugStats", root, self.m_ReceiveServerDebugStats)
	
	self.m_ReceiveServerNetworkStats = bind(self.receiveServerNetworkStats, self)
	addEvent("receiveServerNetworkStats", true)
	addEventHandler("receiveServerNetworkStats", root, self.m_ReceiveServerNetworkStats)
	
	self.m_OnPreEvent = bind(self.onPreEvent, self)
	addDebugHook("preEvent", self.m_OnPreEvent)
	
	self.m_OnPreFunction = bind(self.onPreFunction, self)
	addDebugHook("preFunction", self.m_OnPreFunction)
end

function DebugClassC:updateSlowly()
	local arg1, arg2, arg3 = self:getLUATimings()
	self.clientDebugStats.luaTimings = {arg1 = arg1, arg2 = arg2, arg3 = arg3}
	
	local arg1, arg2, arg3, arg4 = self:getLUAMemory()
	self.clientDebugStats.luaMemory = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4}
	
	local arg1, arg2, arg3, arg4 = self:getLibMemory()
	self.clientDebugStats.libMemory = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4}
	
	local arg1, arg2, arg3, arg4 = self:getPacketUsage()
	self.clientDebugStats.packetUsage = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4, arg5 = arg5, arg6 = arg6, arg7 = arg7}
end


function DebugClassC:update()
	self:drawBG()
	
	dxDrawText(self.applicationName .. " Stats", self.screenWidth * 0.5, self.screenHeight * 0.13, self.screenWidth * 0.5, self.screenHeight * 0.13, tocolor(200, 90, 50, 180), 2, "default-bold", "center", "center", false, false, self.postGUI, true)
	dxDrawText("Client", self.screenWidth * 0.25, self.screenHeight * 0.14, self.screenWidth * 0.25, self.screenHeight * 0.14, tocolor(200, 150, 90, 180), 1.2, "default-bold", "center", "center", false, false, self.postGUI, true)
	dxDrawText("Server", self.screenWidth * 0.75, self.screenHeight * 0.14, self.screenWidth * 0.75, self.screenHeight * 0.14, tocolor(200, 150, 90, 180), 1.2, "default-bold", "center", "center", false, false, self.postGUI, true)

	self:drawLUATimingsClient()
	self:drawLUAMemoryClient()
	self:drawLibMemoryClient()
	self:drawPacketUsageClient()
	
	self:drawLUATimingsServer()
	self:drawLUAMemoryServer()
	self:drawLibMemoryServer()
	self:drawPacketUsageServer()
	
	self:drawNetworkDiagramBGClient()
	self:drawNetworkDiagramBGServer()
end


function DebugClassC:drawBG()
	dxDrawRectangle(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.8, self.screenHeight * 0.8, tocolor(0, 0, 0, 220), self.postGUI, self.subPixelPositioning)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.1, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.1, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.9, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.9, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.5, self.screenHeight * 0.2, self.screenWidth * 0.5, self.screenHeight * 0.85, tocolor(120, 120, 120, 180), 1,  self.postGUI)
end


function DebugClassC:drawLUATimingsClient()
	local arg1, arg2, arg3 = self.clientDebugStats.luaTimings.arg1, self.clientDebugStats.luaTimings.arg2, self.clientDebugStats.luaTimings.arg3
	local data = tostring(arg2) .. " / " .. tostring(arg3)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.17, self.screenHeight * 0.18
	
	dxDrawText("Lua Timings: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUATimingsServer()
	local arg1, arg2, arg3 = self.serverDebugStats.luaTimings.arg1, self.serverDebugStats.luaTimings.arg2, self.serverDebugStats.luaTimings.arg3
	local data = tostring(arg2) .. " / " .. tostring(arg3)
	
	local x1, y1 = self.screenWidth * 0.57, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.63, self.screenHeight * 0.18
	
	dxDrawText("Lua Timings: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUAMemoryClient()
	local arg1, arg2, arg3, arg4 = self.clientDebugStats.luaMemory.arg1, self.clientDebugStats.luaMemory.arg2, self.clientDebugStats.luaMemory.arg3, self.clientDebugStats.luaMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.36, self.screenHeight * 0.18
	
	dxDrawText("Lua Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUAMemoryServer()
	local arg1, arg2, arg3, arg4 = self.serverDebugStats.luaMemory.arg1, self.serverDebugStats.luaMemory.arg2, self.serverDebugStats.luaMemory.arg3, self.serverDebugStats.luaMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.18
	local x2, y2 = self.screenWidth * 0.76, self.screenHeight * 0.18
	
	dxDrawText("Lua Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLibMemoryClient()
	local arg1, arg2, arg3, arg4 = self.clientDebugStats.luaMemory.arg1, self.clientDebugStats.luaMemory.arg2, self.clientDebugStats.luaMemory.arg3, self.clientDebugStats.luaMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.17, self.screenHeight * 0.2
	
	dxDrawText("Lib Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLibMemoryServer()
	local arg1, arg2, arg3, arg4 = self.serverDebugStats.libMemory.arg1, self.serverDebugStats.libMemory.arg2, self.serverDebugStats.libMemory.arg3, self.serverDebugStats.libMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.57, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.63, self.screenHeight * 0.2
	
	dxDrawText("Lib Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPacketUsageClient()
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = self.clientDebugStats.packetUsage.arg1, self.clientDebugStats.packetUsage.arg2, self.clientDebugStats.packetUsage.arg3, self.clientDebugStats.packetUsage.arg4, self.clientDebugStats.packetUsage.arg5, self.clientDebugStats.packetUsage.arg6, self.clientDebugStats.packetUsage.arg7
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4) .. " / " .. tostring(arg5) .. " / " .. tostring(arg6) .. " / " .. tostring(arg7)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.36, self.screenHeight * 0.2	
	
	dxDrawText("Packet Usage: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPacketUsageServer()
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = self.serverDebugStats.packetUsage.arg1, self.serverDebugStats.packetUsage.arg2, self.serverDebugStats.packetUsage.arg3, self.serverDebugStats.packetUsage.arg4, self.serverDebugStats.packetUsage.arg5, self.serverDebugStats.packetUsage.arg6, self.serverDebugStats.packetUsage.arg7
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4) .. " / " .. tostring(arg5) .. " / " .. tostring(arg6) .. " / " .. tostring(arg7)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.2
	local x2, y2 = self.screenWidth * 0.76, self.screenHeight * 0.2	
	
	dxDrawText("Packet Usage: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkDiagramBGClient()
	local x, y = self.screenWidth * 0.12, self.screenHeight * 0.5
	
	dxDrawLine(x, y, x, y + self.screenHeight * 0.35, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(x, y + self.screenHeight * 0.35, x + self.screenWidth * 0.36, y + self.screenHeight * 0.35, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	
	for i = 0, 35, 5 do
		i = i / 100
		dxDrawLine(x - 4, self.screenHeight * (0.5 + i), x + 4, self.screenHeight * (0.5 + i), tocolor(120, 120, 120, 180), 1,  self.postGUI)
	end
	
	for j = 0, 36, 4 do
		j = j / 100
		dxDrawLine(x + self.screenWidth * j, (y + self.screenHeight * 0.35) - 4, x + self.screenWidth * j, (y + self.screenHeight * 0.35) + 4, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	end
end


function DebugClassC:drawNetworkDiagramBGServer()
	local x, y = self.screenWidth * 0.52, self.screenHeight * 0.5
	
	dxDrawLine(x, y, x, y + self.screenHeight * 0.35, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(x, y + self.screenHeight * 0.35, x + self.screenWidth * 0.36, y + self.screenHeight * 0.35, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	
	for i = 0, 35, 5 do
		i = i / 100
		dxDrawLine(x - 4, self.screenHeight * (0.5 + i), x + 4, self.screenHeight * (0.5 + i), tocolor(120, 120, 120, 180), 1,  self.postGUI)
	end
	
	for j = 0, 36, 4 do
		j = j / 100
		dxDrawLine(x + self.screenWidth * j, (y + self.screenHeight * 0.35) - 4, x + self.screenWidth * j, (y + self.screenHeight * 0.35) + 4, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	end
end


function DebugClassC:drawNetworkStatsServer()

--bytesReceived - Total number of bytes received since the connection was started
--bytesSent - Total number of bytes sent since the connection was started
--packetsReceived - Total number of packets received since the connection was started
--packetsSent - Total number of packets sent since the connection was started
--packetlossTotal - (0-100) Total packet loss percentage of sent data, since the connection was started
--packetlossLastSecond - (0-100) Packet loss percentage of sent data, during the previous second
--messagesInSendBuffer
--messagesInResendBuffer - Number of packets queued to be resent (due to packet loss)
--isLimitedByCongestionControl
--isLimitedByOutgoingBandwidthLimit
--encryptionStatus
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


function DebugClassC:receiveServerDebugStats(serverDebugStats)
	if (serverDebugStats) then
		self.serverDebugStats = serverDebugStats
	end
end


function DebugClassC:receiveServerNetworkStats(serverNetworkStats)
	if (serverNetworkStats) then
		self.serverNetworkStats = serverNetworkStats
	end
end


function DebugClassC:destructor()
	removeEventHandler("receiveServerDebugStats", root, self.m_ReceiveServerDebugStats)
	removeEventHandler("receiveServerNetworkStats", root, self.m_ReceiveServerNetworkStats)
	
	if (self.updateTimer) then
		self.updateTimer:destroy()
		self.updateTimer = nil
	end
	
	self.clientDebugStats = nil
	self.serverDebugStats = nil

	removeDebugHook("preEvent", self.m_OnPreEvent)
	removeDebugHook("preFunction", self.m_OnPreFunction)
	
	mainOutput("DebugClassC was deleted.")
end