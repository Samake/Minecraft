--[[
	Name: Minecraft
	Filename: IconHandlerC.lua
	Authors: Sam@ke
--]]


IconHandlerC = {}

function IconHandlerC:constructor(parent)
	mainOutput("IconHandlerC was loaded.")
	
	self.mainClass = parent
	self.icons = {}
	
	self.icons["stoneBlock"] = dxCreateTexture("res/icons/stoneBlockIcon.png")
	self.icons["dirtBlock"] = dxCreateTexture("res/icons/dirtBlockIcon.png")
	self.icons["grassBlock"] = dxCreateTexture("res/icons/grassBlockIcon.png")
	self.icons["sandBlock"] = dxCreateTexture("res/icons/sandBlockIcon.png")
	self.icons["glassWhiteBlock"] = dxCreateTexture("res/icons/glassWhiteBlockIcon.png")
	self.icons["doorWood"] = dxCreateTexture("res/icons/doorWoodIcon.png")
	self.icons["sapplingOak"] = dxCreateTexture("res/icons/saplingOAKIcon.png")
end


function IconHandlerC:destructor()
	for index, texture in pairs(self.icons) do
		if (texture) then
			texture:destroy()
			texture = nil
		end
	end
	
	mainOutput("IconHandlerC was deleted.")
end