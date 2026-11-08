local ESX = exports['es_extended']:getSharedObject()

local function normalizePlate(plate)
    return string.upper((plate or ''):gsub('%s+', ''))
end

local function canUseGarage(player, garage)
    if not player or not garage then return false end
    if garage.type == 'job' then
        return player.getJob() and player.getJob().name == garage.job
    end
    return garage.type == 'public'
end

ESX.RegisterServerCallback('garage:server:getVehicles', function(source, callback, garageId)
    local player = ESX.GetPlayerFromId(source)
    local garage = Config.Garages[garageId]
    if not canUseGarage(player, garage) then
        callback({})
        return
    end

    local vehicles = MySQL.query.await([[SELECT plate, vehicle, stored, garage FROM owned_vehicles WHERE owner = ? AND stored = 1 AND (garage = ? OR garage IS NULL OR garage = '') ORDER BY plate ASC]], {
        player.getIdentifier(),
        garageId
    })
    callback(vehicles or {})
end)

RegisterNetEvent('garage:server:setOut', function(plate, garageId)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local garage = Config.Garages[garageId]
    if not canUseGarage(player, garage) then return end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    if #(coords - garage.zone) > garage.radius + 8.0 then return end

    MySQL.update.await('UPDATE owned_vehicles SET stored = 0, garage = NULL WHERE owner = ? AND stored = 1 AND REPLACE(UPPER(plate), " ", "") = ?', {
        player.getIdentifier(),
        normalizePlate(plate)
    })
end)

RegisterNetEvent('garage:server:storeVehicle', function(garageId, properties, engineHealth, bodyHealth, fuelLevel, networkId)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local garage = Config.Garages[garageId]
    if not canUseGarage(player, garage) then
        TriggerClientEvent('garage:client:storeResult', source, false, 'You are not allowed to use this garage.')
        return
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    if #(coords - garage.zone) > garage.radius + 8.0 then return end
    local vehicle = NetworkGetEntityFromNetworkId(tonumber(networkId) or 0)
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        TriggerClientEvent('garage:client:storeResult', source, false, 'You must be driving a vehicle to store it.')
        return
    end
    if type(properties) ~= 'table' or not properties.plate or not properties.model then
        TriggerClientEvent('garage:client:storeResult', source, false, 'Vehicle data is invalid.')
        return
    end

    local plate = normalizePlate(properties.plate)
    if normalizePlate(GetVehicleNumberPlateText(vehicle)) ~= plate then
        TriggerClientEvent('garage:client:storeResult', source, false, 'Vehicle data did not match.')
        return
    end

    local updated = MySQL.update.await('UPDATE owned_vehicles SET vehicle = ?, stored = 1, garage = ?, engine = ?, body = ?, fuel = ? WHERE owner = ? AND stored = 0 AND REPLACE(UPPER(plate), " ", "") = ?', {
        json.encode(properties),
        garageId,
        math.floor(tonumber(engineHealth) or 1000),
        math.floor(tonumber(bodyHealth) or 1000),
        math.floor(tonumber(fuelLevel) or 100),
        player.getIdentifier(),
        plate
    })

    if updated and updated > 0 then
        TriggerClientEvent('garage:client:storeResult', source, true, 'Vehicle stored.', networkId)
    else
        TriggerClientEvent('garage:client:storeResult', source, false, 'Vehicle is not owned by you or is already stored.')
    end
end)
