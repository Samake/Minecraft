--[[
	Name: Minecraft
	Filename: GUIManagerC.lua
	Authors: Sam@ke
--]]


GUIManagerC = {}

function GUIManagerC:constructor(parent)
	mainOutput("GUIManagerC was loaded.")
	
	self.mainClass = parent
	
	if (not self.iconHandler) then
		self.iconHandler = new(IconHandlerC, self)
	end

	if (not self.guiInventarSlots) then
		self.guiInventarSlots = new(GUIInventarSlotsC, self)
	end

end


function GUIManagerC:update()
	if (self.guiInventarSlots) then
		self.guiInventarSlots:update()
	end
end


function GUIManagerC:getItemIcons()
	if (self.iconHandler) then
		return self.iconHandler.icons
	end
end


function GUIManagerC:destructor()

	if (self.iconHandler) then
		delete(self.iconHandler)
		self.iconHandler = nil
	end

	if (self.guiInventarSlots) then
		delete(self.guiInventarSlots)
		self.guiInventarSlots = nil
	end
	
	mainOutput("GUIManagerC was deleted.")
end