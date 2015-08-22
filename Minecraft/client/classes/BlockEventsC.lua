--[[
	Name: Minecraft
	Filename: BlockEventsC.lua
	Authors: Sam@ke
--]]


BlockEventsC = {}

function BlockEventsC:constructor(parent)
	mainOutput("BlockEventsC was loaded.")
	
	self.mainClass = parent
	self.soundDistance = 100
	
	self.m_OnBlockDestroyed= bind(self.onBlockDestroyed, self)
	addEvent("onBlockDestroyed", true)
	addEventHandler("onBlockDestroyed", root, self.m_OnBlockDestroyed)

end


function BlockEventsC:onBlockDestroyed(x, y, z, r, g, b, a, scale, count)
	if (x) and (y) and (z) and (r) and (g) and (b) then
		
		fxAddGlass(x, y, z, r, g, b, a, scale, count)
		-- play destroy sound here!!!
	end
end


function BlockEventsC:destructor()
	removeEventHandler("onBlockDestroyed", root, self.m_OnBlockDestroyed)
	
	mainOutput("BlockEventsC was deleted.")
end