<div align="center">
  <img src="https://img.shields.io/badge/Version-2.0.1-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Roblox_Luau-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Mobile-Fully_Supported-orange?style=for-the-badge" />
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

- 🎨 **Dark Glassmorphism** — 7 preset warna siap pakai + custom theme (live update)
- 📱 **Mobile First** — drag, resize, dan semua komponen touch-friendly
- 🧩 **14 Komponen Siap Pakai** — Toggle, Slider, Dropdown (multi), Stepper, Progress, ColorPicker, Keybind, Input, Tooltip, dll.
- 💾 **Smart Config System** — save/load otomatis per-flag dalam format JSON (fallback `_G`)
- ⚡ **Animasi Tactile** — press feedback di semua tombol + glow tipis di tombol Primary
- 🛡️ **Anti-Crash** — semua callback dibungkus `pcall`, error script kamu nggak bikin UI mati

---

## 📦 Instalasi

Load langsung dari GitHub pakai `loadstring` di baris paling atas script kamu:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()
```

> ⚠️ **PENTING:** Semua method komponen **TIDAK** pakai prefix `Create`.
> Jadi `Tab:Toggle(...)`, bukan `Tab:CreateToggle(...)`.
> Hanya `Akbar:CreateWindow(...)` dan `Window:CreateTab(...)` yang pakai `Create`.

---

## 🚀 Quick Start

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()

-- 1. Buat Window
local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "Auto Farm Suite",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled = true, FolderName = "KingAkbar", FileName = "config" },
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ Name = "Utama", Icon = "home" })

-- 3. Tambah komponen
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Aktifkan auto farm otomatis",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

Tab:Button({
    Title = "Simpan Pengaturan",
    Primary = true,
    Callback = function()
        Window:SaveConfig()
        Window:Notify({ Title = "Config Tersimpan!", Type = "success" })
    end,
})
```

---

## 📁 Contoh Script

Bingung mulai dari mana? Langsung copy-paste dari folder [`contoh/`](contoh):

| File | Isi |
|------|-----|
| [`contoh/dasar.lua`](contoh/dasar.lua) | Setup paling minimal — Window + Toggle + Button |
| [`contoh/auto_farm.lua`](contoh/auto_farm.lua) | UI auto farm lengkap dengan Section, Config & Keybind |
| [`contoh/full_demo.lua`](contoh/full_demo.lua) | Showcase SEMUA 14 komponen + tema + notifikasi + dialog |

---

## 📖 Referensi API (Ringkas)

| Komponen | Contoh Pemanggilan | Balikan |
|----------|-------------------|---------|
| Toggle | `Tab:Toggle({Title, Desc, Default, Flag, Callback})` | `Set(v, silent)`, `Get()` |
| Slider | `Tab:Slider({Title, Min, Max, Default, Step, Suffix, Flag})` | `Set(v, silent)`, `Get()` |
| Dropdown | `Tab:Dropdown({Title, Options, Default, Multi, Flag})` | `Set(v)`, `Get()`, `Refresh(opts)` |
| Button | `Tab:Button({Title, Primary, Height, Callback})` | `Set(text)` |
| Keybind | `Tab:Keybind({Title, Default, Flag, Callback, OnChanged})` | `Set(key)`, `Get()` |
| ColorPicker | `Tab:ColorPicker({Title, Default, Flag, Callback})` | `Set(color)`, `Get()` |
| Input | `Tab:Input({Title, Placeholder, Default, Flag, Callback})` | `Set(text)`, `Get()` |
| Stepper | `Tab:Stepper({Title, Range, Increment, CurrentValue})` | `Set(v)`, `Get()` |
| Progress | `Tab:Progress({Title, CurrentValue, Format})` | `Set(v)`, `Get()` |
| Label / Paragraph | `Tab:Label({Title})` / `Tab:Paragraph({Title, Desc})` | `Set(...)` |
| Tooltip | `Tab:Tooltip({Title, Text})` | `Expand()`, `Collapse()` |
| Section | `Tab:Section({Title, Open})` | `Expand()`, `Collapse()` + semua komponen |
| Divider | `Tab:Divider()` | — |

👉 **Butuh penjelasan lengkap + semua parameter?** Baca **[DOCS.md](DOCS.md)**.

---

## 🎨 Tema & Preset Warna

```lua
Akbar:SetPreset("Royal Purple")  -- ganti accent instan, live ke semua elemen
Akbar:SetAccentColor(Color3.fromRGB(255, 200, 0))  -- warna custom bebas
Akbar:SetTheme({ Background = Color3.fromRGB(10, 10, 15) })  -- override field tema
Akbar:SetAnimations(false)  -- matikan tween buat device low-end
```

**Preset bawaan:** `Default Blue`, `Royal Purple`, `Crimson Red`, `Emerald Green`, `Sunset Orange`, `Ocean Teal`, `Midnight Pink`

---

## 🩹 Troubleshooting

| Gejala | Solusi |
|--------|--------|
| `attempt to call a nil value` | Cek nama method — jangan pakai prefix `Create` (kecuali `CreateWindow`/`CreateTab`) |
| Config nggak tersimpan | Pastikan komponen punya `Flag` unik & executor support `writefile`/`readfile` |
| Config nggak ke-load | Panggil `Window:LoadConfig()` SETELAH semua komponen dibuat |
| Warna nggak berubah saat ganti tema | Update ke v2.0.1+ (semua komponen resmi sudah pakai sistem `Themed()`) |

---

## 📝 Changelog

### v2.0.1
- **Fix:** `task.wait` di Button diganti `task.delay` (non-blocking)
- **Fix:** `SelectTab` index out of bounds tidak lagi crash
- **Fix:** `SetMinSize`/`SetMaxSize` sekarang validasi input
- **Fix:** API `Get()` konsisten di semua komponen (Keybind, ColorPicker, Input, Label, Progress)
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
