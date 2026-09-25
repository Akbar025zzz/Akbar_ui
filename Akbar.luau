local Akbar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/Akbar.luau"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar - Indo Hangout",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(640, 480),
})

local MainTab = Window:CreateTab({ Name = "Main", Icon = "M" })
local InfoTab = Window:CreateTab({ Name = "Info", Icon = "i" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "S" })

-- Collapsible Group #1
local fishingGroup = MainTab:Collapsible({ Name = "Auto Fishing Settings" })
fishingGroup:Toggle({
    Title = "Auto Fishing",
    Description = "Otomatis memancing ikan",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(v) print("Auto Fishing:", v) end,
})

-- Collapsible Group #2
local miningGroup = MainTab:Collapsible({ Name = "Auto Mining Settings" })
miningGroup:Toggle({
    Title = "Auto Mining",
    Description = "Otomatis menambang",
    CurrentValue = false,
    Flag = "AutoMining",
    Callback = function(v) print("Auto Mining:", v) end,
})
miningGroup:Slider({
    Title = "Mining Speed",
    Range = { 1, 10 },
    CurrentValue = 5,
    Suffix = "x",
    Flag = "MiningSpeed",
    Callback = function(v) print("Speed:", v) end,
})

-- Elemen tambahan
SettingsTab:Section("General")
SettingsTab:Button({
    Title = "Reset Character",
    Description = "Respawn ke spawn point",
    Style = "Primary",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then char:BreakJoints() end
    end,
})
SettingsTab:Input({
    Title = "Player Name", PlaceholderText = "type here...",
    Callback = function(t) print("Input:", t) end,
})
SettingsTab:Dropdown({
    Title = "Camera Mode",
    Options = { "Classic", "Follow", "Orbital", "Track" },
    CurrentOption = "Classic",
    Callback = function(o) print("Camera:", o) end,
})

InfoTab:Label({ Text = "Akbar UI v1.1 loaded successfully!" })

Window:Notify({
    Title = "Welcome",
    Content = "Akbar UI loaded!",
    Type = "Success",
    Duration = 4,
})
