ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    print("^7[^1cylex_npcdealer^7] - ^2Aktif! ^0") 
end)

ESX.RegisterServerCallback('cylex_npcdealer:server:getData', function(source, cb)
    cb(Config, ESX.Items)
end)

ESX.RegisterServerCallback('cylex_npcdealer:server:getCount', function(source, cb, item)
    local player = ESX.GetPlayerFromId(source)
    if player then
        local item = player.getInventoryItem(item)
        if item == nil then
            cb(0)
        else
            cb(item.count)
        end
    else
        cb(0)
    end
end)

RegisterServerEvent("cylex_npcdealer:server:sellItem")
AddEventHandler("cylex_npcdealer:server:sellItem", function(item, amount, cash)
    local player = ESX.GetPlayerFromId(source)
    if not player or amount == nil or amount < 1 then return end
    local count = player.getInventoryItem(item).count
    if count >= amount then 
        player.removeInventoryItem(item, amount) 
        player.addMoney(cash * amount)
        TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'inform', text = _U('on_sell', amount, ESX.GetItemLabel(item), amount*cash)})
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = _U('not_enough_item')})
    end
end)