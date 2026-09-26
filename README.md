<div align="center">
  <img src="https://img.shields.io/badge/Version-3.0.0-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Roblox_Luau-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Mobile-Fully_Supported-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Icons-100%2B_Lucide-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Components-20%2B-green?style=for-the-badge" />
</div>

<h1 align="center">👑 Akbar UI Framework</h1>

<p align="center">
  <b>Modern Dark Glassmorphism UI Library untuk Roblox Luau</b><br>
  Ringan, cepat, dan 100% responsif (PC + Mobile) — dipakai di seluruh proyek
  <b>King Akbar</b> (Drag Race Simulator, Indo Hangout Hub, Car Driving Indonesia).
</p>

<p align="center">
  <a href="DOCS.md"><b>📖 Dokumentasi Lengkap</b></a> •
  <a href="#-contoh-script"><b>📁 Contoh Script</b></a> •
  <a href="#-instalasi"><b>📦 Instalasi</b></a> •
  <a href="#-changelog"><b>📝 Changelog</b></a>
</p>

---

## ✨ Fitur Unggulan

### 🎨 Visual
- **Dark Glassmorphism** — efek frosted glass + background blur game
- **10 Preset Warna** — ganti tema instan tanpa rebuild UI (live update)
- **100+ Icons** — Lucide icon set built-in + support custom spritesheet
- **Animasi Tactile** — press feedback di semua tombol + glow di tombol Primary
- **Hover Tooltip** — tooltip muncul saat hover di setiap komponen

### 🧩 Komponen Lengkap (20+)
- **Core:** Toggle, Slider, Dropdown (multi+search), Button, Input, Keybind
- **Visual:** ColorPicker, Stepper, Progress, Image, Divider, Label (RichText)
- **Info:** Console, Tooltip, Paragraph, Spinner, Checklist
- **Layout:** Section (accordion), Window, Tab (dengan Badge)
- **Overlay:** Notification, Confirm, Dialog, ThemePicker

### ⚙️ Sistem
- **Smart Config** — save/load otomatis per-flag dalam JSON + auto-generate Settings tab
- **Element States** — `SetDisabled()`, `SetVisible()`, `Destroy()` di semua komponen
- **Slider Enhanced** — tooltip saat drag + `CallbackOnlyOnRelease`
- **Dropdown Search** — filter otomatis kalau opsi > 8
- **Mobile Auto-Fit** — window otomatis menyesuaikan ukuran layar HP
- **Anti-Crash** — semua callback dibungkus `pcall`, error script kamu nggak bikin UI mati

---

## 📦 Instalasi

Load langsung dari GitHub pakai `loadstring` di baris paling atas script kamu:

```lua
local Akbar = loadstring(game:HttpGet(
    "[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua)"
))()
```

> ⚠️ **PENTING:** Semua method komponen **TIDAK** pakai prefix `Create`.
> Jadi `Tab:Toggle(...)`, bukan `Tab:CreateToggle(...)`.
> Hanya `Akbar:CreateWindow(...)` dan `Window:CreateTab(...)` yang pakai `Create`.

---

## 🚀 Quick Start

```lua
local Akbar = loadstring(game:HttpGet(
    "[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua)"
))()

-- 1. Buat Window
local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "Auto Farm Suite",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Blur = true,  -- blur background game saat UI aktif
    ConfigurationSaving = { Enabled = true, FolderName = "KingAkbar", FileName = "config" },
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ Name = "Utama", Icon = "home" })

-- 3. Tambah Section
local Section = Tab:Section({ Title = "Player Settings" })

-- 4. Tambah komponen
Section:Toggle({
    Title = "Auto Farm",
    Desc = "Aktifkan auto farm otomatis",
    Default = false,
    Flag = "AutoFarm",
    Tooltip = "Hover untuk info",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

Section:Slider({
    Title = "Farm Speed",
    Min = 1, Max = 10, Default = 5,
    Suffix = "x",
    ShowTooltip = true,           -- tooltip nilai saat drag
    CallbackOnlyOnRelease = true,  -- callback cuma saat lepas
    Flag = "FarmSpeed",
    Callback = function(value)
        print("Speed:", value)
    end,
})

-- 5. Auto-generate tab Settings (Save/Load/Theme UI)
Window:AddConfigTab()

-- 6. Notification
Window:Notify({
    Title = "Selamat Datang!",
    Content = "Script berhasil dimuat",
    Type = "success",
    Duration = 5,
})
```

---

## 📁 Contoh Script

Bingung mulai dari mana? Langsung copy-paste dari folder [`contoh/`](contoh):

| File | Isi |
|------|-----|
| [`contoh/dasar.lua`](contoh/dasar.lua) | Setup paling minimal — Window + Toggle + Button |
| [`contoh/auto_farm.lua`](contoh/auto_farm.lua) | UI auto farm lengkap dengan Section, Config & Keybind |
| [`contoh/full_demo.lua`](contoh/full_demo.lua) | Showcase SEMUA 20+ komponen + tema + notifikasi + dialog |
| [`contoh/console_demo.lua`](contoh/console_demo.lua) | Demo Console + Spinner + Checklist |

---

## 📖 Referensi API (Ringkas)

### Komponen

| Komponen | Contoh Pemanggilan | Method |
|----------|-------------------|---------|
| **Toggle** | `Section:Toggle({Title, Desc, Default, Flag, Tooltip, Callback})` | `Set(v)`, `Get()` |
| **Slider** | `Section:Slider({Title, Min, Max, Default, Step, Suffix, ShowTooltip, CallbackOnlyOnRelease, Flag})` | `Set(v)`, `Get()` |
| **Dropdown** | `Section:Dropdown({Title, Options, Default, Multi, Search, Flag})` | `Set(v)`, `Get()`, `Refresh(opts)`, `AddOption(opt)`, `RemoveOption(opt)` |
| **Button** | `Section:Button({Title, Primary, Height, Tooltip, Callback})` | `Set(text)` |
| **Keybind** | `Section:Keybind({Title, Default, Flag, Callback, OnChanged})` | `Set(key)`, `Get()` |
| **ColorPicker** | `Section:ColorPicker({Title, Default, Flag, Callback})` | `Set(color)`, `Get()` |
| **Input** | `Section:Input({Title, Placeholder, Default, Flag, Callback})` | `Set(text)` |
| **Stepper** | `Section:Stepper({Title, Range, Increment, CurrentValue})` | `Set(v)`, `Get()` |
| **Progress** | `Section:Progress({Title, CurrentValue, Format})` | `Set(v)` |
| **Console** | `Section:Console({Title, Height, MaxLines})` | `Log()`, `Info()`, `Warn()`, `Error()`, `Success()`, `Debug()`, `Clear()`, `GetLines()` |
| **Spinner** | `Section:Spinner({Title, Desc})` | `Start()`, `Stop()`, `SetText(text)` |
| **Checklist** | `Section:Checklist({Title, Options, Default, Flag, Callback})` | `Set(table)`, `Get()` |
| **Image** | `Section:Image({Image, Height})` | `Set(assetId)` |
| **Tooltip** | `Section:Tooltip({Title, Text})` | `Expand()`, `Collapse()` |
| **Label** | `Section:Label({Title, RichText})` | `Set(text)` |
| **Paragraph** | `Section:Paragraph({Title, Desc})` | `Set(title, desc)` |
| **Divider** | `Section:Divider()` | — |
| **ThemePicker** | `Section:ThemePicker({Title})` | — (auto-generate preset + custom color) |

### Window & Tab

| Method | Deskripsi |
|--------|-----------|
| `Window:Show()` / `Hide()` / `Toggle()` | Kontrol visibilitas |
| `Window:IsVisible()` | Returns `boolean` |
| `Window:Center()` | Posisikan di tengah layar |
| `Window:SetTitle(text)` / `SetSubtitle(text)` / `SetIcon(icon)` | Update header |
| `Window:SetBlur(bool)` | On/off background blur |
| `Window:AddConfigTab()` | Auto-generate tab Settings |
| `Window:SaveConfig(name)` / `LoadConfig(name)` / `DeleteConfig(name)` | Config manual |
| `Window:ListConfigs()` | List semua config tersimpan |
| `Window:Notify({Title, Content, Type, Duration, Icon})` | Notifikasi toast |
| `Window:Confirm({Title, Content, Callback})` | Dialog konfirmasi Yes/No |
| `Window:Dialog({Title, Content, Buttons})` | Dialog custom multi-tombol |
| `Tab:SetBadge(count)` | Badge merah di tab (0 = hide) |
| `Tab:Select()` | Pindah ke tab ini |

### Element States (Semua Komponen)

| Method | Deskripsi |
|--------|-----------|
| `Element:SetDisabled(bool)` | Abu-abu & tidak bisa diklik |
| `Element:SetVisible(bool)` | Show/hide komponen |
| `Element:Destroy()` | Hapus permanen dari UI |

### Icon System

| Method | Deskripsi |
|--------|-----------|
| `Akbar.AddIcon(name, assetId)` | Tambah custom icon |
| `IconLib:RegisterSpritesheet(name, assetId, iconMap)` | Register spritesheet |
| `IconLib:Get(iconName, size, color)` | Get icon ImageLabel |

👉 **Butuh penjelasan lengkap + semua parameter?** Baca **[DOCS.md](DOCS.md)**.

---

## 🎨 Tema & Preset Warna

```lua
-- Pakai preset (10 tersedia)
Akbar:SetPreset("Royal Purple")

-- Warna custom bebas
Akbar:SetAccentColor(Color3.fromRGB(255, 200, 0))

-- Override field tema spesifik
Akbar:SetTheme({ Background = Color3.fromRGB(10, 10, 15) })

-- Matikan animasi buat device low-end
Akbar:SetAnimations(false)

-- Refresh manual (jarang diperlukan)
Akbar:RefreshTheme()
```

**Preset bawaan:**

| Preset | Warna |
|--------|-------|
| `Default Blue` | 🔵 Biru standar |
| `Royal Purple` | 🟣 Ungu royal |
| `Crimson Red` | 🔴 Merah crimson |
| `Emerald Green` | 🟢 Hijau emerald |
| `Sunset Orange` | 🟠 Oranye sunset |
| `Ocean Teal` | 🩵 Teal ocean |
| `Midnight Pink` | 🌸 Pink midnight |
| `Cotton Candy` | 🍬 Pink pastel |
| `Cyber Lime` | 💚 Lime neon |
| `Deep Violet` | 💜 Violet gelap |

---

## 🖼️ Icon Library

100+ Lucide icons built-in. Pakai nama icon langsung di parameter `Icon`:

```lua
Window:CreateTab({ Name = "Home", Icon = "home" })
Window:CreateTab({ Name = "Settings", Icon = "settings" })
Window:CreateTab({ Name = "Players", Icon = "users" })
```

<details>
<summary>📋 <b>Daftar Icon Lengkap (klik untuk buka)</b></summary>

| Kategori | Icons |
|----------|-------|
| **Navigasi** | `home`, `anchor`, `compass`, `map-pin`, `globe`, `navigation` |
| **User** | `user`, `users`, `crown`, `heart`, `star`, `bookmark` |
| **Settings** | `settings`, `wrench`, `sliders`, `filter`, `tool`, `cog` |
| **Files** | `file`, `folder`, `save`, `copy`, `edit`, `trash`, `trash-2` |
| **UI** | `x`, `check`, `plus`, `minus`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `maximize`, `search` |
| **Komunikasi** | `mail`, `message-circle`, `message-square`, `send`, `bell`, `bell-off`, `bell-ring`, `phone` |
| **Media** | `play`, `pause`, `video`, `camera`, `image`, `music`, `volume`, `volume-2`, `volume-x`, `mic`, `mic-off`, `headphones` |
| **Tech** | `cpu`, `monitor`, `laptop`, `smartphone`, `tablet`, `tv`, `wifi`, `wifi-off`, `bluetooth`, `battery-full`, `battery-low` |
| **Data** | `database`, `server`, `hard-drive`, `cloud-download`, `cloud-upload`, `terminal`, `code` |
| **Finance** | `dollar-sign`, `credit-card`, `wallet`, `shopping-bag`, `shopping-cart`, `gift`, `ticket` |
| **Charts** | `bar-chart`, `pie-chart`, `activity`, `trending-up`, `trending-down`, `calendar`, `clock` |
| **Security** | `shield`, `lock`, `key`, `eye`, `eye-off`, `power` |
| **Status** | `circle-alert`, `circle-check`, `circle-x`, `circle-question`, `info`, `zap` |
| **Misc** | `flag`, `tag`, `rocket`, `gamepad`, `bot`, `fish`, `pickaxe`, `sprout`, `sun`, `moon`, `palette`, `link`, `share`, `download`, `upload`, `printer`, `arrow-right`, `arrow-left`, `arrow-up`, `arrow-down`, `loader-circle` |

</details>

### Custom Icon

```lua
-- Tambah icon sendiri
Akbar.AddIcon("my-icon", "rbxassetid://123456789")
Window:CreateTab({ Name = "Custom", Icon = "my-icon" })

-- Pakai langsung rbxassetid
Window:CreateTab({ Name = "Custom", Icon = "rbxassetid://123456789" })

-- Register spritesheet (untuk banyak icon sekaligus)
IconLib:RegisterSpritesheet("MySet", "rbxassetid://123456789", {
    ["icon1"] = { Position = Vector2.new(0, 0),  Size = Vector2.new(24, 24) },
    ["icon2"] = { Position = Vector2.new(24, 0), Size = Vector2.new(24, 24) },
})
```

---

## 📱 Mobile Support

| Fitur | Behavior |
|-------|----------|
| **Auto-Fit** | Window otomatis 95% dari ukuran layar HP |
| **Touch Drag** | Drag window pakai jari |
| **Touch Resize** | Resize dari pojok kanan bawah (grip diperbesar) |
| **Slider Hitbox** | Area sentuh diperluas (34px vertikal) |
| **Press Feedback** | Feedback visual saat tap |
| **Floating Button** | Tombol toggle selalu tersedia (nggak perlu keyboard) |
| **Safe Area** | Window nggak bisa keluar dari layar |

---

## 💾 Config System

### Manual

```lua
Window:SaveConfig("preset-1")      -- Simpan ke file JSON
Window:LoadConfig("preset-1")      -- Load dari file
Window:DeleteConfig("preset-1")    -- Hapus file
Window:ListConfigs()               -- List semua config
```

### Auto-Generated UI

```lua
Window:AddConfigTab()  -- Generate tab Settings lengkap
```

Auto-generate mencakup:
- Input nama config
- Dropdown config tersimpan
- Tombol Save / Load / Delete
- Theme picker (preset + custom color)
- Indikator support file system

### Flag System

Tambahkan `Flag` di komponen untuk masuk ke config:

```lua
Section:Toggle({ Title = "Auto Farm", Flag = "auto_farm", ... })
Section:Slider({ Title = "Speed", Flag = "speed_value", ... })
Section:Dropdown({ Title = "Target", Flag = "target_player", ... })
Section:ColorPicker({ Title = "ESP Color", Flag = "esp_color", ... })
Section:Keybind({ Title = "Toggle", Flag = "toggle_key", ... })
```

---

## ⚡ Performance

| Metric | Nilai |
|---------|-------|
| Load time | ~50ms |
| Memory | ~2MB |
| Element creation | <1ms per element |
| Theme switch | <16ms (1 frame) |
| File size | ~85KB |

### Tips Optimasi

```lua
-- Matikan animasi di device low-end
if isLowEnd then
    Akbar:SetAnimations(false)
end

-- Matikan blur kalau lag
Window:SetBlur(false)

-- Hapus komponen yang nggak dipakai
SomeElement:Destroy()

-- Cleanup saat script unload
Akbar:DestroyAll()
```

---

## 🩹 Troubleshooting

| Gejala | Solusi |
|--------|--------|
| `attempt to call a nil value` | Cek nama method — jangan pakai prefix `Create` (kecuali `CreateWindow`/`CreateTab`) |
| Config nggak tersimpan | Pastikan komponen punya `Flag` unik & executor support `writefile`/`readfile` |
| Config nggak ke-load | Panggil `Window:LoadConfig()` SETELAH semua komponen dibuat |
| Warna nggak berubah saat ganti tema | Pastikan pakai v3.0.0+ (sistem `Themed()` + `ThemeHooks`) |
| Komponen overlapping | Pastikan komponen di dalam `Section`, bukan langsung di `Tab` |
| Blur nggak muncul | Beberapa executor memblokir `Lighting`. Coba restart atau matikan `Blur = false` |
| `SetDisabled` nggak berfungsi | Pastikan elemen punya `_state` (semua komponen v3.0.0+ sudah otomatis) |
| Dropdown search nggak muncul | Search otomatis aktif kalau opsi > 8, atau set `Search = true` manual |

---

## 📝 Changelog

### v3.0.0 *(Latest)*

**New Components:**
- `Console` — terminal output real-time dengan 6 log level + tombol Clear
- `Spinner` — loading indicator dengan start/stop control
- `Checklist` — multi-select checkbox (beda dari Dropdown Multi)
- `Image` — embed custom image di dalam section
- `ThemePicker` — preset dropdown + custom color picker otomatis

**New Features:**
- 100+ Lucide icons built-in
- `IconLib` dengan support custom spritesheet
- `Element:SetDisabled(bool)` — gray out & disable interaksi
- `Element:SetVisible(bool)` — show/hide komponen
- `Element:Destroy()` — hapus permanen
- Background blur effect (`Blur = true` di CreateWindow)
- `Window:Show()` / `Hide()` / `IsVisible()`
- `Akbar:DestroyAll()` — cleanup semua window
- `Window:AddConfigTab()` — auto-generate tab Settings
- Slider `ShowTooltip` — tooltip nilai muncul saat drag
- Slider `CallbackOnlyOnRelease` — callback cuma saat mouse dilepas
- Dropdown `Search` — filter opsi otomatis/manual
- Dropdown `AddOption()` / `RemoveOption()` — runtime add/remove
- Badge system di Tab (`Tab:SetBadge(count)`)
- Hover Tooltip di semua komponen (`Tooltip = "text"`)
- Label `RichText` support
- Mobile auto-fit detection
- Maximize re-fits saat resize/rotate layar
- 3 preset baru: `Cotton Candy`, `Cyber Lime`, `Deep Violet`

**Fixes:**
- Stepper value label overlapping tombol minus
- Dialog backdrop sekarang bisa close dialog
- Maximized window re-fits saat viewport berubah
- Keybind text truncation untuk nama key panjang

---

### v2.0.1
- **Fix:** `task.wait` di Button diganti `task.delay` (non-blocking)
- **Fix:** `SelectTab` index out of bounds tidak lagi crash
- **Fix:** `SetMinSize`/`SetMaxSize` sekarang validasi input
- **Fix:** API `Get()` konsisten di semua komponen
- **New:** Komponen `Stepper`, `Progress`, `Tooltip`
- **New:** 7 preset warna via `Akbar:SetPreset()`
- **New:** Animasi tactile (`PressFeedback`) & glow di tombol Primary

### v2.0.0
- Rilis awal: Window, Tab, Section, Toggle, Slider, Dropdown, Button, Label, Paragraph, Divider, Keybind, ColorPicker, Input, Notify, Confirm, Dialog, Config Save/Load, Live Theme

---

## 📄 Lisensi & Kredit

Dibuat dengan ❤️ oleh **King Akbar**.
Bebas dipakai untuk proyek pribadi maupun publik — mohon cantumkan credit kalau di-redistribute.

📱 Instagram: [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)

Icon set oleh [Lucide](https://lucide.dev) — MIT License
