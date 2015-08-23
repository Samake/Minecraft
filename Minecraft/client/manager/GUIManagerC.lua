--[[
	Name: Minecraft
	Filename: GUIManagerC.lua
	Authors: Sam@ke
--]]


GUIManagerC = {}

function GUIManagerC:constructor(parent)
	mainOutput("GUIManagerC was loaded.")
	
	self.mainClass = parent


end


function GUIManagerC:destructor()
	
	mainOutput("GUIManagerC was deleted.")
end