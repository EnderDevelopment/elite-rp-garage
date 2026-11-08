fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_script 'config.lua'
client_script 'client.lua'
server_script '@oxmysql/lib/MySQL.lua'
server_script 'server.lua'

dependencies {
    'es_extended',
    'oxmysql'
}
