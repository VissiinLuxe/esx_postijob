resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

version '1.0.0'

server_scripts {
  '@es_extended/locale.lua',
  'en.lua',
	'config.lua',
	'sv_postijob.lua'
}

client_scripts {
	'@es_extended/locale.lua',
  'en.lua',
	'config.lua',
	'cl_postijob.lua'
}
