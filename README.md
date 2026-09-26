<div align="center">
  <img src="https://img.shields.io/badge/Version-2.0.1-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Roblox_Luau-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Mobile-Fully_Supported-orange?style=for-the-badge" />
</div>

<h1 align="center">👑 Akbar UI Framework</h1>

<p align="center">
  <b>Modern Dark Glassmorphism UI Library untuk Roblox</b><br>
  Framework UI yang ringan, cepat, dan 100% responsif (PC + Mobile). 
  Dibuat untuk mendukung seluruh proyek <b>King Akbar</b> (Drag Race Simulator, Indo Hangout Hub, Car Driving Indonesia).
</p>

<p align="center">
  <a href="DOCS.md"><b>📖 Baca Dokumentasi Lengkap</b></a> •
  <a href="#-instalasi"><b>🚀 Instalasi</b></a> •
  <a href="#-fitur-unggulan"><b>✨ Fitur</b></a>
</p>

---

## ✨ Fitur Unggulan

- 🎨 **Dark Glassmorphism** — Desain modern dengan 7 preset warna siap pakai & custom theme.
- 📱 **Mobile First** — Full support untuk layar sentuh (drag, resize, tactile feedback).
- 🧩 **14 Komponen Siap Pakai** — Toggle, Slider, Dropdown (Multi), Stepper, ColorPicker, Keybind, dll.
- 💾 **Smart Config System** — Save/Load otomatis per-flag dalam format JSON (dengan fallback `_G`).
- ⚡ **Performa Optimal** — Animasi tween yang halus, anti-crash (`pcall` wrapper), dan ramah device low-end.
- 🛡️ **Error Handling** — Callback error di script kamu tidak akan bikin UI utama crash.

---

## 📦 Instalasi

Cukup load langsung dari GitHub menggunakan `loadstring` di baris paling atas script kamu:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()
```

---

## 🚀 Quick Start (Contoh Dasar)

```lua
local Akbar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"))()

-- 1. Buat Window
local Window = Akbar:CreateWindow({
    Name = "King Akbar Hub",
    LoadingSubtitle = "Premium Suite",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled = true, FolderName = "KingAkbar", FileName = "config" }
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })

-- 3. Tambah Komponen
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
    Title = "💾 Simpan Config",
    Primary = true,
    Callback = function()
        Window:SaveConfig()
        Window:Notify({ Title = "Berhasil!", Type = "success" })
    end,
})
```

---

## 📖 Dokumentasi & API Reference

Ingin tahu cara pakai `Slider`, `Dropdown`, `ColorPicker`, atau `Config System` secara mendalam? 
👉 **[Klik di sini untuk membaca Dokumentasi Lengkap (DOCS.md)](DOCS.md)**

---

## 🎨 Tema & Preset

Ganti warna aksen UI hanya dengan 1 baris kode:
```lua
Akbar:SetPreset("Royal Purple") 
-- Pilihan: Default Blue, Royal Purple, Crimson Red, Emerald Green, Sunset Orange, Ocean Teal, Midnight Pink
```

---

## 🩹 Troubleshooting

| Gejala | Solusi |
|---|---|
| `attempt to call a nil value` | Pastikan tidak pakai prefix `Create` (Kecuali `CreateWindow` & `CreateTab`). |
| Config tidak tersimpan | Pastikan executor mendukung `writefile`/`readfile` (Fluxus, Delta, Synapse, dll). |
| UI Crash | Bungkus logic berat kamu di dalam `pcall` atau `task.spawn`. |

---

## 📝 Changelog (v2.0.1)
- **Fix:** Elemen di dalam `Section` tidak lagi tumpang tindih.
- **Fix:** Button callback sekarang non-blocking (`task.delay`).
- **Fix:** API `Get()` sekarang konsisten di semua komponen.
- **New:** Komponen `Stepper`, `Progress`, dan `Tooltip`.
- **New:** Sistem Live Theme & 7 Preset Warna.

---

## 📄 Lisensi & Kredit

Dibuat dengan ❤️ oleh **King Akbar**. 
Bebas dipakai untuk proyek pribadi maupun publik (Script Hub, Executor Tools, dll) — mohon cantumkan credit jika di-redistribute.

📱 **Instagram:** [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)
