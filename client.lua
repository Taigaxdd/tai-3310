local QBCore = exports['qb-core']:GetCoreObject()
local clientblip = nil
local doingjob = false



function openmenu()
    local opt = {}
    for k,v in ipairs(Config.Items) do
        table.insert(opt, {value = v.value, text = v.name})
    end

    local keyboard = exports['qb-input']:ShowInput({
        header = "Satış Yap",
        submitText = "Anlaşma Yap",
        inputs = {
            {
                text = "Bana ne verebilirsin ?", -- text you want to be displayed as a input header
                name = "selecteditem", -- name of the input should be unique otherwise it might override
                type = "select", -- type of the input - Select is useful for 3+ amount of "or" options e.g; someselect = none OR other OR other2 OR other3...etc
                options = opt
            }
        }
    })
    local selecteditem = keyboard.selecteditem
    local sans = math.random(1, 8)
    local itemsans = math.random(1,5)
    if selecteditem and selecteditem ~= 'none' then
        startjob(selecteditem, sans, itemsans)
    else
        QBCore.Functions.Notify('Geçerli bir eşya seçmedin', 'error')
        doingjob = false
    end
end

startjob =  function (selecteditem, sans, itemsans)
    local ped = PlayerPedId()
    coords = Config.Locations[selecteditem].coords[sans]
    SetNewWaypoint(coords)
    clientblip = addblip(coords)
    QBCore.Functions.Notify('Konum gpsinde işaretlendi.', 'info')
    QBCore.Functions.Notify('İstenen eşya sayısı: '.. ' '.. itemsans, 'info')
    QBCore.Functions.Notify('İptal etmek için /satışiptal', 'info')
    doingjob = true
    while doingjob do
        local pedcoords = GetEntityCoords(ped)
        local dist = GetDistanceBetweenCoords(pedcoords, coords, 1)
        local sleep = 1000
        if dist < 20 then
            sleep = 1
            DrawMarker(3, coords.x, coords.y, coords.z - 0.2, 0,0,0,0.0,0,0,0.3,0.3,0.2,0,255,0,50,0,0,0,1)
            if dist < 5.0 then
                QBCore.Functions.DrawText3D(coords.x, coords.y, coords.z, "[E] - Teslim Et")
                if IsControlJustReleased(0, 38) then
                    QBCore.Functions.TriggerCallback('tai-3310:hasitem', function (qtty)
                        if qtty >= itemsans then
                            QBCore.Functions.Progressbar("sell3310", "Malzemeleri satıyorsun", 15000, false, true, {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = "timetable@jimmy@doorknock@",
                                anim = "knockdoor_idle",
                                flags = 1,
                            }, {}, {}, function() -- Done
                                RemoveBlip(clientblip)
                                if math.random(1,100) >= 50 then
                                    data = {
                                        id = id,
                                        code = 1,
                                        description = "Birileri illegal eşyalar satıyor",
                                        location = exports["jtDispatch"]:GetTheStreet(),
                                        coords = pedcoords,
                                        sprite = 354
                                    }
                                    TriggerServerEvent("jtDispatch:add-notification", data, "police")
                                end
                                TriggerServerEvent('tai-3310:server:sellitem', selecteditem, itemsans)
                                -- QBCore.Functions.Notify('Başarıyla ' .. itemsans .. ' adet ' .. selecteditem .. ' sattın.' , 'success')
                                doingjob = false
                                QBCore.Functions.Notify('Görev bitti yeni görev alabilirsin.' , 'info')
                                -- resell(selecteditem)
                            end, function()
                                QBCore.Functions.Notify('İptal ettin', 'error')
                            end)

                        else
                            QBCore.Functions.Notify('Yeterli eşyan yok', 'error')
                        end
                    end, selecteditem)
                end
            end
        end
        Citizen.Wait(sleep)
    end

end

function addblip(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 40)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Alıcı')
    EndTextCommandSetBlipName(blip)
    return blip
end



-- function resell(selecteditem)
--     if not incooldown and not doingjob then
--         local sans2 = math.random(1,8)
--         local itemsans2 = math.random(1,5)
--         startjob(selecteditem, sans2, itemsans2)
--     end
-- end

-- function  isincooldown()    
--     if (os.time() - lastselled) < 15 and lastselled ~= 0 then
--         local seconds = 15 - (os.time() - lastselled)
--         return false
--     end
--     lastselled = os.time()
--     start = true
--     return true
    
-- end

RegisterNetEvent('tai-3310:canceljob')
AddEventHandler('tai-3310:canceljob', function ()
    doingjob = false
    QBCore.Functions.Notify('İşi iptal ettin', 'error')
    DeleteWaypoint()
    RemoveBlip(clientblip)
end)

RegisterNetEvent('tai-3310:openmenu')
AddEventHandler('tai-3310:openmenu', function ()
    if not doingjob then
        openmenu()
    else
        QBCore.Functions.Notify('Zaten iş yapyorsun', 'error')
    end
end)
