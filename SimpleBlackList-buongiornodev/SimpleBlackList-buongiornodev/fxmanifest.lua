resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
fx_version 'adamant'
game 'gta5'

author 'AOBUONGIORNO'
description 'Blacklist'
version '1.1'

files {
	'client/*.lua',
}

shared_scripts {
    '@es_extended/imports.lua'
}

client_scripts {
	'config/*.lua',
	'client/*.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/*.lua'
}