--[[
	Name: Minecraft
	Filename: InventoryHandlerC.lua
	Authors: Sam@ke
--]]


InventoryHandlerC = {}

function InventoryHandlerC:constructor(parent)
	mainOutput("InventoryHandlerC was loaded.")
	
	self.mainClass = parent
	self.player = getLocalPlayer()
	
	self.m_OnClientCharacter = bind(self.onClientCharacter, self)
	addEventHandler("onClientCharacter", root, self.m_OnClientCharacter)
end


function InventoryHandlerC:onClientCharacter(character)
	if (character == "1") or (character == "2") or (character == "3") or (character == "4") or (character == "5") or (character == "6") or (character == "7") or (character == "8") or (character == "9") then
		triggerServerEvent("onPlayerSwitchSlot", root, self.player, tonumber(character))
		mainOutput("Slot choosed: " .. character)
	end
end


function InventoryHandlerC:destructor()
	removeEventHandler("onClientCharacter", root, self.m_OnClientCharacter)
	
	mainOutput("InventoryHandlerC was deleted.")
end