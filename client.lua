local ESX = exports['es_extended']:getSharedObject()
local menuOpen = false

local function notify(message)
    ESX.ShowNotification(message)
end

local function vehicleLabel(vehicleData, properties)
    local model = properties.model or vehicleData.model
    if not model then return vehicleData.plate end

    local displayName = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(displayName)
    if label == 'NULL' then label = displayName end
    if label == 'NULL' or label == '' then label = tostring(model) end
    return label .. ' | ' .. vehicleData.plate
end

local function spawnVehicle(vehicleData, garageId)
    local garage = Config.Garages[garageId]
    if not garage then return end
    local point = garage.spawn
    if IsAnyVehicleNearPoint(point.x, point.y, point.z, Config.SpawnDistance) then
        notify('The vehicle spawn area is blocked.')
        return
    end

    local properties = json.decode(vehicleData.vehicle or '{}') or {}
    local model = properties.model or vehicleData.model
    if not model or not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        notify('This vehicle model is invalid.')
        return
    end

    ESX.Game.SpawnVehicle(model, vector3(point.x, point.y, point.z), point.w, function(vehicle)
        if not DoesEntityExist(vehicle) then
            notify('Vehicle could not be spawned.')
            return
        end

        ESX.Game.SetVehicleProperties(vehicle, properties)
        SetEntityHeading(vehicle, point.w)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleNumberPlateText(vehicle, vehicleData.plate)
        SetVehRadioStation(vehicle, 'OFF')
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        TriggerServerEvent('garage:server:setOut', vehicleData.plate, garageId)
        notify('Vehicle retrieved.')
    end)
end

local function openGarage(garageId)
    if menuOpen then return end
    local garage = Config.Garages[garageId]
    if not garage then return end

    menuOpen = true
    ESX.TriggerServerCallback('garage:server:getVehicles', function(vehicles)
        menuOpen = false
        if not vehicles or #vehicles == 0 then
            notify('No stored vehicles in this garage.')
            return
        end

        local elements = {}
        for _, vehicle in ipairs(vehicles) do
            local properties = json.decode(vehicle.vehicle or '{}') or {}
            elements[#elements + 1] = {
                label = vehicleLabel(vehicle, properties),
                vehicle = vehicle
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
            title = garage.label,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            spawnVehicle(data.current.vehicle, garageId)
        end, function(data, menu)
            menu.close()
        end)
    end, garageId)
end

RegisterNetEvent('garage:client:storeResult', function(success, message, networkId)
    notify(message)
    if success and networkId then
        local vehicle = NetToVeh(tonumber(networkId))
        if DoesEntityExist(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
        end
    end
end)

CreateThread(function()
    for garageId, garage in pairs(Config.Garages) do
        if Config.UseBlip then
            local blip = AddBlipForCoord(garage.zone.x, garage.zone.y, garage.zone.z)
            SetBlipSprite(blip, Config.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipColour(blip, Config.Blip.colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blip.name)
            EndTextCommandSetBlipName(blip)
        end

        local id = garageId
        CreateThread(function()
            while true do
                local wait = 1000
                local ped = PlayerPedId()
                local distance = #(GetEntityCoords(ped) - garage.zone)
                if distance < 15.0 then
                    wait = 0
                    DrawMarker(2, garage.zone.x, garage.zone.y, garage.zone.z + 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.2, 70, 160, 230, 180, false, true, 2, false, nil, nil, false)
                    if distance < garage.radius then
                        BeginTextCommandDisplayHelp('STRING')
                        AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to open garage; press ~INPUT_DETONATE~ to store vehicle')
                        EndTextCommandDisplayHelp(0, false, true, -1)
                        if IsControlJustReleased(0, 38) then
                            openGarage(id)
                        elseif IsControlJustReleased(0, 47) then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
                                notify('You must be driving a vehicle to store it.')
                            else
                                local props = ESX.Game.GetVehicleProperties(vehicle)
                                TriggerServerEvent('garage:server:storeVehicle', id, props, GetVehicleEngineHealth(vehicle), GetVehicleBodyHealth(vehicle), GetVehicleFuelLevel(vehicle), VehToNet(vehicle))
                            end
                        end
                    end
                end
                Wait(wait)
            end
        end)
    end
end)
