Config = {}

-- ====================================================
-- ✅ SIMPLECHAT SETTINGS
-- ====================================================

Config.CommandDisplayOrder = { -- Add commands here to set their order on the hud.
'me', -- always first
'do', -- always second
'gme', -- always third
'ooc' -- always last
}

Config.BuiltInCommands = {
    me = true, -- /me  (Local RP action)
    ['do'] = true, -- /do  (RP environment detail)
    gme = true, -- /gme (Global RP action)
    ooc = true -- /ooc (Out of Character)
}

-- ====================================================
-- ✅ DISCORD LOGGING SETTINGS
-- ====================================================

Config.EnableDiscordLogging = true
Config.WebhookURL = "https://discord.com/api/webhooks/"

Config.BotName = "SimpleChat Logger"
Config.BotAvatar = "https://i.postimg.cc/qvrHpRxj/logo.png"

Config.EmbedColors = {
    me = 0xB366FF,
    ['do'] = 0x60A5FA,
    gme = 0xEC4899,
    ooc = 0x9CA3AF,
    command = 0xFBBF24
}

-- ====================================================
-- ✅ ADVANCED OPTIONS
-- ====================================================

-- Delay for auto-suggestion sync on join/start
Config.SuggestionSyncDelay = 2000

-- Enable debug messages in console
Config.Debug = true
