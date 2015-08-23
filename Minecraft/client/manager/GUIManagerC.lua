--[[
	Name: Minecraft
	Filename: GUIManagerC.lua
	Authors: Sam@ke
--]]


GUIManagerC = {}

function GUIManagerC:constructor(parent)
	mainOutput("GUIManagerC was loaded.")
	
	self.mainClass = parent

	if (not self.guiInventarSlots) then
		self.guiInventarSlots = new(GUIInventarSlotsC, self)
	end

end


function GUIManagerC:update()
	if (self.guiInventarSlots) then
		self.guiInventarSlots:update()
	end
end


function GUIManagerC:destructor()

	if (self.guiInventarSlots) then
		delete(self.guiInventarSlots)
		self.guiInventarSlots = nil
	end
	
	mainOutput("GUIManagerC was deleted.")
end