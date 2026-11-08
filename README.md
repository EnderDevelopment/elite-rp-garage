# Elite RP Garage FiveM Resource

Elite RP Garage is a configurable FiveM garage resource for ESX roleplay servers. This FiveM resource provides public garages and job-restricted garages, allowing players to retrieve owned vehicles, store vehicles, and preserve vehicle properties, condition, fuel, and garage state through the ESX `owned_vehicles` database table.

## Install

1. Copy the resource folder into your FiveM server's resources directory.
2. Run `install.sql` against your server database.
3. Ensure the dependencies in `server.cfg` in this order:

```cfg
ensure oxmysql
ensure es_extended
ensure esx_menu_default
ensure esx_menu_dialog
ensure elite_rp_garage
```

4. Replace `elite_rp_garage` with the actual resource folder name if necessary.
5. Edit `config.lua` to configure garage labels, locations, spawn points, blips, garage types, and job restrictions.
6. Restart the server.

Requirements:

- `es_extended`
- `oxmysql`
- `esx_menu_default`
- `esx_menu_dialog`
- An ESX `owned_vehicles` table containing `owner`, `plate`, `vehicle`, and `stored` columns

The SQL migration adds the `garage`, `engine`, `body`, and `fuel` columns. Existing vehicles are set as stored by default.

## Use

1. Walk to a configured garage marker.
2. Press `E` to open the garage menu.
3. Select one of your stored vehicles to spawn it.
4. The resource checks garage access and vehicle ownership on the server before marking the vehicle as out.
5. Drive the vehicle into a garage zone.
6. Press `G` while sitting in the driver's seat to store the vehicle.
7. Vehicle properties, engine health, body health, fuel level, garage location, and stored state are saved to the database.

Public garages are available to all players. Job garages require the configured ESX job name.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/122cac79-5780-41a1-b64d-698f82a1284a?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=122cac79-5780-41a1-b64d-698f82a1284a
