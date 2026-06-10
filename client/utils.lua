--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

-- Notifications (native GTA feed above the minimap)

function showNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(false, true)
end

function sendMessage(text)
	showNotification(("~r~FireScript~s~ %s"):format(text))
end

function DrawText3D(coords, text)
	local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
	if not onScreen then
		return
	end

	local dist = #(GetGameplayCamCoords() - coords)
	local scale = (1 / dist) * 2 * (1 / GetGameplayCamFov()) * 100

	SetTextScale(0.0, 0.55 * scale)
	SetTextFont(0)
	SetTextCentre(true)
	SetTextColour(255, 255, 255, 215)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

-- Table functions

function countElements(t)
	local count = 0
	if type(t) == "table" then
		for k, v in pairs(t) do
			count = count + 1
		end
	end
	return count
end

-- Sync lock

syncInProgress = false

-- Serializes fire state mutations. pcall guarantees the lock is released
-- even if the protected code errors; a stuck flag would otherwise
-- permanently deadlock every fire event handler on this client.
function withSyncLock(fn)
	while syncInProgress do
		Citizen.Wait(10)
	end
	syncInProgress = true
	local ok, err = pcall(fn)
	syncInProgress = false
	if not ok then
		print(("[FireScript] Error in synchronized section: %s"):format(err))
	end
end