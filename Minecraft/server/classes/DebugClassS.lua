--[[
	Name: Minecraft
	Filename: DebugClassS.lua
	Authors: Sam@ke
--]]


DebugClassS = {}

function DebugClassS:constructor(parent)
	mainOutput("DebugClassS was loaded.")
	
	self.mainClass = parent
	self.applicationName = getResourceName(getThisResource())
	
	self.updateInterval = 500
	
	self.m_Update = bind(self.update, self)
	self.updateTimer = setTimer(self.m_Update, self.updateInterval, 0)

	self.isDebug = "false"
	
	self.serverDebugStats = {}
	self.serverDebugStats.luaTimings = {arg1 = "-", arg2 = "-", arg3 = "-"}
	self.serverDebugStats.luaMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-"}
	self.serverDebugStats.libMemory = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-",}
	self.serverDebugStats.packetUsage = {arg1 = "-", arg2 = "-", arg3 = "-", arg4 = "-", arg5 = "-", arg6 = "-", arg7 = "-"}
	self.serverDebugStats.elements = {players = "-", peds = "-", vehicles = "-", objects = "-", timers = "-", shaders = "-", textures = "-", all = "-"}
	
	self.m_ToogleDebug = bind(self.toggleDebug, self)
	addEvent("enableDebugStats", true)
	addEventHandler("enableDebugStats", root, self.m_ToogleDebug)
end


function DebugClassS:update()
	if (self.isDebug == "true") then
		local arg1, arg2, arg3 = self:getLUATimings()
		self.serverDebugStats.luaTimings = {arg1 = arg1, arg2 = arg2, arg3 = arg3}
		
		local arg1, arg2, arg3, arg4 = self:getLUAMemory()
		self.serverDebugStats.luaMemory = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4}
		
		local arg1, arg2, arg3, arg4 = self:getLibMemory()
		self.serverDebugStats.libMemory = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4}
		
		local arg1, arg2, arg3, arg4 = self:getPacketUsage()
		self.serverDebugStats.packetUsage = {arg1 = arg1, arg2 = arg2, arg3 = arg3, arg4 = arg4, arg5 = arg5, arg6 = arg6, arg7 = arg7}
		
		self.serverDebugStats.elements = {	players = #getElementsByType("player"), 
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
		
		triggerClientEvent("receiveServerDebugStats", root, self.serverDebugStats)
		
		self:sendNetworkStats()
		self:sendPlayerStats()
	end
end


function DebugClassS:toggleDebug(isDebug)
	if (isDebug) then
		self.isDebug = isDebug
	end
	
	mainOutput("Debug Server enabled: " .. self.isDebug)
end


function DebugClassS:getLUATimings()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lua timing", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3]
	end
end


function DebugClassS:getLUAMemory()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lua memory", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4]
	end
end


function DebugClassS:getLibMemory()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Lib memory", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4]
	end
end


function DebugClassS:getPacketUsage()
	local luaTimingsColumns, luaTimingsRows = getPerformanceStats("Packet usage", "5", self.applicationName)
	
	for i, row in ipairs(luaTimingsRows) do
		local results = split(table.concat(row, ";"), ";")
		return results[1], results[2], results[3], results[4], results[5], results[6], results[7]
	end
end


function DebugClassS:sendNetworkStats()
	for index, player in pairs(getElementsByType("player")) do
		if (player) then
			local netWorkstats = getNetworkStats(player)
			triggerClientEvent(player, "receiveServerNetworkStats", player, netWorkstats)
		end
	end
end


function DebugClassS:sendPlayerStats()
	for index, player in pairs(getElementsByType("player")) do
		if (player) then
			local playerPos = player:getPosition()
			local posTable = {x = playerPos.x, y = playerPos.y, z = playerPos.z}
			triggerClientEvent(player, "receivePlayerStats", player, posTable)
		end
	end
end


function DebugClassS:destructor()
	removeEventHandler("enableDebugStats", root, self.m_ToogleDebug)
	
	self.serverDebugStats = nil
	
	if (self.updateTimer) then
		self.updateTimer:destroy()
		self.updateTimer = nil
	end
	
	mainOutput("DebugClassS was deleted.")
end