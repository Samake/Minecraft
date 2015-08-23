--[[
	Name: Minecraft
	Filename: GUIInventarSlotsC.lua
	Authors: Sam@ke
--]]


GUIInventarSlotsC = {}

function GUIInventarSlotsC:constructor(parent)
	mainOutput("GUIInventarSlotsC was loaded.")
	
	self.guiManager = parent
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	self.postGUI = false
	
	self.inventarSlotsBG = dxCreateTexture("res/textures/invSlotsBG.png")
	self.inventarSlotsFrame = dxCreateTexture("res/textures/invSlotsFrame.png")
	
	self.inventarSlots = 9
	self.inventarSlotSize = 48
	self.guiWidth = self.inventarSlotSize * self.inventarSlots
	
	self.selectedSlot = 1
	self.selectedSlotColor = tocolor(200, 200, 200, 200)
	self.selectedSlotWidth = 3

	if (not self.inventarSlotsBG) or (not self.inventarSlotsFrame) then
		mainOutput("FAIL // GUI textures cant be loaded. Please use ´/debugscript 3´ for further details")
		return
	end
	
	self.playerStats = nil
	self.playerSlots = nil
	
	self.m_OnPlayerSwitchSlot = bind(self.onPlayerSwitchSlot, self)
	addEvent("onPlayerSwitchSlot", true)
	addEventHandler("onPlayerSwitchSlot", root, self.m_OnPlayerSwitchSlot)
	
	self.m_UpdatePlayerStats = bind(self.updatePlayerStats, self)
	addEvent("updatePlayerStats", true)
	addEventHandler("updatePlayerStats", root, self.m_UpdatePlayerStats)
end


function GUIInventarSlotsC:updatePlayerStats(playerStats)
	if (playerStats) then
		self.playerStats = playerStats
		self.playerSlots = playerStats.slots
	end
	
	self.iconList = self.guiManager:getItemIcons()
end


function GUIInventarSlotsC:update()
	if (self.inventarSlotsBG) and (self.inventarSlotsFrame) then
		local startX = (self.screenWidth * 0.5) - (self.guiWidth * 0.5)
		local startY = self.screenHeight - (self.inventarSlotSize + 10)
		
		-- // background layer // --
		dxDrawImage(startX, startY, self.guiWidth, self.inventarSlotSize, self.inventarSlotsBG)
		
		-- // icon layer // --
		if (self.iconList) then
			if (self.playerStats) and (self.playerSlots) then
				for i = 1, self.inventarSlots, 1 do
					if (self.playerSlots[i]) then
						if (self.playerSlots[i].item) then
							local slotItem = self.playerSlots[i].item
							local iconTex = self.iconList[self.playerSlots[i].item]
							local iconPos = {x = (startX + self.inventarSlotSize * (i - 1)) + 6, y = startY + 6}
							
							dxDrawImage(iconPos.x, iconPos.y, self.inventarSlotSize - 12, self.inventarSlotSize - 12, iconTex)
						end
					end
				end
			end
		end
		
		-- // frame layer // --
		for j = 0, self.inventarSlots - 1, 1 do
			dxDrawImage(startX + self.inventarSlotSize * j, startY, self.inventarSlotSize, self.inventarSlotSize, self.inventarSlotsFrame)
		end
		
		-- // selected slot layer // --
		local topLeft = {x = startX + self.inventarSlotSize * (self.selectedSlot - 1), y = startY}
		local topRight = {x = (startX + self.inventarSlotSize * (self.selectedSlot - 1)) + self.inventarSlotSize, y = startY}
		local bottomLeft = {x = startX + self.inventarSlotSize * (self.selectedSlot - 1), y = startY + self.inventarSlotSize}
		local bottomRight = {x = (startX + self.inventarSlotSize * (self.selectedSlot - 1)) + self.inventarSlotSize, y = startY + self.inventarSlotSize}
		
		dxDrawLine(topLeft.x, topLeft.y, topRight.x, topRight.y, self.selectedSlotColor, self.selectedSlotWidth, self.postGUI)
		dxDrawLine(topRight.x, topRight.y, bottomRight.x, bottomRight.y, self.selectedSlotColor, self.selectedSlotWidth, self.postGUI)
		dxDrawLine(bottomRight.x, bottomRight.y, bottomLeft.x, bottomLeft.y, self.selectedSlotColor, self.selectedSlotWidth, self.postGUI)
		dxDrawLine(bottomLeft.x, bottomLeft.y, topLeft.x, topLeft.y, self.selectedSlotColor, self.selectedSlotWidth, self.postGUI)
		
	end
end


function GUIInventarSlotsC:onPlayerSwitchSlot(slot)
	if (slot) then
		self.selectedSlot = slot
	end
end


function GUIInventarSlotsC:destructor()

	removeEventHandler("onPlayerSwitchSlot", root, self.m_OnPlayerSwitchSlot)
	removeEventHandler("updatePlayerStats", root, self.m_UpdatePlayerStats)

	if (self.inventarSlotsFrame) then
		self.inventarSlotsFrame:destroy()
		self.inventarSlotsFrame = nil
	end
	
	if (self.inventarSlotsFrame) then
		self.inventarSlotsFrame:destroy()
		self.inventarSlotsFrame = nil
	end
	
	mainOutput("GUIInventarSlotsC was deleted.")
end