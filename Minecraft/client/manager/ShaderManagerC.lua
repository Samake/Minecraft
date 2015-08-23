--[[
	Name: Minecraft
	Filename: ShaderManagerC.lua
	Authors: Sam@ke
--]]


ShaderManagerC = {}

function ShaderManagerC:constructor(parent)
	mainOutput("ShaderManagerC was loaded.")
	
	self.mainClass = parent


end


function ShaderManagerC:destructor()
	
	mainOutput("ShaderManagerC was deleted.")
end