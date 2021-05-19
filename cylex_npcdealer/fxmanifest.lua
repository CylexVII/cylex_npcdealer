fx_version 'adamant'
description "C Y L E X"
game 'gta5'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'server/server.lua',
    'config.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'client/client.lua',
}

dependency 'es_extended'