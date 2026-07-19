<div align="center">

# 💬 SimpleChat

### A modern, customizable standalone chat replacement for FiveM.

<p>
  <a href="https://simpledevelopments.org/store"><img src="https://img.shields.io/badge/Explore_Our_Store-5865F2?style=for-the-badge&logo=googlechrome&logoColor=white" /></a>
  <a href="https://discord.gg/RquDVTfDwu"><img src="https://img.shields.io/badge/Join_Our_Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/Fadinlaws123/SimpleChat"><img src="https://img.shields.io/badge/View_on_GitHub-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
</p>

<p>
  <img src="https://img.shields.io/badge/FiveM-Standalone-FF6B35?style=flat-square&logo=fivem&logoColor=white" />
  <img src="https://img.shields.io/badge/Framework-No_Dependency-238636?style=flat-square" />
  <img src="https://img.shields.io/badge/Status-Release_Ready-238636?style=flat-square" />
  <img src="https://img.shields.io/github/stars/Fadinlaws123/SimpleChat?style=flat-square&logo=github&label=Stars" />
</p>

</div>

---

## 📖 About

**SimpleChat** is a standalone FiveM chat system built around a modern NUI interface, configurable roleplay commands, custom message templates, external resource exports, and optional Discord logging.

It can be used as a full chat replacement while also providing reusable exports for other resources that need to display styled messages or send related logs.

---

## ✨ Features

- Modern custom NUI chat interface
- Built-in `/me`, `/do`, `/gme`, and `/ooc` commands
- Individually toggleable built-in commands
- Dynamic command suggestions
- Custom template-style messages
- Inline chat messages
- Discord webhook logging
- Configurable embed colors and webhook settings
- Exports for other FiveM resources
- Standalone with no ESX, QBCore, or NDCore dependency

---

## ⚙️ Configuration

Configuration is handled through `config.lua`, including:

- Debug mode
- Discord logging
- Webhook URL and bot appearance
- Built-in command toggles
- Command display order
- Suggestion sync delay
- Discord embed colors

Keep live webhook URLs private and do not commit them to a public repository.

---

## 🔌 Exports

### `SendTemplateMessage(data)`

Displays a card-style message through SimpleChat.

```lua
exports['SimpleChat']:SendTemplateMessage({
    icon = '🚨',
    title = '911 Call',
    message = 'Shots fired near Legion Square!',
    color = {255, 50, 50}
})
```

### `SendInlineMessage(data)`

Displays a compact inline chat message.

```lua
exports['SimpleChat']:SendInlineMessage({
    name = 'News',
    icon = '📰',
    text = 'Breaking news from across the city.',
    color = {80, 180, 255}
})
```

### `SendDiscordLog(data)`

Sends a formatted Discord log through the webhook configured by SimpleChat.

```lua
exports['SimpleChat']:SendDiscordLog({
    playerId = source,
    title = 'Command Used',
    command = '/example',
    message = 'Example message',
    color = 0x60A5FA
})
```

---

## 📥 Installation

1. Place `SimpleChat` in your server's resources directory.
2. Configure `config.lua`.
3. Add the following to your `server.cfg`:

```cfg
ensure SimpleChat
```

4. Restart the resource or server.

---

## 📋 Requirements

- FiveM server
- No framework required
- No database required

---

## 🌐 SimpleDevelopments

SimpleChat is developed and maintained by **SimpleDevelopments**.

<div align="center">

### Keep it Simple. Keep it SimpleDevelopments.

</div>
