--================================--
--       FIRE SCRIPT v2.0.2       --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

Config = {}

Config.Fire = {
    fireSpreadChance = 5, -- Out of 100 chances, how many lead to fire spreading? (not exactly percents)
    maximumSpreads = 5,
    difficulty = 3, -- 1 to 10; sets how hard (lengthy) it will be to extinguish a fire (set nil as default or a whole number larger than 0, e.g. 2, to increase difficulty; try how it works, probably don't go higher than 10)
    spawner = { -- Requires the use of the built-in dispatch system
        enableOnStartup = false,
        interval = 1800000, -- Random fire spawn interval (set to nil or false if you don't want to spawn random fires) in ms
        chance = 50, -- Fire spawn chance (out of 100 chances, how many lead to spawning a fire?); Set to values between 1-100
        players = 3, -- Sets the minimum number of players subscribed to dispatch for the spawner to spawn fires.
        firefighterJobs = { -- If using a framework (Config.Dispatch.enableFramework), you can specify which players will count as firefighters in Config.Fire.spawner.players above; If set to nil, all jobs specified in Config.Dispatch.jobs will count as firefighters
            ["fd"] = true -- Always set the job name in the key, value has to be true
        }
    }
}

Config.ExplosionFires = {
    enabled = true,
    dispatch = true,      -- Trigger a dispatch call (tone, blip, GPS) like a scenario fire would
    cooldown = 30000,     -- Minimum time in ms between two explosion-started fires (anti-spam)
    minDistance = 35.0,   -- Don't start a fire if another fire is already burning within this radius
    triggers = {          -- [explosionType] = { chance = start chance out of 100, spread = max spreads, spreadChance = spread chance out of 100, name = dispatch fallback name }
        [3]  = { chance = 80,  spread = 3, spreadChance = 30, name = "Molotov fire" },
        [7]  = { chance = 25,  spread = 3, spreadChance = 20, name = "Vehicle fire" },
        [8]  = { chance = 60,  spread = 5, spreadChance = 40, name = "Aircraft fire" },
        [9]  = { chance = 100, spread = 5, spreadChance = 50, name = "Petrol pump fire" },
        [10] = { chance = 25,  spread = 2, spreadChance = 20, name = "Bike fire" },
        [17] = { chance = 35,  spread = 4, spreadChance = 25, name = "Truck fire" },
        [27] = { chance = 60,  spread = 3, spreadChance = 35, name = "Barrel fire" },
        [28] = { chance = 75,  spread = 4, spreadChance = 40, name = "Propane fire" },
        [31] = { chance = 70,  spread = 5, spreadChance = 50, name = "Tanker fire" },
        [34] = { chance = 50,  spread = 4, spreadChance = 40, name = "Fuel tank fire" },
    }
}

Config.Dispatch = {
    enabled = true, -- Set this to false if you don't want to use the default dispatch system
    disableCalls = false, -- Set to true to suppress dispatch calls while keeping the rest of the dispatch system active
    timeout = 15000, -- The amount of time in ms to delay the dispatch after the fire has been created
    storeLast = 5, -- The client will store the last five dispatch coordinates for use with /remindme <dispatchNumber>
    clearGpsRadius = 20.0, -- If you don't want to automatically clear the route upon arrival, leave this to false
    clearBlipRadius = 150.0, -- The dispatch blip is removed once no fire burns within this radius of the call anymore
    playSound = true,
    enableFramework = nil, -- Set to nil if you don't want to use any framework implementation. Set to 1 for ESX, 2 for QB-Core.
    jobs = { -- Set to a ESX job / jobs you want to be automatically subscribed to dispatch; Set to nil or false if you don't want to use this
        "fd"
    },
    toneSources = { -- Here you can set coordinates of sound sources for the fire tones to go off at; Set to nil if you wish to disable this function.
        -- Fire Station 7
        vector3(1207.11, -1463.37, 36),
        vector3(1195, -1464, 36),
        vector3(1195, -1484, 36),
        vector3(1207.11, -1484, 36),
        -- Sandy Shores
        vector3(1691, 3586, 37)
    }
}
