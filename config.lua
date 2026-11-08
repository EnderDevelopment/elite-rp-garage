Config = {}

Config.Framework = 'esx'
Config.InteractionDistance = 3.0
Config.SpawnDistance = 35.0
Config.UseBlip = true
Config.Blip = {
    sprite = 357,
    colour = 3,
    scale = 0.75,
    name = 'Garage'
}

Config.Garages = {
    legion = {
        label = 'Legion Square Garage',
        type = 'public',
        zone = vector3(215.76, -810.12, 30.73),
        spawn = vector4(229.34, -801.78, 30.57, 157.0),
        radius = 3.0
    },
    sandy = {
        label = 'Sandy Shores Garage',
        type = 'public',
        zone = vector3(1737.66, 3710.27, 34.14),
        spawn = vector4(1722.66, 3713.79, 34.23, 20.0),
        radius = 3.0
    },
    police = {
        label = 'Police Garage',
        type = 'job',
        job = 'police',
        zone = vector3(452.31, -1018.71, 28.48),
        spawn = vector4(445.64, -1025.46, 28.63, 2.0),
        radius = 3.0
    }
}
