--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

-- Explosion-started fires: configured explosion types have a chance to
-- ignite a spreading fire at the blast site, with a dispatch call like
-- any other fire. See Config.ExplosionFires.

local lastExplosionFire = 0

-- Vehicle/entity explosions often report no usable world position;
-- when the event carries an entity, prefer its actual coordinates.
local function getExplosionCoords(ev)
	local coords = vector3(ev.posX, ev.posY, ev.posZ)

	if ev.f210 and ev.f210 ~= 0 then
		local entity = NetworkGetEntityFromNetworkId(ev.f210)
		if entity and entity ~= 0 and DoesEntityExist(entity) then
			local entityCoords = GetEntityCoords(entity)
			if #(entityCoords.xy) > 1.0 then
				coords = entityCoords
			end
		end
	end

	return coords
end

local function isNearActiveFire(coords, radius)
	for _, fire in pairs(Fire.active) do
		for k, flame in pairs(fire) do
			if type(k) == "number" and flame.c and #(flame.c - coords) < radius then
				return true
			end
		end
	end
	return false
end

AddEventHandler(
	'explosionEvent',
	function(sender, ev)
		local cfg = Config.ExplosionFires

		if not (cfg and cfg.enabled) then
			return
		end

		local trigger = cfg.triggers[ev.explosionType]
		if not trigger then
			return
		end

		if math.random(100) > trigger.chance then
			return
		end

		if GetGameTimer() - lastExplosionFire < (cfg.cooldown or 30000) then
			return
		end

		local coords = getExplosionCoords(ev)

		-- No usable position (e.g. entity already despawned) — bail out
		if #(coords.xy) < 1.0 then
			return
		end

		if isNearActiveFire(coords, cfg.minDistance or 35.0) then
			return
		end

		lastExplosionFire = GetGameTimer()

		-- Game events deliver sender as a string
		local witness = tonumber(sender)

		-- Short random delay so the fire grows out of the explosion naturally
		Citizen.SetTimeout(
			math.random(1500, 4000),
			function()
				local fireIndex = Fire:create(coords, trigger.spread, trigger.spreadChance)

				print(("[FireScript] %s started fire #%s at %.1f, %.1f, %.1f (explosion type %s)"):format(
					trigger.name or "Explosion", fireIndex, coords.x, coords.y, coords.z, ev.explosionType))

				if not (cfg.dispatch and Config.Dispatch.enabled and not Config.Dispatch.disableCalls) then
					return
				end

				if Config.Dispatch.toneSources and type(Config.Dispatch.toneSources) == "table" then
					TriggerClientEvent('fireClient:playTone', -1)
				end

				Citizen.SetTimeout(
					Config.Dispatch.timeout,
					function()
						-- Let the player who caused the explosion resolve the street
						-- name, same flow as /startfire; fall back to a generic
						-- message if they're gone.
						if witness and witness > 0 and GetPlayerName(witness) then
							Dispatch.expectingInfo[witness] = GetGameTimer() + 30000
							TriggerClientEvent('fd:dispatch', witness, coords)
						else
							Dispatch:create(("%s reported."):format(trigger.name or "Fire"), coords)
						end
					end
				)
			end
		)
	end
)
