--[[
	Name: Minecraft
	Filename: PlayerManagerS.lua
	Authors: Sam@ke
--]]


PlayerManagerS = {}

function PlayerManagerS:constructor(parent)
	mainOutput("PlayerManagerS was loaded.")
	
	self.mainClass = parent
	self.spawnPlaces = {}
	self.spawnPlaces[1] = {x = -3000, y = -3000, z = 7}
	self.spawnPlaces[2] = {x = -3010, y = -3000, z = 7}
	self.spawnPlaces[3] = {x = -3000, y = -3010, z = 7}
	self.spawnPlaces[4] = {x = -3020, y = -3000, z = 7}
	self.spawnPlaces[5] = {x = -3000, y = -3020, z = 7}

	self.players = {}
	self.fadeTime = 2000
	
	self.m_FadeIN = bind(self.fadeIN, self)
	self.m_OnPlayerSpawn = bind(self.onPlayerSpawn, self)
	addEventHandler("onPlayerSpawn", root, self.m_OnPlayerSpawn)
	
	self.m_OnPlayerWasted = bind(self.onPlayerWasted, self)
	addEventHandler("onPlayerWasted", root, self.m_OnPlayerWasted)
	
	self:init()
end


function PlayerManagerS:init()
	for index, player in pairs(getElementsByType("player")) do
        if (player) then
			fadeCamera(player, false, 0.1, 0, 0, 0)
			local id = self:getNextFreeId()
            self.players[id] = new(PlayerS, self, player, id)
        end
    end
	
	setTimer(self.m_FadeIN, self.fadeTime, 1)	
end


function PlayerManagerS:fadeIN()
	for index, player in pairs(getElementsByType("player")) do
        if (player) then
			local x, y, z = self:getRandomSpawn()
			spawnPlayer(player, -3000, -3000, 7)
			fadeCamera(player, true, 1.0, 255, 255, 255)
        end
    end
end


function PlayerManagerS:onPlayerWasted()
	fadeCamera(source, false, 0.1, 0, 0, 0)
	self:respawnPlayer(source)
end


function PlayerManagerS:respawnPlayer(player)
	if (player) then
		local x, y, z = self:getRandomSpawn()
		spawnPlayer(player, -3000, -3000, 7)
		fadeCamera(player, true, 1.0, 255, 255, 255)
	end
end


function PlayerManagerS:getRandomSpawn()
	local randomSpawn = math.random(1, #self.spawnPlaces)

	return self.spawnPlaces[randomSpawn].x, self.spawnPlaces[randomSpawn].y, self.spawnPlaces[randomSpawn].z
end


function PlayerManagerS:onPlayerSpawn()
	for index, playerInstance in pairs(self.players) do
        if (playerInstance) then
            if (playerInstance.player == source) then
				return
			end	
        end
    end
	
	local id = self:getNextFreeId()
    self.players[id] = new(PlayerS, self, source, id)
end


function PlayerManagerS:getNextFreeId()
    for index, playerInstance in pairs(self.players) do
        if (not playerInstance) then
            return index
        end
    end
	
    return #self.players + 1
end


function PlayerManagerS:clear()
	for index, playerInstance in pairs(self.players) do
        if (playerInstance) then
            delete(playerInstance)
			playerInstance = nil
        end
    end
end


function PlayerManagerS:destructor()
	removeEventHandler("onPlayerSpawn", root, self.m_OnPlayerSpawn)
	removeEventHandler("onPlayerWasted", root, self.m_OnPlayerWasted)

	self:clear()
	
	mainOutput("PlayerManagerS was deleted.")
end