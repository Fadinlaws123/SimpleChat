local chatOpen = false

RegisterCommand('simplechat:open', function()
    if chatOpen then
        return
    end
    chatOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'chat:open'
    })
end)
RegisterKeyMapping('simplechat:open', 'Open Chat', 'keyboard', 't')

RegisterNUICallback('chat:submit', function(data, cb)
    local raw = (data.message or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if raw ~= '' then
        if raw:sub(1, 1) == '/' then
            local cmd, rest = raw:match('^/(%S+)%s*(.*)$')
            cmd = (cmd or ''):lower()

            if cmd == 'me' or cmd == 'do' or cmd == 'gme' or cmd == 'ooc' then
                TriggerServerEvent('_simplechat:builtin', cmd, rest)
            else
                ExecuteCommand(raw:sub(2))
            end
        else
            TriggerServerEvent('_simplechat:builtin', 'ooc', raw)
        end
    end

    cb('ok')
    chatOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'chat:close'
    })
end)

RegisterNUICallback('chat:escape', function(_, cb)
    chatOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'chat:close'
    })
    cb('ok')
end)

-- ===== Default chat API compatibility =====
RegisterNetEvent('chat:addMessage', function(data)
    SendNUIMessage({
        type = 'chat:addMessage',
        template = data.template,
        color = data.color or {255, 255, 255},
        args = data.args or {'System', ''}
    })
end)

RegisterNetEvent('chat:clear', function()
    SendNUIMessage({
        type = 'chat:clear'
    })
end)

RegisterNetEvent('chat:addSuggestion', function(name, help, params)
    SendNUIMessage({
        type = 'chat:addSuggestion',
        name = name,
        help = help or '',
        params = params or {}
    })
end)

RegisterNetEvent('chat:removeSuggestion', function(name)
    SendNUIMessage({
        type = 'chat:removeSuggestion',
        name = name
    })
end)

-- ===== Our broadcast -> UI =====
RegisterNetEvent('simplechat:show', function(payload)
    SendNUIMessage({
        type = 'simplechat:add',
        data = payload
    })
end)

-- ======================================================
-- INITIALIZATION / AUTO REQUEST COMMANDS
-- ======================================================
CreateThread(function()
    Wait(2000)
    TriggerServerEvent('simplechat:requestSuggestions')
end)

--------------------------------------------
-- UPDATE BUILT-IN COMMAND VISIBILITY
--------------------------------------------
RegisterNetEvent('simplechat:updateBuiltInConfig', function(builtIns, order)
    SendNUIMessage({
        type = 'chat:updateBuiltIns',
        builtIns = builtIns,
        commandOrder = order
    })
end)

RegisterNetEvent('simplechat:template', function(payload)
    SendNUIMessage({
        type = 'simplechat:addTemplate',
        data = payload
    })
end)

RegisterNetEvent('simplechat:inline', function(payload)
    SendNUIMessage({
        type = 'simplechat:addInline',
        data = payload
    })
end)

-- ======================================================
-- ADD BUILT-IN RP COMMANDS LOCALLY (for fallback)
-- ======================================================
CreateThread(function()
    Wait(1000)
    if Config.BuiltInCommands.me then
        TriggerEvent('chat:addSuggestion', '/me', 'Perform a local action', {{
            name = 'action',
            help = 'What you do'
        }})
    end
    if Config.BuiltInCommands['do'] then
        TriggerEvent('chat:addSuggestion', '/do', 'Describe surroundings or RP details', {{
            name = 'context',
            help = 'What others would see'
        }})
    end
    if Config.BuiltInCommands.gme then
        TriggerEvent('chat:addSuggestion', '/gme', 'Global action (admin/scene use)', {{
            name = 'info',
            help = 'Describe event'
        }})
    end
    if Config.BuiltInCommands.ooc then
        TriggerEvent('chat:addSuggestion', '/ooc', 'Out of character chat', {{
            name = 'message',
            help = 'What you say OOC'
        }})
    end
end)
