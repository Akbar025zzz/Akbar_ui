-- Memuat UI Library (Gunakan require() jika di dalam Studio atau loadstring jika via executor)
local Akbar = require(script.Parent:WaitForChild("AkbarUI"))

-- 1. Inisialisasi Window Utama "King Akbar"
local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "King Akbar",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(760, 520),
    MinSize = Vector2.new(500, 380),
    MaxSize = Vector2.new(1050, 720),
    KeepOnScreen = true,
    Accordion = false, -- Ubah ke true jika ingin hanya satu collapsible yang terbuka dalam satu waktu
    OpenButton = {
        Title = "Akbar",
        Icon = "crown"
    },
    Loading = {
        Enabled = true,
        Title = "AKBAR UI",
        Text = "Starting",
        Steps = {
            "Preparing interface",
            "Loading components",
            "Almost ready"
        },
        Duration = 1.5
    },
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AkbarUI",
        FileName = "default"
    }
})

-- 2. TAB: Main
local Main = Window:CreateTab({
    Name = "Main",
    Desc = "Main features & automation",
    Icon = "anchor"
})

-- Collapsible 1: Auto Fishing Settings
local Fishing = Main:CreateCollapsible({
    Name = "Auto Fishing Settings",
    Desc = "Fishing configuration & locations",
    Icon = "fish",
    Open = false
})

Fishing:CreateToggle({
    Name = "Auto Fishing",
    Desc = "Automatically casts and reels in",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(Value)
        print("[AKBAR UI] Auto Fishing:", Value)
    end
})

Fishing:CreateToggle({
    Name = "Auto Sell",
    Desc = "Sells inventory when full",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        print("[AKBAR UI] Auto Sell:", Value)
    end
})

Fishing:CreateDropdown({
    Name = "Fishing Location",
    Options = { "Beach", "River", "Ocean", "Deep Sea Lake" },
    CurrentOption = "Beach",
    Flag = "FishingLocation",
    Callback = function(Value)
        print("[AKBAR UI] Fishing Location:", Value)
    end
})

Fishing:CreateSlider({
    Name = "Fishing Delay",
    Desc = "Delay between consecutive casts",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = " sec",
    CurrentValue = 1.0,
    Flag = "FishingDelay",
    Callback = function(Value)
        print("[AKBAR UI] Delay:", Value)
    end
})

-- Collapsible 2: Auto Mining Settings
local Mining = Main:CreateCollapsible({
    Name = "Auto Mining Settings",
    Desc = "Ore farming & cave paths",
    Icon = "pickaxe",
    Open = false
})

Mining:CreateToggle({
    Name = "Auto Mining",
    CurrentValue = false,
    Flag = "AutoMining",
    Callback = function(Value)
        print("[AKBAR UI] Auto Mining:", Value)
    end
})

Mining:CreateDropdown({
    Name = "Mining Target",
    Options = { "Iron", "Gold", "Diamond", "Ancient Scrap" },
    CurrentOption = "Iron",
    Flag = "MiningTarget",
    Callback = function(Value)
        print("[AKBAR UI] Mining Target:", Value)
    end
})

Mining:CreateStepper({
    Name = "Mining Radius",
    Range = {5, 100},
    Increment = 5,
    CurrentValue = 25,
    Callback = function(Value)
        print("[AKBAR UI] Mining Radius:", Value)
    end
})

-- Collapsible 3: Auto Farming Settings
local Farming = Main:CreateCollapsible({
    Name = "Auto Farming Settings",
    Desc = "Crops & harvester automation",
    Icon = "sprout",
    Open = false
})

Farming:CreateToggle({
    Name = "Auto Harvest Crops",
    CurrentValue = false,
    Flag = "AutoHarvest",
    Callback = function(Value)
        print("[AKBAR UI] Auto Harvest:", Value)
    end
})

Farming:CreateProgress({
    Name = "Harvest Bag Capacity",
    CurrentValue = 0.45,
    Format = function(val)
        return math.floor(val * 100) .. "% Full"
    end
})

-- 3. TAB: Info
local Info = Window:CreateTab({
    Name = "Info",
    Desc = "System information & overview",
    Icon = "info"
})

Info:CreateSection("Hardware & Environment")

Info:CreateLabel({
    Text = "Players Online: ...",
    UpdateRate = 2,
    Update = function()
        return "Players Online: " .. #game:GetService("Players"):GetPlayers()
    end
})

Info:CreateParagraph({
    Title = "AKBAR UI Framework",
    Content = "High-performance Luau interface crafted with dark glassmorphism, responsive touch coordinates, and accordion collapsible architecture."
})

-- 4. TAB: Settings
local Settings = Window:CreateTab({
    Name = "Settings",
    Desc = "Interface configuration & themes",
    Icon = "settings"
})

Settings:CreateSection("Preferences")

Settings:CreateToggle({
    Name = "Accordion Mode",
    Desc = "Close open groups when another is clicked",
    CurrentValue = false,
    Callback = function(Value)
        Window:SetAccordion(Value)
    end
})

Settings:CreateToggle({
    Name = "UI Smooth Animations",
    Desc = "Toggle TweenService transitions",
    CurrentValue = true,
    Callback = function(Value)
        Akbar:SetAnimations(Value)
    end
})

Settings:CreateKeybind({
    Name = "Toggle Menu Key",
    CurrentKeybind = "RightControl",
    OnChanged = function(newKey)
        print("[AKBAR UI] New toggle keybind:", newKey)
    end
})

Settings:CreateDivider()

Settings:CreateButton({
    Name = "Save Current Configuration",
    Desc = "Persist current flags to storage",
    Icon = "save",
    Style = "Primary",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({
            Title = "Akbar UI",
            Content = "Configuration has been saved successfully.",
            Duration = 3,
            Icon = "check"
        })
    end
})

Settings:CreateButton({
    Name = "Reset Configuration",
    Desc = "Restore default settings",
    Icon = "refresh-cw",
    Callback = function()
        Window:Confirm({
            Title = "Reset Defaults",
            Content = "Are you sure you want to delete and reset your saved config?",
            ConfirmText = "Reset",
            CancelText = "Keep",
            Callback = function(Confirmed)
                if Confirmed then
                    Window:DeleteConfig("default")
                    Window:Notify({
                        Title = "Config Reset",
                        Content = "Config removed.",
                        Duration = 3,
                        Icon = "check"
                    })
                end
            end
        })
    end
})

-- 5. Berikan Notifikasi Selamat Datang
Window:Notify({
    Title = "AKBAR UI",
    Content = "Interface successfully loaded! Welcome, King Akbar.",
    Duration = 4,
    Icon = "crown"
})
