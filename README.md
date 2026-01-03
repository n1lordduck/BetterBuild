# BetterBuild

BetterBuild is a lightweight sandbox **build mode system** for Garry’s Mod.

It allows players to toggle a dedicated **Build Mode**, preventing damage, handling PvP cooldowns, restricting noclip, and clearly showing who is currently building — while remaining multiplayer-safe and compatible with servers where clients may not have the addon installed.

---

## Features

- Toggleable build mode via chat commands or console
- Prevents player damage while in build mode
- Prevents prop-kill and vehicle damage from builders
- Optional PvP detection with cooldown
- Optional noclip restriction outside build mode
- Billboard text above players in build mode
- Server-wide announcements when players enter or leave build mode
- Customizable message colors and text
- CPPI-compatible prop ownership detection
- Safe fallbacks for clients without the addon installed

---

## Usage

### Chat Commands
- `!build` — Toggle build mode
- `!pvp` — Leave or toggle build mode

### Console Command
- `build_mode` — Toggle build mode

> Players cannot enter build mode while in combat if PvP detection is enabled.

---

## Configuration (ConVars)

### Shared / Client-visible

| ConVar | Description | Default |
|------|------------|---------|
| `betterbuild_text` | Text displayed above players in build mode | `"Building"` |
| `betterbuild_font` | Font used for the billboard text | `"DermaDefault"` |
| `betterbuild_textcolor` | RGB color of the build text | `"255, 165, 0"` |
| `betterbuild_pvpWarningMessage` | Message shown when entering build during combat | `"You can't join build mode while in combat!"` |

---

### Server-side

| ConVar | Description | Default |
|------|------------|---------|
| `betterbuild_enterBuildCommand` | Chat command to toggle build mode | `!build` |
| `betterbuild_enterLeaveCommand` | Alternate chat command | `!pvp` |
| `betterbuild_chatCooldown` | Cooldown between chat command uses (seconds) | `5` |
| `betterbuild_detectPVP` | Enable PvP detection | `true` |
| `betterbuild_pvpCooldown` | PvP cooldown duration (seconds) | `60` |
| `betterbuild_allowNoclipOutsideBuildMode` | Allow noclip outside build mode | `false` |

---

### Announcements

| ConVar | Description | Default |
|------|------------|---------|
| `betterbuild_announceEnteringBuildMode` | Announce entering build mode | `true` |
| `betterbuild_announceEnterMessage` | Enter message text | `{addonprefix} {player} has entered build mode!` |
| `betterbuild_announceEnterMessageColor` | RGB color of enter message | `255 255 255` |
| `betterbuild_announceExitingBuildMode` | Announce leaving build mode | `true` |
| `betterbuild_announceExitMessage` | Exit message text | `{addonprefix} {player} has left build mode!` |
| `betterbuild_announceExitMessageColor` | RGB color of exit message | `255 255 255` |

Supported placeholders:
- `{player}` — Player name
- `{addonprefix}` — Optional addon prefix

---

## Compatibility

- Compatible with CPPI-based prop protection
- Graceful fallback if no prop protection is installed
- Clients without the addon will not error or crash
- Safe for multiplayer environments

---

## Installation

1. Subscribe on the Steam Workshop **or**
2. Clone/download this repository into: garrysmod/addons/betterbuild
3. Restart the server 

---

## Bug Reports & Contributions

Found a bug or want to suggest an improvement?

Please open an issue and include:
- What happened
- Steps to reproduce
- Any console errors or warnings

GitHub repository:  
https://github.com/n1lordduck/BetterBuild

Pull requests are welcome.

---

## License

MIT License
