--[[
	Name: Minecraft
	Filename: BlockCursorC.lua
	Authors: Sam@ke
--]]


BlockCursorC = {}

function BlockCursorC:constructor(parent)
	mainOutput("BlockCursorC was loaded.")
	
	self.mainClass = parent

	self.x = nil
	self.y = nil
	self.z = nil
	self.blockOffset = 0.5
	self.cursorColor = tocolor(0, 0, 0, 255)
	self.cursorSize = 1.2
	
	self.m_OnCursorCoordsChanged = bind(self.onCursorCoordsChanged, self)
	addEvent("onCursorCoordsChanged", true)
	addEventHandler("onCursorCoordsChanged", root, self.m_OnCursorCoordsChanged)

end


function BlockCursorC:update()
	if (self.x) and (self.y) and (self.z) then
		local topFrontLeft = {x = self.x - self.blockOffset, y = self.y + self.blockOffset, z = self.z + self.blockOffset}
		local topFrontRight = {x = self.x + self.blockOffset, y = self.y + self.blockOffset, z = self.z + self.blockOffset}
		local topBackLeft = {x = self.x - self.blockOffset, y = self.y - self.blockOffset, z = self.z + self.blockOffset}
		local topBackRight = {x = self.x + self.blockOffset, y = self.y - self.blockOffset, z = self.z + self.blockOffset}
		
		local bottomFrontLeft = {x = self.x - self.blockOffset, y = self.y + self.blockOffset, z = self.z - self.blockOffset}
		local bottomFrontRight = {x = self.x + self.blockOffset, y = self.y + self.blockOffset, z = self.z - self.blockOffset}
		local bottomBackLeft = {x = self.x - self.blockOffset, y = self.y - self.blockOffset, z = self.z - self.blockOffset}
		local bottomBackRight = {x = self.x + self.blockOffset, y = self.y - self.blockOffset, z = self.z - self.blockOffset}
		
		-- // top square // --
		dxDrawLine3D(topFrontLeft.x, topFrontLeft.y, topFrontLeft.z, topFrontRight.x, topFrontRight.y, topFrontRight.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topFrontRight.x, topFrontRight.y, topFrontRight.z, topBackRight.x, topBackRight.y, topBackRight.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topBackRight.x, topBackRight.y, topBackRight.z, topBackLeft.x, topBackLeft.y, topBackLeft.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topBackLeft.x, topBackLeft.y, topBackLeft.z, topFrontLeft.x, topFrontLeft.y, topFrontLeft.z, self.cursorColor, self.cursorSize)
		
		-- // bottom square // --
		dxDrawLine3D(bottomFrontLeft.x, bottomFrontLeft.y, bottomFrontLeft.z, bottomFrontRight.x, bottomFrontRight.y, bottomFrontRight.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(bottomFrontRight.x, bottomFrontRight.y, bottomFrontRight.z, bottomBackRight.x, bottomBackRight.y, bottomBackRight.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(bottomBackRight.x, bottomBackRight.y, bottomBackRight.z, bottomBackLeft.x, bottomBackLeft.y, bottomBackLeft.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(bottomBackLeft.x, bottomBackLeft.y, bottomBackLeft.z, bottomFrontLeft.x, bottomFrontLeft.y, bottomFrontLeft.z, self.cursorColor, self.cursorSize)
		
		-- // body // --
		dxDrawLine3D(topFrontLeft.x, topFrontLeft.y, topFrontLeft.z, bottomFrontLeft.x, bottomFrontLeft.y, bottomFrontLeft.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topFrontRight.x, topFrontRight.y, topFrontRight.z, bottomFrontRight.x, bottomFrontRight.y, bottomFrontRight.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topBackLeft.x, topBackLeft.y, topBackLeft.z, bottomBackLeft.x, bottomBackLeft.y, bottomBackLeft.z, self.cursorColor, self.cursorSize)
		dxDrawLine3D(topBackRight.x, topBackRight.y, topBackRight.z, bottomBackRight.x, bottomBackRight.y, bottomBackRight.z, self.cursorColor, self.cursorSize)
	end
end


function BlockCursorC:onCursorCoordsChanged(x, y, z)
	if (x) and (y) and (z) then
		self.x = x
		self.y = y
		self.z = z
	end
end


function BlockCursorC:destructor()
	removeEventHandler("onCursorCoordsChanged", root, self.m_OnCursorCoordsChanged)
	
	mainOutput("BlockCursorC was deleted.")
end