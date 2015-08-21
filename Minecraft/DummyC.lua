--[[
	Name: MainClassS
	Filename: MainClassC.lua
	Authors: Sam@ke
--]]

MainClassC = {}

function MainClassC:constructor(parent)
	mainOutput("MainClassC was loaded.")
	
	self.mainClass = parent

end


function MainClassC:destructor()
	
	
	mainOutput("MainClassC was deleted.")
end