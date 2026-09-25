# Akbar UI Framework

A sleek, glassmorphic interface engine for Roblox Luau[span_0](start_span)[span_0](end_span)[span_1](start_span)[span_1](end_span). Engineered for high frame-pacing, responsive mobile touch handling, auto-calculated accordion layouts, floating draggable toggle icons, and persistent JSON configurations[span_2](start_span)[span_2](end_span)[span_3](start_span)[span_3](end_span).

[![Luau](https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square)](https://luau-lang.org/)
[![Version](https://img.shields.io/badge/Version-1.1.0-3882FF?style=flat-square)]()
[![Tested](https://img.shields.io/badge/Environment-Delta%20%7C%20Codex%20%7C%20Wave-3882FF?style=flat-square)]()
[![Platform](https://img.shields.io/badge/Platform-Mobile%20%2F%20PC-1e1e2e?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## Bootstrapper

Jalankan framework langsung via `loadstring`:

```lua
local Akbar = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua)"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "v1.1.0",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    OpenButton = {
        Icon = "crown",
        Position = UDim2.new(0, 16, 0, 16)
    },
    Loading = {
        Enabled = true,
        Title = "AKBAR UI",
        Text = "Memuat sistem...",
        Duration = 1.5
    }
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Desc = "Automation overview",
    Icon = "anchor"
})

local FarmGroup = MainTab:CreateCollapsible({
    Name = "Auto Farm",
    Desc = "Pengaturan otomatisasi",
    Icon = "bot",
    Open = true
})

FarmGroup:CreateToggle({
    Name = "Enable Loop",
    Desc = "Jalankan auto farm utama",
    CurrentValue = false,
    Flag = "AutoFarmFlag",
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
```

---

## Fitur Utama

- **Top-Left Floating Toggle:** Tombol ikon buka/tutup di pojok kiri atas yang responsif untuk sentuhan HP (bisa digeser/drag) dan klik PC.
- **Glassmorphism Design:** Tampilan modern semi-transparan dengan aksen warna dinamis dan border lembut.
- **Auto Configuration Manager:** Simpan dan muat status fitur ke file JSON secara otomatis.
- **Mobile & PC Responsive:** Pengaturan posisi otomatis agar tidak keluar batas layar viewport kamera.
- **Event-Cleaned Architecture:** Proteksi terhadap kebocoran memori (memory leak) saat script dieksekusi berulang kali.

---

## Komponen API

### 1. Inisialisasi Window
```lua
local Window = Akbar:CreateWindow({
    Name = "Judul Window",
    LoadingSubtitle = "Subjudul",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(760, 520),
    MinSize = Vector2.new(480, 360),
    MaxSize = Vector2.new(1100, 750),
    KeepOnScreen = true,
    Accordion = false
})
```

### 2. Tab & Collapsible Group
```lua
local Tab = Window:CreateTab({
    Name = "Tab 1",
    Desc = "Deskripsi Tab",
    Icon = "home"
})

local Group = Tab:CreateCollapsible({
    Name = "Group Menu",
    Desc = "Sub-kategori fitur",
    Icon = "wrench",
    Open = false
})
```

### 3. Elemen Interaktif (Button, Slider, Stepper)
```lua
Tab:CreateButton({
    Name = "Execute",
    Desc = "Menjalankan fungsi instan",
    Icon = "zap",
    Style = "Primary",
    Callback = function()
        print("Executed!")
    end
})

Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Suffix = " spd",
    Flag = "WalkSpeedFlag",
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

Tab:CreateStepper({
    Name = "Multiplier",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 1,
    Flag = "MultiplierFlag",
    Callback = function(v)
        print("Multiplier:", v)
    end
})
```

### 4. Dropdown & Color Picker
```lua
Tab:CreateDropdown({
    Name = "Pilih Mode",
    Options = {"Safe", "Legit", "Rage"},
    CurrentOption = "Safe",
    MultipleOptions = false,
    Flag = "ModeFlag",
    Callback = function(selected)
        print("Mode aktif:", selected)
    end
})

Tab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(56, 130, 255),
    Flag = "ESPColorFlag",
    Callback = function(col)
        print("Warna diubah:", col)
    end
})
```

### 5. Input Box & Keybind
```lua
Tab:CreateInput({
    Name = "Teleport Target",
    PlaceholderText = "Masukkan username...",
    Numeric = false,
    Flag = "TargetFlag",
    Callback = function(text, enterPressed)
        print("Input:", text)
    end
})

Tab:CreateKeybind({
    Name = "Toggle Keybind",
    CurrentKeybind = "E",
    Flag = "BindFlag",
    Callback = function(key)
        print("Key ditekan!")
    end
})
```

### 6. Modal Dialog & Konfirmasi
```lua
Window:Confirm({
    Title = "Reset Data",
    Content = "Apakah kamu yakin ingin mengatur ulang data?",
    ConfirmText = "Ya",
    CancelText = "Batal",
    Callback = function(confirmed)
        if confirmed then
            print("Pengaturan di-reset")
        end
    end
})
```

---

## Daftar Icon Bawaan

Kamu bisa langsung menulis nama icon berikut ke dalam konfigurasi komponen:

`crown`, `anchor`, `fish`, `pickaxe`, `bot`, `sprout`, `settings`, `home`, `info`, `user`, `users`, `zap`, `shield`, `wrench`, `refresh-cw`, `layout-dashboard`, `scroll-text`, `search`, `palette`, `save`, `check`, `x`, `minus`, `maximize`, `chevron-down`, `chevron-up`.

---

## Lisensi

Didistribusikan di bawah Lisensi MIT. Bebas digunakan dan dimodifikasi untuk proyek pribadi maupun publik.
