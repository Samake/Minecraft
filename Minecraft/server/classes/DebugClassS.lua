--[[
	Name: Minecraft
	Filename: DebugClassS.lua
	Authors: Sam@ke
--]]


DebugClassS = {}

function DebugClassS:constructor(parent)
	mainOutput("DebugClassS was loaded.")
	
	self.mainClass = parent
	self.applicationName = "Minecraft"

	self.isDebug = "false"
	
	self.m_ToogleDebug = bind(self.toggleDebug, self)
	addEvent("enableDebugStats", true)
	addEventHandler("enableDebugStats", root, self.m_ToogleDebug)
end


function DebugClassS:update()


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


function DebugClassS:destructor()
	removeEventHandler("enableDebugStats", root, self.m_ToogleDebug)
	
	mainOutput("DebugClassS was deleted.")
end