--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

Dispatch = {
	_players = {},
	_firefighters = {},
	lastNumber = 0,
	expectingInfo = {},
	calls = {}
}

function Dispatch:create(text, coords)
	text = tostring(text)

	if not (text and coords) then
		return
	end

	self.lastNumber = self.lastNumber + 1
	self.calls[self.lastNumber] = coords

	for k, v in pairs(self._players) do
		sendMessage(k, text, ("Dispatch (#%s)"):format(self.lastNumber))
		TriggerClientEvent('fireClient:createDispatch', k, self.lastNumber, coords)
	end

	-- Safety net: if the fire was already put out before the call went
	-- through (dispatch is delayed), resolve the call right away.
	Citizen.SetTimeout(
		10000,
		function()
			self:clearResolved()
		end
	)
end

-- Removes the blip of every call that no longer has a fire burning nearby.
-- Invoked whenever a fire fully goes out.
function Dispatch:clearResolved()
	local radius = Config.Dispatch.clearBlipRadius or 150.0

	for number, coords in pairs(self.calls) do
		local burning = false

		for _, fire in pairs(Fire.active) do
			for k, flame in pairs(fire) do
				if type(k) == "number" and flame.c and #(flame.c - coords) < radius then
					burning = true
					break
				end
			end
			if burning then
				break
			end
		end

		if not burning then
			self.calls[number] = nil
			TriggerClientEvent('fireClient:clearDispatch', -1, number)
		end
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