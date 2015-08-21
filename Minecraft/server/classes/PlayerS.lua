--[[
	Name: Minecraft
	Filename: PlayerS.lua
	Authors: Sam@ke
--]]


PlayerS = {}

function PlayerS:constructor(parent, player, id)
	mainOutput("PlayerS " .. id .. " was loaded.")
	
	self.playerManager = parent
	self.player = player
	self.id = id
	self.slots = {}
	self.slots[1] = {item = "stoneBlock", count = 999}
	self.slots[2] = {item = "dirtBlock", count = 999}
	self.slots[3] = {item = "grassBlock", count = 999}
	self.slots[4] = {item = "sandBlock", count = 999}
	
	self.currentSlot = 1
	
	self.m_PlaceBlock = bind(self.placeBlock, self)
	addEvent("onClientPlaceBlock", true)
	addEventHandler("onClientPlaceBlock", root, self.m_PlaceBlock)
	
	self.m_DeleteBlock = bind(self.deleteBlock, self)
	addEvent("onClientDeleteBlock", true)
	addEventHandler("onClientDeleteBlock", root, self.m_DeleteBlock)
	
	self.m_ResetAnimation = bind(self.resetAnimation, self)
	addEvent("onClientResetAnimation", true)
	addEventHandler("onClientResetAnimation", root, self.m_ResetAnimation)
	
	self.m_OnPlayerSwitchSlot = bind(self.onPlayerSwitchSlot, self)
	addEvent("onPlayerSwitchSlot", true)
	addEventHandler("onPlayerSwitchSlot", root, self.m_OnPlayerSwitchSlot)
end


function PlayerS:placeBlock(player, x, y, z)
	if (isElement(player)) and (player == self.player) and (x) and (y) and (z) then
		self.player:setAnimation()
		self.player:setAnimation("CASINO", "Slot_in")
		
		triggerEvent("onBlockCreate", root, self.player, self.slots[self.currentSlot].item, x, y, z)
	end
end


function PlayerS:deleteBlock(player, id)
	if (isElement(player)) and (player == self.player) and (id) then
		self.player:setAnimation()
		self.player:setAnimation("CASINO", "Slot_in")
		
		triggerEvent("onBlockDelete", root, id)
	end
end


function PlayerS:resetAnimation(player)
	if (isElement(player)) and (player == self.player)then
		self.player:setAnimation()
	end
end


function PlayerS:onPlayerSwitchSlot(player, slot)
	if (isElement(player)) and (player == self.player)then
		if (slot) then
			if (self.slots[slot]) then
				self.currentSlot = slot
			end
		end
	end
end


function PlayerS:destructor()
	removeEventHandler("onClientPlaceBlock", root, self.m_PlaceBlock)
	removeEventHandler("onClientDeleteBlock", root, self.m_DeleteBlock)
	removeEventHandler("onClientResetAnimation", root, self.m_ResetAnimation)
	removeEventHandler("onPlayerSwitchSlot", root, self.m_OnPlayerSwitchSlot)

	mainOutput("PlayerS " .. self.id .. " was deleted.")
end