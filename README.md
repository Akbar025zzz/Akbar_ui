# 👑 AKBAR UI (King Akbar)

Modern Dark Glassmorphism UI Framework untuk Roblox Luau yang dirancang ringan, responsif untuk PC & Mobile (Touch), serta memiliki sistem animasi Collapsible / Accordion yang mulus.

---

## ⚡ Quick Start

Tempelkan script berikut ke executor atau script Roblox Anda:

```lua
local Akbar = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua)"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "King Akbar",
    Icon = "crown",
    ToggleUIKeybind = "RightControl"
})
