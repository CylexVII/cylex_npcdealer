ESX = nil
local PlayerData = {}
local blips, peds, itemsData = {}, {}, {}
local menuOpen = false
Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    ESX.TriggerServerCallback('cylex_npcdealer:server:getData', function(data)
        Config = data
    end)

    CreateThread(function()
        while (GlobalState.ItemList) == nil do Wait(500) end
        while next(GlobalState.ItemList) == nil do Wait(500) end
        itemsData = GlobalState.ItemList
    end)
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearby = false
        if Config ~= nil then
            for k, v in pairs(Config.DealerLocation) do 
                for i = 1, #v.coords do
                    local dist = #(coords - v.coords[i])
                    if v["drawText"].enable then
                        if dist <= v["drawText"].distance + 1 then
                            nearby = true
                            if dist <= v["drawText"].distance then
                                DrawText3D(v.coords[i], v["drawText"].text)
                                if IsControlJustPressed(0, 38) and not IsPedInAnyVehicle(ped, false) and not menuOpen then 
                                    sellFunction(v, k)
                                end
                            end
                            if menuOpen and dist >= v["drawText"].distance then
                                ESX.UI.Menu.CloseAll()
                                menuOpen = false
                            end
                        end
                    end
                end
            end
        end
        if not nearby then Citizen.Wait(1000) end
        Citizen.Wait(1)
    end
end)

function getQuantity(item)
    local count = nil
    if item == nil or item == 0 then return 0 end
    ESX.TriggerServerCallback('cylex_npcdealer:server:getCount', function(quanity)
        count = quanity
    end, item)
    while count == nil do
        Citizen.Wait(1)
    end
    return count
end

function sellFunction(vConfig, kConfig)
    ESX.UI.Menu.CloseAll()
    local elements = {}
    menuOpen = true
    local itemConfig = itemsData
    for k, v in pairs(vConfig["items"]) do 
        if itemConfig[k] ~= nil then
            local price = vConfig["items"][k]
            local count = getQuantity(k)
            if count > 0 then
                table.insert(elements, {
                    label = itemConfig[k]['label'],
                    name = k,
                    price = price,
                    type = 'slider',
                    value = 1,
                    min = 1,
                    max = count
                })
            else
                table.insert(elements, {
                    label = itemConfig[k]['label'],
                    name = k,
                    price = nil,
                    value = nil,
                })
            end
        end
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'npc_sell', {
	title    = _U('menu_default_title'),
	align    = 'top-left',
	elements = elements
    }, function(data, menu)
        ESX.UI.Menu.CloseAll()
        local amount = data.current.value
        if amount == nil or amount <= 0 then 
            ESX.UI.Menu.CloseAll()
            menuOpen = false
            return exports["mythic_notify"]:SendAlert("error", _U('not_enough_item'))
        end
        TriggerAnimation(PlayerPedId(), vConfig['animation'])
        TriggerEvent("mythic_progbar:client:progress", {
            name = "sell_progress",
            duration = vConfig['progressBar'].durationPerAmount and amount * vConfig['progressBar'].duration or vConfig['progressBar'].duration,
            label = vConfig['progressBar'].text,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },									
        }, function(status)
            if not status then
                TriggerServerEvent('cylex_npcdealer:server:sellItem', data.current.name, amount, vConfig["items"][data.current.name])
            else
                exports["mythic_notify"]:SendAlert("error", _U('progress_cancel'))
            end
            ESX.UI.Menu.CloseAll()
            menuOpen = false
        end)
   end, function(data, menu)
	menu.close()
	menuOpen = false
    end)
end

Citizen.CreateThread(function()
    while Config == nil do Citizen.Wait(100) end
    for k, v in pairs(Config.DealerLocation) do
        for i = 1, #v.coords do
            if v["blip"].enable then
                local PickupBlip = AddBlipForCoord(v["coords"][i])
                SetBlipSprite(PickupBlip, v["blip"].sprite)
                SetBlipColour(PickupBlip, v["blip"].color)
                SetBlipScale(PickupBlip, v["blip"].scale)
                SetBlipAsShortRange(PickupBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v["blip"].blipName)
                EndTextCommandSetBlipName(PickupBlip)
                table.insert(blips, PickupBlip)
            end
            if v["npc"].enable then
                RequestModel(v["npc"].hash)
                while not HasModelLoaded(v["npc"].hash) do Citizen.Wait(1) end
                local ped = CreatePed(1, v["npc"].hash, v["coords"][i].x, v["coords"][i].y, v["coords"][i].z-1, v["npc"].heading, false, true)
                SetPedCombatAttributes(ped, 46, true)                     
                SetPedFleeAttributes(ped, 0, 0)                      
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetEntityAsMissionEntity(ped, true, true)
                SetEntityInvincible(ped, true)
                FreezeEntityPosition(ped, true)
                table.insert(peds, ped)
            end
        end
    end
end)

function DrawText3D(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z+0.5)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function TriggerAnimation(ped, animation)
    if not HasAnimDictLoaded(animation['animDict']) then
        RequestAnimDict(animation['animDict']) 
        while not HasAnimDictLoaded(animation['animDict']) do Citizen.Wait(10) end
    end
    TaskPlayAnim(ped, animation['animDict'], animation['animName'], 8.0, -8, -1, animation['animFlag'], 0, 0, 0, 0)
end
