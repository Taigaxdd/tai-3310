local QBCore = exports['qb-core']:GetCoreObject()
local lastselled = 0

QBCore.Commands.Add("satışiptal", "Satışı iptal et.", {}, false, function(source, args) -- name, help, arguments, argsrequired,  end sonuna persmission
    TriggerClientEvent("tai-3310:canceljob", source)
end)

QBCore.Functions.CreateUseableItem(Config.ItemName, function (source)
    TriggerClientEvent('tai-3310:openmenu', source)
end)

QBCore.Functions.CreateCallback('tai-3310:hasitem', function (source, cb, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Player.Functions.GetItemByName(item)
    cb(item.amount)
end)

RegisterServerEvent('tai-3310:server:sellitem')
AddEventHandler('tai-3310:server:sellitem', function (item, count)
    local player = QBCore.Functions.GetPlayer(source)
    local itemdata = player.Functions.GetItemByName(item)
    player.Functions.RemoveItem(item, count)
    player.Functions.AddMoney('cash', Config.Locations[item].price * count)
    TriggerClientEvent('QBCore:Notify', source, 'Başarıyla '.. count .. ' adet ' .. itemdata.label .. ' sattın.' , 'success')
end)

QBCore.Functions.CreateCallback('tai-3310:server:checkTime', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    if (os.time() - lastselled) < 15 and lastselled ~= 0 then
        local seconds = 15 - (os.time() - lastselled)
        -- TriggerClientEvent('trainheist:client:showNotification', src, Strings['wait_nextrob'] .. ' ' .. math.floor(seconds / 60) .. ' ' .. Strings['minute'])
        -- TriggerClientEvent("QBCore:Notify", src, "Tren Soygununu Tekrar Başlatabilmek İçin " .. " " .. math.floor(seconds / 60) .. ' ' .. "Dakika Beklemelisin", "error")
        cb(false)
    else
        lastselled = os.time()
        start = true
        -- discordLog(player.getName() ..  ' - ' .. player.getIdentifier(), ' started the Train Heist!')
        cb(true)
    end
end)