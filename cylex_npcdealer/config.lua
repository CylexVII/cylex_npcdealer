Config = {}
Config.Locale = 'en'

Config.DealerLocation = {
    ["Fish"] = {
        coords = {
            vector3(-3031.1628417969, 92.543334960938, 12.346242904663),
        },
        ["npc"] = {
            enable = true,
            hash = 0x5B44892C,
            heading = 328.6963,
        },
        ["blip"] = {
            enable = true,
            blipName = "Fish Sell",
            sprite = 365,
            color = 46,
            scale = 0.9,
        },
        ["drawText"] = {
            enable = true,
            farText = "Aquaman",
            text = "Press ~g~E~w~ to talk Aquaman.",
            distance = 1.5
        },
        ['animation'] = {
            enable = true,
            animDict = "mp_car_bomb",
            animName = "car_bomb_mechanic",
            animFlag = 49,
        },
        ['progressBar'] = {
            enable = true,
            text = 'Selling...',
            durationPerAmount = true, -- if is true progress time = duration*itemAmount 
            duration = 5000
        },
        ["items"] = {
           ["fish"] = 20,
        }
    },

    ["Butcher"] = {
        coords = {
            vector3(-591.70, -892.56, 25.93),
        },
        ["npc"] = {
            enable = true,
            hash = 0x0DE9A30A,
            heading = 91.83,
        },
        ["blip"] = {
            enable = true,
            blipName = "Slaughterer Sell",
            sprite = 365,
            color = 46,
            scale = 0.9,
        },
        ["drawText"] = {
            enable = true,
            farText = "Butcherman",
            text = "Press ~g~E~w~ to talk Butcher.",
            distance = 1.5
        },
        ['animation'] = {
            enable = true,
            animDict = "mp_car_bomb",
            animName = "car_bomb_mechanic",
            animFlag = 49,
        },
        ['progressBar'] = {
            enable = true,
            text = 'Selling...',
            durationPerAmount = true, -- if is true progress time = duration*itemAmount 
            duration = 5000
        },
        ["items"] = {
            ["alive_chicken"] = 100,
            ["slaughtered_chicken"] = 100,
        }
    },
}