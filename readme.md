# 💬 SimpleChat

A sleek, modern, and fully customizable **chat system for FiveM** — built by *SimpleDevelopments*.
This chat isn’t just a replacement — it’s an upgrade. It supports message templates, embedded icons, inline messages, Discord logging, custom command systems, and smooth NUI transitions.

---

## 🧩 Features

* 🖥️ **Modern UI** — Tablet-style transparent chat window with blurred background.
* 💡 **Built-In Commands** — `/me`, `/do`, `/gme`, `/ooc` (toggleable individually via config).
* ⚙️ **Fully Configurable** — Everything from colors to built-ins, webhook, bot details, etc.
* 🔗 **Custom Exports** — Trigger inline or template messages from *any* other script.
* 🪄 **Discord Webhook Logging** — Automatically logs all chat commands with identifiers.
* 🔍 **Command Suggestions** — Dynamically synced for all players and resources.
* 🧱 **Lightweight & Optimized** — 0.00ms idle, runs clean even under heavy chat load.

---

## 📁 Configuration

Located in `config.lua`:

```lua
Config = {
    Debug = false,

    -- Webhook settings
    EnableDiscordLogging = true,
    WebhookURL = "YOUR_WEBHOOK_URL_HERE",
    BotName = "SimpleChat Logger",
    BotAvatar = "https://i.imgur.com/VZLrHkZ.png",

    -- Built-in chat commands (toggle individually)
    BuiltInCommands = {
        me = true,
        ['do'] = true,
        gme = true,
        ooc = true
    },

    -- Header order for visible /commands
    CommandDisplayOrder = { "me", "do", "gme", "ooc" },

    -- Delay before syncing suggestions when joining
    SuggestionSyncDelay = 2500,

    -- Embed colors per type (for Discord logs)
    EmbedColors = {
        me = 0xB366FF,
        ['do'] = 0x60A5FA,
        gme = 0xEC4899,
        ooc = 0x9CA3AF,
        text = 0x60A5FA
    }
}
```

---

## ⚙️ Exports

SimpleChat includes **powerful exports** that let other scripts interact with chat seamlessly.

### 🧾 `SendTemplateMessage(data)`

Creates a **card-style message** (like a 911 or dispatch alert).

**Parameters:**

| Field     | Type     | Description               |
| --------- | -------- | ------------------------- |
| `icon`    | `string` | Emoji or FontAwesome icon |
| `title`   | `string` | Message header title      |
| `message` | `string` | Main message text         |
| `color`   | `table`  | RGB table `{r, g, b}`     |

**Example:**

```lua
exports['SimpleChat']:SendTemplateMessage({
    icon = '🚨',
    title = '911 Call',
    message = 'Shots fired near Legion Square!',
    color = {255, 50, 50}
})
```

---

### 💭 `SendInlineMessage(data)`

Sends a **chat-style bubble message** with a custom icon and color (matches `/me`, `/do` style).

**Parameters:**

| Field   | Type     | Description               |
| ------- | -------- | ------------------------- |
| `name`  | `string` | Name or source label      |
| `icon`  | `string` | Emoji or FontAwesome icon |
| `text`  | `string` | Chat message content      |
| `color` | `table`  | RGB table `{r, g, b}`     |

**Example:**

```lua
exports['SimpleChat']:SendInlineMessage({
    name = 'News',
    icon = '📰',
    text = 'Breaking: City council passed new laws today!',
    color = {80, 180, 255}
})
```

---

### 📡 `SendDiscordLog(data)`

Sends a Discord embed log with your configured webhook and formatting.

**Parameters:**

| Field        | Type     | Description                                      |
| ------------ | -------- | ------------------------------------------------ |
| `playerId`   | `number` | Player source ID (optional if `playerName` used) |
| `playerName` | `string` | Fallback name if no player                       |
| `title`      | `string` | Embed title                                      |
| `command`    | `string` | Command or context name                          |
| `message`    | `string` | Message contents                                 |
| `color`      | `number` | Embed color (hex)                                |

**Example:**

```lua
exports['SimpleChat']:SendDiscordLog({
    playerId = source,
    title = "911 Command Used",
    command = "/911",
    message = "Shots fired near Legion Square",
    color = 0xFF3030
})
```

---

## 🧠 Example Custom Commands

Use these examples to quickly create commands that show messages via SimpleChat:

```lua
-- /911 <message>
RegisterCommand('911', function(source, args)
    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"SYSTEM", "Usage: /911 <message>"},
            color = {255, 0, 0}
        })
        return
    end

    exports['SimpleChat']:SendTemplateMessage({
        icon = '🚨',
        title = '911 Call',
        message = msg,
        color = {255, 45, 45}
    })

    exports['SimpleChat']:SendDiscordLog({
        playerId = source,
        title = "911 Command Used",
        command = "/911",
        message = msg,
        color = 0xFF3030
    })
end)
```

---

## 💬 Example `/news` Inline Command

```lua
RegisterCommand('news', function(source, args)
    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"SYSTEM", "Usage: /news <message>"},
            color = {80, 180, 255}
        })
        return
    end

    exports['SimpleChat']:SendInlineMessage({
        name = 'News',
        icon = '📰',
        text = msg,
        color = {80, 180, 255}
    })
end)
```

---

## 🧱 Developer Notes

* Message templates render safely (HTML args are escaped).
* Commands support full Unicode (emojis, symbols, etc.).
* You can expand exports into jobs, dispatch systems, admin alerts, or event logs.
* Works standalone — no dependency on ESX/QBCore/NDCore.

---

## 🧩 Credits

Built with ❤️ by **SimpleDevelopments**
[https://simpledevelopments.org](https://simpledevelopments.org)
Discord: [SimpleDevelopments](https://discord.gg/simpledev)

---
