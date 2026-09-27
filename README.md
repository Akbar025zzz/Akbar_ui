# Akbar UI Framework

UI library untuk Roblox Luau bergaya **dark glassmorphism**, responsif di PC & mobile.

- Ringan, satu file, tinggal `loadstring`
- Live theme system — ganti warna, semua elemen ikut update otomatis
- 10 preset warna siap pakai
- Config save/load bawaan (tersimpan ke file lewat executor)
- Dukungan penuh touch/mobile (drag, resize, auto-fit)

## Instalasi

```lua
local Akbar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua"))()
```

## Quick Start

```lua
local Akbar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar Hub",
    Subtitle = "v3.0.0",
    Icon = "crown",
    ToggleKey = "RightControl",
    Size = UDim2.fromOffset(760, 520),
})

local Tab = Window:CreateTab("Main", "home")

Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Aktifkan auto farm",
    Default = false,
    Flag = "autoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end,
})

Tab:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "walkSpeed",
    Callback = function(value) end,
})

Tab:Button({
    Title = "Simpan Config",
    Callback = function()
        Window:SaveConfig("default")
    end,
})
```

## Komponen yang tersedia

Semua komponen dibuat lewat `Tab:NamaKomponen({...})`:

| Komponen | Fungsi |
|---|---|
| `Section(c)` | Grup collapsible (accordion) untuk mengelompokkan elemen |
| `Toggle(c)` | Saklar on/off |
| `Slider(c)` | Slider angka, ada `OnRelease` dan tooltip nilai |
| `Dropdown(c)` | Dropdown single/multi-select dengan search |
| `Button(c)` | Tombol — anti-spam-klik & callback dibungkus `pcall` |
| `Checklist(c)` | Daftar checkbox |
| `Label(c)` | Teks label sederhana |
| `Paragraph(c)` | Teks panjang/deskripsi |
| `Divider()` | Garis pemisah antar grup |
| `Image(c)` | Menampilkan gambar/ikon |
| `Console(c)` | Panel log — `Console:Print(text)` / `Console:Warn(text)` |
| `Spinner(c)` | Loading spinner |
| `Keybind(c)` | Input untuk bind tombol keyboard |
| `ColorPicker(c)` | Pemilih warna (RGB/Hex) |
| `Input(c)` | Kotak input teks |
| `Stepper(c)` | Stepper angka (tombol +/-) |
| `Progress(c)` | Progress bar |
| `Tooltip(c)` | Tooltip statis |
| `ThemePicker(c)` | Selector untuk ganti preset tema langsung dari UI |

## Window API

```lua
Window:Toggle() / Show() / Hide() / IsVisible()
Window:Center()
Window:SetSize(size) / GetSize()
Window:SetMinSize(min) / SetMaxSize(max)
Window:SetTitle(text) / SetSubtitle(text) / SetIcon(iconAsset)
Window:SetToggleKey(key)
Window:SetAccordion(state)
Window:SetSearchEnabled(enabled)

Window:SaveConfig(name) / LoadConfig(name) / DeleteConfig(name) / ListConfigs()
Window:AddConfigTab()

Window:Notify({ Title, Text, Duration, Type })
Window:Confirm({ Title, Text, OnConfirm, OnCancel })
Window:Dialog({ ... })

Window:CreateTab(nameOrConfig, icon)
Window:Destroy()
```

## Tema & Preset Warna

```lua
Akbar:SetTheme({ Accent = Color3.fromRGB(255, 0, 0) })
Akbar:SetAccentColor(Color3.fromRGB(255, 0, 0))
Akbar:SetPreset("Royal Purple")   -- lihat daftar di bawah
Akbar:ListPresets()
Akbar:SetAnimations(true)          -- matikan/nyalakan animasi tween
Akbar:RefreshTheme()
Akbar:DestroyAll()                 -- hancurkan semua window aktif
```

Preset bawaan: `Default Blue`, `Royal Purple`, `Crimson Red`, `Emerald Green`,
`Sunset Orange`, `Ocean Teal`, `Midnight Pink`, `Cotton Candy`, `Cyber Lime`, `Deep Violet`.

## Icon

Library sudah include 100+ ikon siap pakai (`"crown"`, `"home"`, `"settings"`, `"shield"`, dll) via `rbxassetid`, dan mendukung spritesheet custom lewat `IconLib:RegisterSpritesheet(name, assetId, iconData)`.

## Kompatibilitas

Mendukung executor dengan `writefile`/`readfile` untuk config permanen; kalau tidak ada, config otomatis fallback ke `_G` (tidak permanen antar sesi). Auto-detect mobile (touch tanpa mouse) untuk resize & posisi UI otomatis.

## Lisensi

MIT — bebas dipakai & dimodifikasi, kredit dihargai.

---
Dibuat oleh **King Akbar**. Kontribusi & laporan bug lewat [issue GitHub](https://github.com/Akbar025zzz/Akbar_ui/issues).
