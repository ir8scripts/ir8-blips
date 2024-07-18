fx_version 'cerulean'
game 'gta5'
author 'IR8 Scripts'
description 'Blips script'
version '1.0.6'
lua54 'yes'

client_script 'client/main.lua'

server_script {
    '@oxmysql/lib/MySQL.lua', 
    'server/database.lua',
    'server/main.lua'
}

shared_script { 
    "@ox_lib/init.lua",
    "shared/config.lua",
    "shared/utilities.lua"
}

ui_page {
    'nui/index.html',
}

files {
	'nui/index.html',
	'nui/js/script.js', 
	'nui/css/style.css',
    'nui/images/blips/*.png'
}