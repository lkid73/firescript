--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

Dispatch = {
	_players = {},
	_firefighters = {},
	lastNumber = 0,
	expectingInfo = {}
}

function Dispatch:create(text, coords)
	text = tostring(text)

	if not (text and coords) then
		return
	end

	self.lastNumber = self.lastNumber + 1

	for k, v in pairs(self._players) do
		sendMessage(k, text, ("Dispatch (#%s)"):format(self.lastNumber))
		TriggerClientEvent('fireClient:createDispatch', k, self.lastNumber, coords)
	end
end

function Dispatch:subscribe(serverId, isFirefighter)
	serverId = tonumber(serverId)
	if not serverId then
		return
	end
	self._players[serverId] = true
	if isFirefighter then
		self:addFirefighter(serverId)
	end
end

function Dispatch:unsubscribe(serverId)
	serverId = tonumber(serverId)
	if not serverId then
		return
	end
	self._players[serverId] = nil
	self:removeFirefighter(serverId)
end

function Dispatch:addFirefighter(serverId)
	serverId = tonumber(serverId)
	if serverId then
		self._firefighters[serverId] = true
	end
end

function Dispatch:removeFirefighter(serverId)
	serverId = tonumber(serverId)
	if serverId then
		self._firefighters[serverId] = nil
	end
end

function Dispatch:firefighters()
	return table.length(self._firefighters)
end

function Dispatch:players()
	return table.length(self._players)
end

function Dispatch:getRandomPlayer()
	if not next(self._players) then
		-- next() would return the array index (1), not a server ID
		local players = GetPlayers()
		if #players == 0 then
			return false
		end
		return tonumber(players[math.random(#players)])
	end
	return table.random(self._players)
end