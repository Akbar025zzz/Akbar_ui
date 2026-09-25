# Akbar UI

A sleek, glassmorphic interface engine for Roblox Luau. Engineered for high frame-pacing, responsive mobile touch handling, auto-calculated accordion layouts, and persistent runtime states.

[![Luau](https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square)](https://luau-lang.org/)
[![Tested](https://img.shields.io/badge/Environment-Delta%20%7C%20Codex%20%7C%20Wave-3882FF?style=flat-square)]()
[![Platform](https://img.shields.io/badge/Platform-Mobile%20%2F%20PC-1e1e2e?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## Bootstrapper

Execute the framework directly via `loadstring`:

```lua
local Akbar = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua)"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "v1.0.0",
    Icon = "crown",
    ToggleUIKeybind = "RightControl"
})

local Main = Window:CreateTab({
    Name = "Main",
    Desc = "Automation overview",
    Icon = "anchor"
})

local Group = Main:CreateCollapsible({
    Name = "Auto Farm",
    Desc = "Primary parameters",
    Icon = "bot",
    Open = true
})

Group:CreateToggle({
    Name = "Enable Loop",
    CurrentValue = false,
    Callback = function(val)
        print("[Akbar] State:", val)
    end
})

Window:Notify({
    Title = "Akbar UI",
    Content = "Engine initialized.",
    Duration = 3,
    Icon = "crown"
})
