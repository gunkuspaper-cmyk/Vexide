# Vexide-MM2

Vexide-MM2 is a Murder Mystery 2 script hub built with [WindUI](https://github.com/Footagesus/WindUI). It provides combat helpers, ESP, movement options, teleports, automation, and misc utilities in a modern, transparent UI.

**Toggle UI:** Insert

---

## Features

### Main
- Silent Aim — Sheriff shots lock onto the murderer
- Auto Shoot — Automatically fire at the murderer
- Kill All — Teleport to every player (Murderer only)
- Auto Coins — Farm all coins on the map
- Knife Aura — Auto attack nearby players
- Auto Grab Gun — Pick up dropped gun automatically
- Hitbox Size — Expand player hitboxes
- Announce Roles — Say murderer and sheriff in chat
- Spectate Murderer — View from the murderer's perspective
- Auto Dodge — Escape when the murderer is close

### Visuals
- Role ESP — Highlight Murderer and Sheriff
- Gun Drop ESP — Highlight dropped guns
- Murderer Tracer — Line to the murderer
- Name Tags — Show player names
- Fullbright
- No Fog
- Crosshair
- Coin ESP
- Proximity Alert — Notify when the murderer is near
- Rainbow Tool — Rainbow color on held tool

### Movement
- Walk Speed
- Jump Power
- Fly
- Noclip
- Bunny Hop
- Infinite Jump
- Spinbot
- Low Gravity
- Fake Lag
- Ghost Mode

### Teleports
- TP to Murderer
- TP to Sheriff
- TP to Gun
- TP to Lobby
- TP Above Map
- Click TP (Ctrl + Click)

### Automation
- FPS Booster — Low graphics mode
- Mute Sounds
- X-Ray Walls
- Auto Rejoin
- Fake Knife

### Misc
- Auto Clicker
- Anti-AFK
- FOV
- Copy Job ID
- Server Hop
- UI Transparency
- Reset Position
- Chat Spam
- Max Zoom

---

## Installation

1. Use a Roblox executor that supports `loadstring` and `HttpGet`.
2. Paste the full script and execute.
3. Press **Insert** to open or close the UI.

```lua
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/gunkuspaper-cmyk/Vexide/refs/heads/main/MAIN"))()
--
```

The UI is powered by WindUI and loads automatically from GitHub on run.

---

## Requirements

- Roblox executor with:
  - `loadstring`
  - `HttpGet`
  - Optional: `getrawmetatable`, `setclipboard`, `mouse1click`, `newcclosure` (for full feature support)
- Internet access (WindUI is fetched at runtime)

---

## Notes

- Designed for Murder Mystery 2.
- Some features only work in specific roles (e.g. Kill All requires the knife).
- UI transparency is adjustable in the Misc tab.
- Window can be dragged; use Reset Position to center it.

---

## Credits

- UI Library: [WindUI](https://github.com/Footagesus/WindUI) by Footagesus
- Script: Vexide-MM2

---

## Disclaimer

This script is for educational purposes only. Use at your own risk. The authors are not responsible for any account penalties or bans that may result from using third-party scripts.
