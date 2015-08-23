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
	
	self.m_OnPlayerSwitchSlot = bind(self.onPlayerSwitchSlot, self)
	addEvent("onPlayerSwitchSlot", true)
	addEventHandler("onPlayerSwitchSlot", root, self.m_OnPlayerSwitchSlot)
end


function GUIInventarSlotsC:update()
	if (self.inventarSlotsBG) and (self.inventarSlotsFrame) then
		local startX = (self.screenWidth * 0.5) - (self.guiWidth * 0.5)
		local startY = self.screenHeight - (self.inventarSlotSize + 10)
		
		-- // background layer // --
		dxDrawImage(startX, startY, self.guiWidth, self.inventarSlotSize, self.inventarSlotsBG)
		
		-- // icon layer // --
		
		-- // frame layer // --
		for i = 0, self.inventarSlots - 1, 1 do
			dxDrawImage(startX + self.inventarSlotSize * i, startY, self.inventarSlotSize, self.inventarSlotSize, self.inventarSlotsFrame)
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