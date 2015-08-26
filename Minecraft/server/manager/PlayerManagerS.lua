--[[
	Name: Minecraft
	Filename: PlayerManagerS.lua
	Authors: Sam@ke
--]]


PlayerManagerS = {}

function PlayerManagerS:constructor(parent)
	mainOutput("PlayerManagerS was loaded.")
	
	self.mainClass = parent
	self.updateInterval = 500
	
	self.spawnPlaces = {}
	self.spawnPlaces[1] = {x = -3000, y = -3000, z = 7}
	self.spawnPlaces[2] = {x = -3010, y = -3000, z = 7}
	self.spawnPlaces[3] = {x = -3000, y = -3010, z = 7}
	self.spawnPlaces[4] = {x = -3020, y = -3000, z = 7}
	self.spawnPlaces[5] = {x = -3000, y = -3020, z = 7}

	self.players = {}
	self.spawnTime = 2000
	
	self.m_SpawnPlayer = bind(self.spawnPlayer, self)
	self.m_SpawnAllPlayers = bind(self.spawnAllPlayers, self)
	
	self.m_OnPlayerJoin = bind(self.onPlayerJoin, self)
	addEventHandler("onPlayerJoin", root, self.m_OnPlayerJoin)
	
	self.m_OnPlayerSpawn = bind(self.onPlayerSpawn, self)
	addEventHandler("onPlayerSpawn", root, self.m_OnPlayerSpawn)
	
	self.m_OnPlayerWasted = bind(self.onPlayerWasted, self)
	addEventHandler("onPlayerWasted", root, self.m_OnPlayerWasted)
	
	self.m_OnPlayerQuit = bind(self.onPlayerQuit, self)
	addEventHandler("onPlayerQuit", root, self.m_OnPlayerQuit)
	
	self:init()
	
	self.m_Update = bind(self.update, self)
	self.updateTimer = setTimer(self.m_Update, self.updateInterval, 0)
end


function PlayerManagerS:update()
	for index, playerInstance in pairs(self.players) do
        if (playerInstance) then
            playerInstance:update()
        end
    end
end


function PlayerManagerS:init()
	for index, player in pairs(getElementsByType("player")) do
        if (player) then
			fadeCamera(player, false, 0.1, 0, 0, 0)
			local id = self:getNextFreeId()
            self.players[id] = new(PlayerS, self, player, id)
        end
    end
	
	setTimer(self.m_SpawnAllPlayers, self.spawnTime, 1)	
end


function PlayerManagerS:onPlayerJoin()
	local player = source
	
	for index, playerInstance in pairs(self.players) do
        if (playerInstance) then
            if (playerInstance.player == player) then
				return
			end	
        end
    end
	
	local id = self:getNextFreeId()
    self.players[id] = new(PlayerS, self, player, id)
	
	setTimer(self.m_SpawnPlayer, self.spawnTime, 1, player)	
end


function PlayerManagerS:onPlayerSpawn()
	fadeCamera(source, true, 1.0, 255, 255, 255)
end


function PlayerManagerS:onPlayerWasted()
	local player = source
	fadeCamera(player, false, 0.1, 0, 0, 0)
	setTimer(self.m_SpawnPlayer, self.spawnTime, 1, player)	
end


function PlayerManagerS:onPlayerQuit()
	local player = source
	
	self:removePlayerInstance(player)
end


function PlayerManagerS:spawnAllPlayers()
	for index, player in pairs(getElementsByType("player")) do
        if (player) then
			self:spawnPlayer(player)
        end
    end
end


function PlayerManagerS:spawnPlayer(player)
	if (player) then
		local x, y, z = self:getRandomSpawn()
		spawnPlayer(player, -3000, -3000, 7)
	end
end


function PlayerManagerS:removePlayerInstance(player)
	if (player) then
		for index, playerInstance in pairs(self.players) do
			if (playerInstance) then
				if (playerInstance.player == player) then
					delete(playerInstance)
					playerInstance = nil
				end
			end
		end
	end
end


function PlayerManagerS:removePlayerInstancebyID(id)
	if (id) then
		if (self.players[id]) then
			delete(self.players[id])
			self.players[id] = nil
		end
    end
end


function PlayerManagerS:getRandomSpawn()
	local randomSpawn = math.random(1, #self.spawnPlaces)

	return self.spawnPlaces[randomSpawn].x, self.spawnPlaces[randomSpawn].y, self.spawnPlaces[randomSpawn].z
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
	removeEventHandler("onPlayerJoin", root, self.m_OnPlayerJoin)
	removeEventHandler("onPlayerSpawn", root, self.m_OnPlayerSpawn)
	removeEventHandler("onPlayerWasted", root, self.m_OnPlayerWasted)
	removeEventHandler("onPlayerQuit", root, self.m_OnPlayerQuit)

	if (self.updateTimer) then
		self.updateTimer:destroy()
		self.updateTimer = nil
	end
	
	self:clear()
	
	mainOutput("PlayerManagerS was deleted.")
end