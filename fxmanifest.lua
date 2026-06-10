fx_version 'cerulean'

games {
	'gta5'
}

lua54 'yes'

author 'GIMI, foregz, Albo1125'
version '2.0.2'
description 'Fire Script'

shared_script "config.lua"

client_scripts {
	"client/utils.lua",
	"client/fire.lua",
	"client/dispatch.lua",
	"client/main.lua",
}

server_scripts {
	"server/utils.lua",
	"server/whitelist.lua",
	"server/fire.lua",
	"server/dispatch.lua",
	"server/main.lua",
}

files {
	'data/firescript_alarm.dat54.rel',
	'toneaudio/firescript_alarm.awc',
}

data_file 'AUDIO_WAVEPACK' 'toneaudio'
data_file 'AUDIO_SOUNDDATA' 'data/firescript_alarm.dat'
