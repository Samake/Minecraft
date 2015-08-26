--[[
	Name: Minecraft
	Filename: DebugClassC.lua
	Authors: Sam@ke
--]]


DebugClassC = {}

function DebugClassC:constructor(parent)
	mainOutput("DebugClassC was loaded.")
	
	self.mainClass = parent
	self.applicationName = getResourceName(getThisResource())
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	self.player = getLocalPlayer()
	self.playerPosClient = {x = 0, y = 0, z = 0}
	self.playerPosServer = {x = 0, y = 0, z = 0}
	self.ping = 0
	self.fps = 0
	self.fpsTable = {}
	self.allElementsTableClient = {}
	self.allElementsTableServer = {}
	self.lostPacketsTableClient = {}
	self.lostPacketsTableServer = {}
	self.resendPacketsTableClient = {}
	self.resendPacketsTableServer = {}
	
	self.postGUI = false
	self.subPixelPositioning = false
	self.fontSize = 0.9
	
	self.showEventParamaters = "false"
	self.showFunctionParamaters = "false"
	self.showRenderParamaters = "false"
	
	self.clientDebugStats = {}
	self.clientDebugStats.luaTimings = {arg1 = "-", arg2 = "-", arg3 = "-"}
	self.clientDebugStats.luaMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-"}
	self.clientDebugStats.libMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-",}
	self.clientDebugStats.packetUsage = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-", arg5 = "-", arg6 = "-", arg7 = "-"}
	self.clientDebugStats.elements = {players = "-", peds = "-", vehicles = "-", objects = "-", timers = "-", shaders = "-", textures = "-", all = "-"}
	
	self.serverDebugStats = {}
	self.serverDebugStats.luaTimings = {arg1 = "-", arg2 = "-", arg3 = "-"}
	self.serverDebugStats.luaMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-"}
	self.serverDebugStats.libMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-",}
	self.serverDebugStats.packetUsage = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-", arg5 = "-", arg6 = "-", arg7 = "-"}
	self.serverDebugStats.elements = {players = "-", peds = "-", vehicles = "-", objects = "-", timers = "-", shaders = "-", textures = "-", all = "-"}
	
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
	
	self.m_ReceivePlayerStats = bind(self.receivePlayerStats, self)
	addEvent("receivePlayerStats", true)
	addEventHandler("receivePlayerStats", root, self.m_ReceivePlayerStats)
	
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
	
	self.clientDebugStats.elements = {	players = #getElementsByType("player"), 
											peds = #getElementsByType("ped"), 
											vehicles = #getElementsByType("vehicle"), 
											objects = #getElementsByType("object"), 
											timers = #getTimers(), 
											shaders = #getElementsByType("shader"), 
											textures = #getElementsByType("texture"), 
											blocks = #getElementsByType("MCBLOCK") + #getElementsByType("MCDOOR"),
											all = 	#getElementsByType("player") + 
													#getElementsByType("ped") + 
													#getElementsByType("vehicle") +
													#getElementsByType("object") +
													#getTimers() +
													#getElementsByType("shader") +
													#getElementsByType("texture")}
				
	self.clientNetworkStats = getNetworkStats()
	self.ping = self.player:getPing()
	self.playerPosClient = self.player:getPosition()
	
	if (#self.fpsTable < 25) then
		table.insert(self.fpsTable, self.fps)
	else
		self.fpsTable = self:reOrganizeTable(self.fpsTable, self.fps)
	end
	
	
	if (#self.allElementsTableClient < 25) then
		table.insert(self.allElementsTableClient, self.clientDebugStats.elements.all)
	else
		self.allElementsTableClient = self:reOrganizeTable(self.allElementsTableClient, self.clientDebugStats.elements.all)
	end
	
	
	if (#self.allElementsTableServer < 25) then
		table.insert(self.allElementsTableServer, self.serverDebugStats.elements.all)
	else
		self.allElementsTableServer = self:reOrganizeTable(self.allElementsTableServer, self.serverDebugStats.elements.all)
	end
	--self.lostPacketsTableClient = {}
	--self.lostPacketsTableServer = {}
	--self.resendPacketsTableClient = {}
	--self.resendPacketsTableServer = {}
end


function DebugClassC:reOrganizeTable(table, fps)
	if (table) and (fps) then
		local newTable = {}

		for i = 1, 24, 1 do
			newTable[i] = table[i + 1]
		end
		
		newTable[25] = fps

		return newTable
	end
end


function DebugClassC:update()
	self.fps = getFPS()

	self:drawBG()
	
	dxDrawText(self.applicationName .. " Stats", self.screenWidth * 0.5, self.screenHeight * 0.125, self.screenWidth * 0.5, self.screenHeight * 0.125, tocolor(200, 90, 50, 180), 1.5, "default-bold", "center", "center", false, false, self.postGUI, true)
	dxDrawText("Client", self.screenWidth * 0.3, self.screenHeight * 0.21, self.screenWidth * 0.3, self.screenHeight * 0.21, tocolor(200, 150, 90, 180), 1.2, "default-bold", "center", "center", false, false, self.postGUI, true)
	dxDrawText("Server", self.screenWidth * 0.7, self.screenHeight * 0.21, self.screenWidth * 0.7, self.screenHeight * 0.21, tocolor(200, 150, 90, 180), 1.2, "default-bold", "center", "center", false, false, self.postGUI, true)
	
	self:drawFPS()
	self:drawPing()
	self:drawPlayerPosClient()
	self:drawPlayerPosServer()
	self:drawPlayerDesync()

	self:drawLUATimingsClient()
	self:drawLUAMemoryClient()
	self:drawLibMemoryClient()
	self:drawPacketUsageClient()
	self:drawLUATimingsServer()
	self:drawLUAMemoryServer()
	self:drawLibMemoryServer()
	self:drawPacketUsageServer()
	
	self:drawElementsPlayersClient()
	self:drawElementsPlayersServer()
	self:drawElementsPedsClient()
	self:drawElementsPedsServer()
	self:drawElementsVehiclesClient()
	self:drawElementsVehiclesServer()
	self:drawElementsObjectsClient()
	self:drawElementsObjectsServer()
	self:drawElementsTimersClient()
	self:drawElementsTimersServer()
	self:drawElementsShadersClient()
	self:drawElementsShadersServer()
	self:drawElementsTexturesClient()
	self:drawElementsTexturesServer()
	self:drawElementsBlocksClient()
	self:drawElementsBlocksServer()
	self:drawElementsAllClient()
	self:drawElementsAllServer()
	
	self:drawNetworkBytesReceivedClient()
	self:drawNetworkBytesReceivedServer()
	self:drawNetworkBytesSentClient()
	self:drawNetworkBytesSentServer()
	self:drawNetworkPacketsReceivedClient()
	self:drawNetworkPacketsReceivedServer()
	self:drawNetworkPacketsSentClient()
	self:drawNetworkPacketsSentServer()
	self:drawNetworkPacketLossTotalClient()
	self:drawNetworkPacketLossTotalServer()
	self:drawNetworkPacketLossSecondClient()
	self:drawNetworkPacketLossSecondServer()
	self:drawNetworkPacketsResendClient()
	self:drawNetworkPacketsResendServer()
	self:drawNetworkEncryptionStatusClient()
	self:drawNetworkEncryptionStatusServer()
	
	self:drawDiagramBGClient()
	self:drawDiagramBGServer()
	
	self:drawDiagramGraphFPS()
	self:drawDiagramGraphAllElementsClient()
	self:drawDiagramGraphAllElementsServer()
end


function DebugClassC:drawBG()
	dxDrawRectangle(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.8, self.screenHeight * 0.8, tocolor(0, 0, 0, 220), self.postGUI, self.subPixelPositioning)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.1, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.1, self.screenWidth * 0.1, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.9, self.screenHeight * 0.1, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.1, self.screenHeight * 0.9, self.screenWidth * 0.9, self.screenHeight * 0.9, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.5, self.screenHeight * 0.2, self.screenWidth * 0.5, self.screenHeight * 0.88, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.11, self.screenHeight * 0.15, self.screenWidth * 0.88, self.screenHeight * 0.15, tocolor(120, 120, 120, 180), 1,  self.postGUI)
	dxDrawLine(self.screenWidth * 0.11, self.screenHeight * 0.185, self.screenWidth * 0.88, self.screenHeight * 0.185, tocolor(120, 120, 120, 180), 1,  self.postGUI)
end


function DebugClassC:drawFPS()
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.17
	local x2, y2 = self.screenWidth * 0.14, self.screenHeight * 0.17
	
	dxDrawText("FPS: ", x1, y1, x1, y1, tocolor(50, 50, 200, 180), self.fontSize, "default-bold", "left", "center", false, false, self.postGUI, true)
	dxDrawText(self.fps, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPing()
	local x1, y1 = self.screenWidth * 0.19, self.screenHeight * 0.17
	local x2, y2 = self.screenWidth * 0.22, self.screenHeight * 0.17
	
	dxDrawText("Ping: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(self.ping, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPlayerPosClient()
	local data = string.format("%.2f", self.playerPosClient.x) .. ", " .. string.format("%.2f", self.playerPosClient.y) .. ", " .. string.format("%.2f", self.playerPosClient.z)
	local x1, y1 = self.screenWidth * 0.27, self.screenHeight * 0.17
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.17
	
	dxDrawText("Player Position (client): ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPlayerPosServer()
	local data = string.format("%.2f", self.playerPosServer.x) .. ", " .. string.format("%.2f", self.playerPosServer.y) .. ", " .. string.format("%.2f", self.playerPosServer.z)
	local x1, y1 = self.screenWidth * 0.5, self.screenHeight * 0.17
	local x2, y2 = self.screenWidth * 0.6, self.screenHeight * 0.17
	
	dxDrawText("Player Position (server): ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPlayerDesync()
	local data = getDistanceBetweenPoints3D(self.playerPosClient.x, self.playerPosClient.y, self.playerPosClient.z, self.playerPosServer.x, self.playerPosServer.y, self.playerPosServer.z)
	local x1, y1 = self.screenWidth * 0.73, self.screenHeight * 0.17
	local x2, y2 = self.screenWidth * 0.8, self.screenHeight * 0.17
	
	dxDrawText("Player DeSync: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(string.format("%.4f", data) .. " m", x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUATimingsClient()
	local arg1, arg2, arg3 = self.clientDebugStats.luaTimings.arg1, self.clientDebugStats.luaTimings.arg2, self.clientDebugStats.luaTimings.arg3
	local data = tostring(arg2) .. " / " .. tostring(arg3)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.24
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.24
	
	dxDrawText("Lua Timings: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUATimingsServer()
	local arg1, arg2, arg3 = self.serverDebugStats.luaTimings.arg1, self.serverDebugStats.luaTimings.arg2, self.serverDebugStats.luaTimings.arg3
	local data = tostring(arg2) .. " / " .. tostring(arg3)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.24
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.24
	
	dxDrawText("Lua Timings: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUAMemoryClient()
	local arg1, arg2, arg3, arg4 = self.clientDebugStats.luaMemory.arg1, self.clientDebugStats.luaMemory.arg2, self.clientDebugStats.luaMemory.arg3, self.clientDebugStats.luaMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.24
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.24
	
	dxDrawText("Lua Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLUAMemoryServer()
	local arg1, arg2, arg3, arg4 = self.serverDebugStats.luaMemory.arg1, self.serverDebugStats.luaMemory.arg2, self.serverDebugStats.luaMemory.arg3, self.serverDebugStats.luaMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.24
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.24
	
	dxDrawText("Lua Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLibMemoryClient()
	local arg1, arg2, arg3, arg4 = self.clientDebugStats.libMemory.arg1, self.clientDebugStats.libMemory.arg2, self.clientDebugStats.libMemory.arg3, self.clientDebugStats.libMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.26
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.26
	
	dxDrawText("Lib Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawLibMemoryServer()
	local arg1, arg2, arg3, arg4 = self.serverDebugStats.libMemory.arg1, self.serverDebugStats.libMemory.arg2, self.serverDebugStats.libMemory.arg3, self.serverDebugStats.libMemory.arg4
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.26
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.26
	
	dxDrawText("Lib Memory: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPacketUsageClient()
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = self.clientDebugStats.packetUsage.arg1, self.clientDebugStats.packetUsage.arg2, self.clientDebugStats.packetUsage.arg3, self.clientDebugStats.packetUsage.arg4, self.clientDebugStats.packetUsage.arg5, self.clientDebugStats.packetUsage.arg6, self.clientDebugStats.packetUsage.arg7
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4) .. " / " .. tostring(arg5) .. " / " .. tostring(arg6) .. " / " .. tostring(arg7)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.26
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.26
	
	dxDrawText("Packet Usage: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawPacketUsageServer()
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = self.serverDebugStats.packetUsage.arg1, self.serverDebugStats.packetUsage.arg2, self.serverDebugStats.packetUsage.arg3, self.serverDebugStats.packetUsage.arg4, self.serverDebugStats.packetUsage.arg5, self.serverDebugStats.packetUsage.arg6, self.serverDebugStats.packetUsage.arg7
	local data = tostring(arg2) .. " / " .. tostring(arg3) .. " / " .. tostring(arg4) .. " / " .. tostring(arg5) .. " / " .. tostring(arg6) .. " / " .. tostring(arg7)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.26
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.26
	
	dxDrawText("Packet Usage: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsPlayersClient()
	local data = tostring(self.clientDebugStats.elements.players)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.29
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.29
	
	dxDrawText("Players: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsPlayersServer()
	local data = tostring(self.serverDebugStats.elements.players)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.29
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.29
	
	dxDrawText("Players: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsPedsClient()
	local data = tostring(self.clientDebugStats.elements.peds)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.29
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.29
	
	dxDrawText("Peds: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsPedsServer()
	local data = tostring(self.serverDebugStats.elements.peds)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.29
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.29
	
	dxDrawText("Peds: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsVehiclesClient()
	local data = tostring(self.clientDebugStats.elements.vehicles)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.31
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.31
	
	dxDrawText("Vehicles: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsVehiclesServer()
	local data = tostring(self.serverDebugStats.elements.vehicles)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.31
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.31
	
	dxDrawText("Vehicles: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsObjectsClient()
	local data = tostring(self.clientDebugStats.elements.objects)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.31
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.31
	
	dxDrawText("Objects: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsObjectsServer()
	local data = tostring(self.serverDebugStats.elements.objects)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.31
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.31
	
	dxDrawText("Objects: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsTimersClient()
	local data = tostring(self.clientDebugStats.elements.timers)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.33
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.33
	
	dxDrawText("Timers: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsTimersServer()
	local data = tostring(self.serverDebugStats.elements.timers)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.33
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.33
	
	dxDrawText("Timers: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsShadersClient()
	local data = tostring(self.clientDebugStats.elements.shaders)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.33
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.33
	
	dxDrawText("Shaders: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsShadersServer()
	local data = tostring(self.serverDebugStats.elements.shaders)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.33
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.33
	
	dxDrawText("Shaders: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsTexturesClient()
	local data = tostring(self.clientDebugStats.elements.textures)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.35
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.35
	
	dxDrawText("Textures: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsTexturesServer()
	local data = tostring(self.serverDebugStats.elements.textures)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.35
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.35
	
	dxDrawText("Textures: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsBlocksClient()
	local data = tostring(self.clientDebugStats.elements.blocks)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.35
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.35
	
	dxDrawText("MC Blocks: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsBlocksServer()
	local data = tostring(self.serverDebugStats.elements.blocks)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.35
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.35
	
	dxDrawText("MC Blocks: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsAllClient()
	local data = tostring(self.clientDebugStats.elements.all)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.37
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.37
	
	dxDrawText("All Elements: ", x1, y1, x1, y1, tocolor(50, 200, 50, 180), self.fontSize, "default-bold", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawElementsAllServer()
	local data = tostring(self.serverDebugStats.elements.all)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.37
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.37
	
	dxDrawText("All Elements: ", x1, y1, x1, y1, tocolor(50, 200, 50, 180), self.fontSize, "default-bold", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkBytesReceivedClient()
	local data = tostring(self.clientNetworkStats.bytesReceived)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.4
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.4
	
	dxDrawText("Bytes received: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkBytesReceivedServer()
	local data = tostring(self.serverNetworkStats.bytesReceived)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.4
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.4
	
	dxDrawText("Bytes received: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkBytesSentClient()
	local data = tostring(self.clientNetworkStats.bytesSent)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.4
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.4
	
	dxDrawText("Bytes sent: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkBytesSentServer()
	local data = tostring(self.serverNetworkStats.bytesSent)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.4
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.4
	
	dxDrawText("Bytes sent: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsReceivedClient()
	local data = tostring(self.clientNetworkStats.packetsReceived)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.42
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.42
	
	dxDrawText("Packets received: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsReceivedServer()
	local data = tostring(self.serverNetworkStats.packetsReceived)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.42
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.42
	
	dxDrawText("Packets received: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsSentClient()
	local data = tostring(self.clientNetworkStats.packetsSent)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.42
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.42
	
	dxDrawText("Packets sent: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsSentServer()
	local data = tostring(self.serverNetworkStats.packetsSent)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.42
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.42
	
	dxDrawText("Packets sent: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketLossTotalClient()
	local data = tostring(self.clientNetworkStats.packetlossTotal)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.44
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.44
	
	dxDrawText("Packet Loss: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketLossTotalServer()
	local data = tostring(self.serverNetworkStats.packetlossTotal)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.44
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.44
	
	dxDrawText("Packet Loss: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketLossSecondClient()
	local data = tostring(self.clientNetworkStats.packetlossLastSecond)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.44
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.44
	
	dxDrawText("Packet Loss (s): ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketLossSecondServer()
	local data = tostring(self.serverNetworkStats.packetlossLastSecond)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.44
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.44
	
	dxDrawText("Packet Loss (s): ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsResendClient()
	local data = tostring(self.clientNetworkStats.messagesInResendBuffer)
	
	local x1, y1 = self.screenWidth * 0.11, self.screenHeight * 0.46
	local x2, y2 = self.screenWidth * 0.18, self.screenHeight * 0.46
	
	dxDrawText("Packets Resend: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkPacketsResendServer()
	local data = tostring(self.serverNetworkStats.messagesInResendBuffer)
	
	local x1, y1 = self.screenWidth * 0.51, self.screenHeight * 0.46
	local x2, y2 = self.screenWidth * 0.58, self.screenHeight * 0.46
	
	dxDrawText("Packets Resend: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkEncryptionStatusClient()
	local data = tostring(self.clientNetworkStats.encryptionStatus)
	
	local x1, y1 = self.screenWidth * 0.3, self.screenHeight * 0.46
	local x2, y2 = self.screenWidth * 0.37, self.screenHeight * 0.46
	
	dxDrawText("Encryption state: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawNetworkEncryptionStatusServer()
	local data = tostring(self.serverNetworkStats.encryptionStatus)
	
	local x1, y1 = self.screenWidth * 0.7, self.screenHeight * 0.46
	local x2, y2 = self.screenWidth * 0.77, self.screenHeight * 0.46
	
	dxDrawText("Encryption state: ", x1, y1, x1, y1, tocolor(220, 220, 220, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
	dxDrawText(data, x2, y2, x2, y2, tocolor(200, 200, 90, 180), self.fontSize, "default", "left", "center", false, false, self.postGUI, true)
end


function DebugClassC:drawDiagramGraphFPS()
	local x, y = self.screenWidth * 0.12, self.screenHeight * 0.85
	local stepWidthLength = (self.screenWidth * 0.36) / #self.fpsTable
	local stepHeightLength = (self.screenWidth * 0.15) / 60
	
	for i = 1, #self.fpsTable, 1 do
		if (self.fpsTable[i]) and (stepWidthLength) and (stepHeightLength) then
			local lastValue
			if (self.fpsTable[i - 1]) then lastValue = self.fpsTable[i - 1] else lastValue = self.fpsTable[#self.fpsTable] end
			if (not lastValue) then lastValue = 0 end
			local currentValue = self.fpsTable[i]
			local x1 = x + (stepWidthLength * (i - 1))
			local y1 = y - (stepHeightLength * lastValue)
			local x2 = x + (stepWidthLength * i)
			local y2 = y - (stepHeightLength * currentValue)

			dxDrawLine(x1, y1, x2, y2, tocolor(50, 50, 200, 180), 1.5,  self.postGUI)
		end
	end
end


function DebugClassC:drawDiagramGraphAllElementsClient()
	local x, y = self.screenWidth * 0.12, self.screenHeight * 0.85
	local stepWidthLength = (self.screenWidth * 0.36) / #self.allElementsTableClient
	
	local highestValue = 0
	
	for i = 1, #self.allElementsTableClient, 1 do
		if (self.allElementsTableClient[i]) then
			if (self.allElementsTableClient[i] > highestValue) then
				highestValue = self.allElementsTableClient[i]
			end
		end
	end
	 
	local heightModifier = math.floor(highestValue / 1000) + 0.5

	if (heightModifier <= 1) then heightModifier = 1 end

	local stepHeightLength = (self.screenWidth * 0.12) / (1000 * heightModifier)
	
	for i = 1, #self.allElementsTableClient, 1 do
		if (self.allElementsTableClient[i]) and (stepWidthLength) and (stepHeightLength) then
			local lastValue
			if (self.allElementsTableClient[i - 1]) then lastValue = self.allElementsTableClient[i - 1] else lastValue = self.allElementsTableClient[#self.allElementsTableClient] end
			if (not lastValue) then lastValue = 0 end
			local currentValue = self.allElementsTableClient[i]
			local x1 = x + (stepWidthLength * (i - 1))
			local y1 = y - (stepHeightLength * lastValue)
			local x2 = x + (stepWidthLength * i)
			local y2 = y - (stepHeightLength * currentValue)

			dxDrawLine(x1, y1, x2, y2, tocolor(50, 200, 50, 180), 1.5,  self.postGUI)
		end
	end
end


function DebugClassC:drawDiagramGraphAllElementsServer()
	local x, y = self.screenWidth * 0.52, self.screenHeight * 0.85
	local stepWidthLength = (self.screenWidth * 0.36) / #self.allElementsTableServer
	
	local highestValue = 0
	
	for i = 1, #self.allElementsTableServer, 1 do
		if (self.allElementsTableServer[i]) then
			if (self.allElementsTableServer[i] > highestValue) then
				highestValue = self.allElementsTableServer[i]
			end
		end
	end
	 
	local heightModifier = math.floor(highestValue / 1000) + 0.5

	if (heightModifier <= 1) then heightModifier = 1 end

	local stepHeightLength = (self.screenWidth * 0.12) / (1000 * heightModifier)
	
	for i = 1, #self.allElementsTableServer, 1 do
		if (self.allElementsTableServer[i]) and (stepWidthLength) and (stepHeightLength) then
			local lastValue
			if (self.allElementsTableServer[i - 1]) then lastValue = self.allElementsTableServer[i - 1] else lastValue = self.allElementsTableServer[#self.allElementsTableServer] end
			if (not lastValue) then lastValue = 0 end
			local currentValue = self.allElementsTableServer[i]
			local x1 = x + (stepWidthLength * (i - 1))
			local y1 = y - (stepHeightLength * lastValue)
			local x2 = x + (stepWidthLength * i)
			local y2 = y - (stepHeightLength * currentValue)

			dxDrawLine(x1, y1, x2, y2, tocolor(50, 200, 50, 180), 1.5,  self.postGUI)
		end
	end
end


function DebugClassC:drawDiagramBGClient()
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


function DebugClassC:drawDiagramBGServer()
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


function DebugClassC:receivePlayerStats(playerPos)
	if (playerPos) then
		self.playerPosServer = playerPos
	end
end


function DebugClassC:destructor()
	removeEventHandler("receiveServerDebugStats", root, self.m_ReceiveServerDebugStats)
	removeEventHandler("receiveServerNetworkStats", root, self.m_ReceiveServerNetworkStats)
	removeEventHandler("receivePlayerStats", root, self.m_ReceivePlayerStats)
	
	if (self.updateTimer) then
		self.updateTimer:destroy()
		self.updateTimer = nil
	end
	
	self.clientDebugStats = nil
	self.serverDebugStats = nil
	self.serverNetworkStats = nil
	self.playerPosServer = nil
	self.fpsTable = nil
	self.allElementsTableClient = nil
	self.allElementsTableServer = nil
	self.lostPacketsTableClient = nil
	self.lostPacketsTableServer = nil
	self.resendPacketsTableClient = nil
	self.resendPacketsTableServer = nil

	removeDebugHook("preEvent", self.m_OnPreEvent)
	removeDebugHook("preFunction", self.m_OnPreFunction)
	
	mainOutput("DebugClassC was deleted.")
end