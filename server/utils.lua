--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

-- Chat

function sendMessage(source, text, customName)
	if source > 0 then
		local name = (customName ~= nil) and customName or "FireScript"
		TriggerClientEvent('fireClient:notify', source, ("~r~%s~s~ %s"):format(name, text))
	else
		print(("[FireScript v%s] %s"):format(Version, text))
	end
end

-- Table functions

function highestIndex(t, fireIndex)
	if not t then
		return
	end
	t = fireIndex ~= nil and t[fireIndex] or t
	if not t then
		return 0, 0
	end
	local index = 0
	local count = 0

	-- Use pairs and filter numeric keys: ipairs stops at the first gap,
	-- which caused index reuse once a flame in the middle was extinguished.
	for k, v in pairs(t) do
		if type(k) == "number" then
			count = count + 1
			if k > index then
				index = k
			end
		end
	end

	return index, count
end

function table.length(t)
	if not t or type(t) ~= "table" then
		return
	end

	local count = 0

	for k, v in pairs(t) do count = count + 1 end

	return count
end

function table.random(t)
	if not t or type(t) ~= "table" or next(t) == nil then
		return false
	end

	local randomPosition = math.random(1, table.length(t))
	local currentPosition = 0
	local randomKey = nil

	for k, v in pairs(t) do -- Select a random registered fire
		currentPosition = currentPosition + 1

		if currentPosition == randomPosition then
			randomKey = k
			break
		end
	end

	return randomKey, t[randomKey]
end

-- JSON config

function saveData(data, keyword)
	if type(keyword) ~= "string" then
		return
	end
	SaveResourceFile(GetCurrentResourceName(), keyword .. ".json", json.encode(data), -1)
end

function loadData(keyword)
	local fileContents = LoadResourceFile(GetCurrentResourceName(), keyword .. ".json")
	return fileContents and json.decode(fileContents) or nil
end