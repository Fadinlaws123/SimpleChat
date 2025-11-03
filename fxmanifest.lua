fx_version 'cerulean'
game 'gta5'

author 'SimpleDevelopments'
description 'Custom themed chat box'
version '1.0'

ui_page 'html/index.html'

files {'html/index.html', 'html/style.css', 'html/script.js'}

shared_script 'config.lua'

client_script 'client/client.lua'
server_script 'server/server.lua'
provide 'chat'

