--------------------------------------------
-- Simple Chat - Server Side
--------------------------------------------
local tagColors = {
    me = {179, 102, 255},
    ['do'] = {96, 165, 250},
    gme = {236, 72, 153},
    ooc = {156, 163, 175}
}

--------------------------------------------
-- UTILITIES
--------------------------------------------

local function escapeHTML(str)
    if not str or str == '' then
        return ''
    end
    local entities = {
        ['&'] = '&amp;',
        ['<'] = '&lt;',
        ['>'] = '&gt;',
        ['"'] = '&quot;',
        ["'"] = '&#39;'
    }
    return str:gsub("[&<>'\"]", entities)
end

local function DebugPrint(msg)
    if Config.Debug then
        print(("^5[SimpleChat]^7 %s"):format(msg))
    end
end

--------------------------------------------
-- DISCORD LOGGING (MODERNIZED)
--------------------------------------------
local function SendDiscordLog(title, fields, color)
    if not Config.EnableDiscordLogging or not Config.WebhookURL or Config.WebhookURL == "" then
        return
    end

    local embed = {{
        ["title"] = "💬 " .. title,
        ["color"] = color or 0x60A5FA,
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "SimpleChat • " .. os.date("%Y-%m-%d %H:%M:%S")
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}

    PerformHttpRequest(Config.WebhookURL, function()
    end, "POST", json.encode({
        username = Config.BotName or "SimpleChat Logger",
        avatar_url = Config.BotAvatar or "https://i.imgur.com/2Qz8Z7Y.png",
        embeds = embed
    }), {
        ["Content-Type"] = "application/json"
    })
end

local function LogChat(playerId, commandType, message)
    if not Config.EnableDiscordLogging then
        return
    end

    local name = GetPlayerName(playerId) or ("Player %d"):format(playerId)
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local color = Config.EmbedColors[commandType] or 0x60A5FA

    local ids = GetPlayerIdentifiers(playerId)
    local steam, license, discord, fivem = "N/A", "N/A", "N/A", "N/A"

    for _, id in ipairs(ids) do
        if id:find("steam:") then
            local steamHex = id:gsub("steam:", "")
            local steamDec = tonumber(steamHex, 16)
            if steamDec then
                steam = ("[Steam Profile](https://steamcommunity.com/profiles/%s)"):format(steamDec)
            else
                steam = id
            end
        elseif id:find("license:") then
            license = id
        elseif id:find("discord:") then
            local discordId = id:gsub("discord:", "")
            discord = ("<@%s>"):format(discordId)
        elseif id:find("fivem:") then
            fivem = id
        end
    end

    if message == nil or message == "" then
        message = "*No message*"
    end

    local fields = {{
        name = "👤 Player",
        value = ("%s (%d)"):format(name, playerId),
        inline = true
    }, {
        name = "🕒 Time",
        value = time,
        inline = true
    }, {
        name = "💭 Command",
        value = ("/" .. commandType),
        inline = true
    }, {
        name = "📝 Message",
        value = message,
        inline = false
    }, {
        name = "🧩 Identifiers",
        value = ("**License:** %s\n**Steam:** %s\n**Discord:** %s\n**FiveM:** %s"):format(license, steam, discord, fivem),
        inline = false
    }}

    SendDiscordLog("Chat Message Logged", fields, color)
end

--------------------------------------------
-- EVENTS
--------------------------------------------

RegisterNetEvent('_simplechat:builtin', function(kind, text)
    local src = source
    local name = GetPlayerName(src) or ('Player %d'):format(src)
    kind = (kind or 'ooc'):lower()
    text = tostring(text or ''):gsub("^%s*(.-)%s*$", "%1")

    if not Config.BuiltInCommands[kind] then
        if Config.Debug then
            print(("[SimpleChat] Ignored /%s command (disabled in config) from %s"):format(kind, name))
        end
        return
    end

    if (text == nil or text == '') and (kind == 'me' or kind == 'do' or kind == 'gme' or kind == 'ooc') then
        if Config.Debug then
            print(("[SimpleChat] Blocked empty /%s message from %s"):format(kind, name))
        end
        return
    end

    if not tagColors[kind] then
        kind = 'ooc'
    end

    TriggerEvent('chatMessage', src, name, ('/%s %s'):format(kind, text))
    TriggerClientEvent('simplechat:show', -1, {
        kind = kind,
        name = name,
        text = text
    })

    LogChat(src, kind, text)
end)

RegisterNetEvent('_simplechat:messageEntered', function(msg)
    local src = source
    local name = GetPlayerName(src) or ('Player %d'):format(src)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 255, 255},
        args = {name, msg or ''}
    })
    LogChat(src, "text", msg)
end)

RegisterNetEvent('chat:addSuggestion', function(name, help, params)
    TriggerClientEvent('chat:addSuggestion', -1, name, help, params)
end)

RegisterNetEvent('chat:removeSuggestion', function(name)
    TriggerClientEvent('chat:removeSuggestion', -1, name)
end)

--------------------------------------------
-- SEND BUILT-IN STATUS TO CLIENT
--------------------------------------------
local function SendBuiltInConfig(target)
    TriggerClientEvent('simplechat:updateBuiltInConfig', target or -1, Config.BuiltInCommands,
        Config.CommandDisplayOrder)
end

AddEventHandler('playerJoining', function()
    local src = source
    Wait(Config.SuggestionSyncDelay)
    local commands = GetRegisteredCommands()
    for _, cmd in ipairs(commands) do
        TriggerClientEvent('chat:addSuggestion', src, '/' .. cmd.name, '')
    end
    SendBuiltInConfig(src)
end)

RegisterCommand('refreshchatsuggestions', function(src)
    local commands = GetRegisteredCommands()
    for _, cmd in ipairs(commands) do
        TriggerClientEvent('chat:addSuggestion', -1, '/' .. cmd.name, '')
    end
    DebugPrint('Suggestions refreshed for all players.')
end, true)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(Config.SuggestionSyncDelay)
        local commands = GetRegisteredCommands()
        for _, cmd in ipairs(commands) do
            TriggerClientEvent('chat:addSuggestion', -1, '/' .. cmd.name, '')
        end
        SendBuiltInConfig(-1)
        DebugPrint('Loaded command suggestions for all players.')
    end
end)

-- =============================================
-- EXPORT: Template Card (Full Box Style)
-- =============================================
exports('SendTemplateMessage', function(data)
    if not data then
        return
    end

    local icon = data.icon or '💬'
    local title = data.title or 'SimpleChat'
    local message = data.message or ''
    local color = data.color or {255, 255, 255}

    if message == '' or message:match('^%s*$') then
        return
    end

    TriggerClientEvent('simplechat:template', -1, {
        icon = icon,
        title = title,
        message = message,
        color = color
    })
end)

-- =============================================
-- EXPORT: Inline Icon Message (Bubble Style)
-- =============================================
exports('SendInlineMessage', function(data)
    if not data then
        return
    end

    local playerName = data.name or "SYSTEM"
    local icon = data.icon or '💬'
    local text = data.text or ''
    local color = data.color or {255, 255, 255}

    if text == '' or text:match('^%s*$') then
        return
    end

    TriggerClientEvent('simplechat:inline', -1, {
        name = playerName,
        icon = icon,
        text = text,
        color = color
    })
end)

-- =============================================
-- EXPORT: Discord Logging
-- =============================================

exports('SendDiscordLog', function(data)
    if not Config.EnableDiscordLogging or not Config.WebhookURL or Config.WebhookURL == "" then
        print("^3[SimpleChat]^7 Tried to send Discord log but logging is disabled or webhook missing.")
        return
    end

    local playerId = data.playerId or 0
    local playerName = GetPlayerName(playerId) or data.playerName or "SYSTEM"
    local title = data.title or "Chat Message Logged"
    local command = data.command or "N/A"
    local message = data.message or "No message"
    local color = data.color or 0x60A5FA

    local identifiers = GetPlayerIdentifiers(playerId)
    local steam, license, discord, fivem = "N/A", "N/A", "N/A", "N/A"
    for _, id in pairs(identifiers) do
        if string.find(id, "steam:") then
            steam = id
        elseif string.find(id, "license:") then
            license = id
        elseif string.find(id, "discord:") then
            discord = "<@" .. string.sub(id, 9) .. ">"
        elseif string.find(id, "fivem:") then
            fivem = id
        end
    end

    local embed = {{
        ["title"] = title,
        ["color"] = color,
        ["fields"] = {{
            name = "👤 Player",
            value = string.format("%s (%d)", playerName, playerId),
            inline = true
        }, {
            name = "⏰ Time",
            value = os.date("%Y-%m-%d %H:%M:%S"),
            inline = true
        }, {
            name = "💬 Command",
            value = command,
            inline = true
        }, {
            name = "📝 Message",
            value = message ~= "" and message or "No message",
            inline = false
        }, {
            name = "🔍 Identifiers",
            value = string.format("**License:** %s\n**Steam:** %s\n**Discord:** %s\n**FiveM:** %s", license, steam,
                discord, fivem),
            inline = false
        }},
        ["footer"] = {
            ["text"] = "SimpleChat • " .. os.date("%Y-%m-%d %H:%M:%S")
        }
    }}

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
    end, 'POST', json.encode({
        username = Config.BotName or "SimpleChat",
        avatar_url = Config.BotAvatar or "https://i.imgur.com/VZLrHkZ.png",
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end)
