--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

-- Scenario visualization: map blips per scenario, markers + floating
-- info text per flame. Toggled via /showscenarios and /hidescenarios.

ScenarioView = {
	active = false,
	blips = {},
	flames = {},
	centers = {}
}

function ScenarioView:hide()
	self.active = false

	for _, blip in pairs(self.blips) do
		RemoveBlip(blip)
	end

	self.blips = {}
	self.flames = {}
	self.centers = {}
end

function ScenarioView:show(scenarios, activeScenarios)
	self:hide()
	self.active = true

	for id, scenario in pairs(scenarios) do
		local isActive = activeScenarios[id] == true
		local isEnabled = scenario.random == true -- part of the random spawner pool

		-- Blip at the scenario's dispatch coords (fall back to its first flame)
		local blipCoords = scenario.dispatchCoords
		if not blipCoords then
			for _, flame in pairs(scenario.flames) do
				blipCoords = flame.coords
				break
			end
		end

		if blipCoords then
			local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
			SetBlipSprite(blip, 436)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 0.9)
			-- Green = in random pool, red = not; burning flashes red regardless
			SetBlipColour(blip, (isActive or not isEnabled) and 1 or 2)
			if isActive then
				SetBlipFlashes(blip, true)
			end
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(("Scenario #%s%s"):format(id, isActive and " (active)" or ""))
			EndTextCommandSetBlipName(blip)
			self.blips[#self.blips + 1] = blip

			self.centers[#self.centers + 1] = {
				coords = blipCoords,
				isActive = isActive,
				isEnabled = isEnabled
			}
		end

		-- Flatten flames once so the draw loop stays cheap
		local header = ("Scenario #%s%s%s%s"):format(
			id,
			scenario.difficulty and (" | Difficulty %s"):format(scenario.difficulty) or "",
			scenario.random and " | Random" or "",
			isActive and " | ~r~ACTIVE~s~" or ""
		)

		for flameID, flame in pairs(scenario.flames) do
			self.flames[#self.flames + 1] = {
				coords = flame.coords,
				text = ("%s\nFlame #%s | Spread %s | Chance %s%%"):format(header, flameID, flame.spread, flame.chance)
			}
		end
	end

	Citizen.CreateThread(
		function()
			while self.active do
				Citizen.Wait(0)
				local pedCoords = GetEntityCoords(PlayerPedId())

				-- Tall beam at each scenario center, visible from far away
				for _, center in ipairs(self.centers) do
					if #(center.coords - pedCoords) < 1000.0 then
						-- Green = in random pool, red = not; burning = brighter red
						local r, g, b, a = 30, 200, 30, 110
						if center.isActive then
							r, g, b, a = 255, 30, 30, 160
						elseif not center.isEnabled then
							r, g, b, a = 200, 30, 30, 110
						end
						DrawMarker(
							1, -- vertical cylinder
							center.coords.x, center.coords.y, center.coords.z - 1.0,
							0.0, 0.0, 0.0,
							0.0, 0.0, 0.0,
							4.0, 4.0, 250.0,
							r, g, b, a,
							false, false, 2, false, nil, nil, false
						)
					end
				end

				for _, flame in ipairs(self.flames) do
					if #(flame.coords - pedCoords) < 50.0 then
						DrawMarker(
							28, -- sphere
							flame.coords.x, flame.coords.y, flame.coords.z,
							0.0, 0.0, 0.0,
							0.0, 0.0, 0.0,
							1.5, 1.5, 1.5,
							255, 60, 30, 120,
							false, false, 2, false, nil, nil, false
						)
						DrawText3D(flame.coords + vector3(0.0, 0.0, 1.5), flame.text)
					end
				end
			end
		end
	)
end

RegisterNetEvent('fireClient:showScenarios')
AddEventHandler(
	'fireClient:showScenarios',
	function(scenarios, activeScenarios)
		if not next(scenarios) then
			sendMessage("No scenarios registered.")
			return
		end

		ScenarioView:show(scenarios, activeScenarios or {})

		local count = countElements(scenarios)
		sendMessage(("Showing %s scenario(s). Use /hidescenarios to clear."):format(count))
	end
)

RegisterCommand(
	'hidescenarios',
	function()
		ScenarioView:hide()
		sendMessage("Scenario display cleared.")
	end,
	false
)
