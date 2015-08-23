--[[
	Name: Minecraft
	Filename: ActionHandlerC.lua
	Authors: Sam@ke
--]]


ActionHandlerC = {}

function ActionHandlerC:constructor(parent)
	mainOutput("ActionHandlerC was loaded.")
	
	self.mainClass = parent
	self.player = getLocalPlayer()
	self.blockPlaceButton = "mouse2"
	self.blockDeleteButton = "mouse1"
	self.actionDistance = 20
	
	self.m_PlaceBlock = bind(self.placeBlock, self)
	bindKey(self.blockPlaceButton, "both", self.m_PlaceBlock)
	
	self.m_DeleteBlock = bind(self.deleteBlock, self)
	bindKey(self.blockDeleteButton, "both", self.m_DeleteBlock)

end


function ActionHandlerC:update()
	self.playerPos = self.player:getPosition()
	
	self.tx, self.ty, self.tz = self:getCursorCoords()
	
	triggerEvent("onCursorCoordsChanged", root, self.tx, self.ty, self.tz)
	
	if (self.mainClass.isDebug == "true") then
		if (self.tx) and (self.ty) and (self.tz) then
			dxDrawLine3D(self.tx, self.ty, self.tz - 0.5, self.tx, self.ty, self.tz + 0.5, tocolor(0, 255, 0, 200), 3)
			dxDrawLine3D(self.tx, self.ty - 0.5, self.tz, self.tx, self.ty + 0.5, self.tz, tocolor(255, 255, 0, 200), 3)
			dxDrawLine3D(self.tx - 0.5, self.ty, self.tz, self.tx + 0.5, self.ty, self.tz, tocolor(0, 0, 255, 200), 3)
		end
	end
end


function ActionHandlerC:getCursorCoords()
    local x, y, z, lx, ly, lz = getCameraMatrix()
    local fromX, fromY, fromZ = self.playerPos.x, self.playerPos.y, self.playerPos.z
    local toX = fromX + (lx - x) * self.actionDistance
    local toY = fromY + (ly - y) * self.actionDistance
    local toZ = fromZ + (lz - z) * self.actionDistance
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(fromX, fromY, fromZ + 1, toX, toY, toZ, true, true, false, true, true, true, true, true, self.player, true)
	
	if (hit) then
		if (hitElement) then
			local type = hitElement:getData("OBJECTTYPE")
			local id = hitElement:getData("ID")
			
			if (type) then
				if (type == "MCBLOCK") or (type == "MCDOOR") then
					self.hitElement =  {element = hitElement, id = id, type = type}
				end
			end
		else
			self.hitElement = nil
		end
		
		if (hitX) and (hitY) and (hitZ) then
			return math.floor(hitX), math.floor(hitY), math.floor(hitZ) + 0.5
		end
	else
		self.hitElement = nil
	end
	
	return nil, nil, nil
end


function ActionHandlerC:placeBlock(button, state)
	if (state == "down") then
		if (self.tx) and (self.ty) and (self.tz) then
			if (self.hitElement) then
				if (isElement(self.hitElement.element)) then
					if (self.hitElement.type == "MCDOOR") then
						triggerServerEvent("onClientDoorAction", root, self.hitElement.element)
						return
					end
				end
			end
				
			triggerServerEvent("onClientPlaceBlock", root, self.player, self.tx, self.ty, self.tz)
		end
	elseif (state == "up") then
		triggerServerEvent("onClientResetAnimation", root, self.player)
	end
end


function ActionHandlerC:deleteBlock(button, state)
	if (state == "down") then
		if (self.hitElement) then
			if (isElement(self.hitElement.element)) then
				if (self.hitElement.id) then
					triggerServerEvent("onClientDeleteBlock", root, self.player, self.hitElement.id)
				end
			end
		end
	elseif (state == "up") then
		triggerServerEvent("onClientResetAnimation", root, self.player)
	end
end


function ActionHandlerC:destructor()
	unbindKey(self.blockPlaceButton, "both", self.m_PlaceBlock)
	unbindKey(self.blockDeleteButton, "both", self.m_DeleteBlock)
	
	mainOutput("ActionHandlerC was deleted.")
end