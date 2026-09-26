<div align="center">
  <img src="https://img.shields.io/badge/Version-2.0.1-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/Roblox-Luau-red?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" />
  <img src="https://img.shields.io/badge/Mobile-Supported-orange?style=flat-square" />
</div>

<h1 align="center">📘 Akbar UI — Dokumentasi Lengkap</h1>

<p align="center">
  Panduan resmi penggunaan <b>Akbar UI Framework v2.0.1</b> untuk Roblox Luau.<br>
  Dari instalasi dasar sampai advanced tricks — semua ada di sini.
</p>

<p align="center">
  <a href="README.md"><b>← Kembali ke README</b></a> •
  <a href="#-instalasi"><b>Instalasi</b></a> •
  <a href="#-quick-start"><b>Quick Start</b></a> •
  <a href="#-komponen-ui"><b>Komponen</b></a>
</p>

---

## 📑 Daftar Isi

1. [📦 Instalasi](#-instalasi)
2. [🚀 Quick Start](#-quick-start)
3. [🧠 Konsep Dasar](#-konsep-dasar)
4. [🪟 Window](#-window)
5. [📂 Tab & Section](#-tab--section)
6. [🧩 Komponen UI](#-komponen-ui)
   - [Toggle](#-toggle)
   - [Slider](#-slider)
   - [Dropdown](#-dropdown)
   - [Button](#-button)
   - [Keybind](#️-keybind)
   - [ColorPicker](#-colorpicker)
   - [Input](#-input)
   - [Stepper](#-stepper)
   - [Progress](#-progress)
   - [Label](#-label)
   - [Paragraph](#-paragraph)
   - [Tooltip](#-tooltip)
   - [Divider](#-divider)
7. [🔔 Notifikasi & Dialog](#-notifikasi--dialog)
8. [💾 Config System](#-config-system)
9. [🎨 Tema & Preset](#-tema--preset)
10. [🎛️ Window Methods](#️-window-methods)
11. [💡 Best Practices](#-best-practices)
12. [🔥 Pro Tips](#-pro-tips)
13. [🩹 Troubleshooting](#-troubleshooting)
14. [❓ FAQ](#-faq)

---

## 📦 Instalasi

Load library dari GitHub dengan 1 baris di paling atas script kamu:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()
```

> ⚠️ **ATURAN PENTING:**
> 
> ❌ `Tab:CreateToggle(...)` 
> ✅ `Tab:Toggle(...)`
> 
> Semua method komponen **TIDAK** pakai prefix `Create`. 
> Hanya `Akbar:CreateWindow(...)` dan `Window:CreateTab(...)` yang pakai `Create`.

---

## 🚀 Quick Start

Script minimal yang langsung jalan:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()

-- 1. Buat Window
local Window = Akbar:CreateWindow({
    Name = "My Script",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyScript",
        FileName = "config"
    },
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })

-- 3. Tambah komponen
Tab:Toggle({
    Title = "Auto Farm",
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

-- 4. Auto-load config
task.defer(function()
    Window:LoadConfig()
end)
```

---

## 🧠 Konsep Dasar

Akbar UI punya struktur hierarki:

```
Akbar (Library)
└── Window (Jendela utama)
    ├── Tab 1 (Kategori)
    │   ├── Section (Grup collapsible, opsional)
    │   │   ├── Toggle
    │   │   ├── Slider
    │   │   └── Button
    │   └── Komponen lainnya
    └── Tab 2
        └── ...
```

**Prinsip Utama:**
- Setiap komponen yang punya `Flag` akan otomatis tersimpan di config
- Semua callback dibungkus `pcall` — error di script kamu tidak bikin UI crash
- Animasi bisa dimatikan untuk device low-end (`Akbar:SetAnimations(false)`)

---

## 🪟 Window

`Akbar:CreateWindow(config)` adalah pintu masuk utama.

### Syntax

```lua
local Window = Akbar:CreateWindow(config)
```

### Parameter `config` Lengkap

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Name` | string | `"King Akbar"` | Judul window |
| `LoadingSubtitle` | string | `"King Akbar"` | Subjudul di header |
| `Icon` | string | `"crown"` | Nama ikon preset atau `rbxassetid://...` |
| `ToggleUIKeybind` | string/EnumItem | `"RightControl"` | Tombol show/hide window |
| `Size` | UDim2 | `760x520` | Ukuran awal window |
| `MinSize` | Vector2 | `480x360` | Ukuran minimum |
| `MaxSize` | Vector2 | `1100x750` | Ukuran maksimum |
| `MaxNotifications` | number | `5` | Maksimal notifikasi numpuk |
| `KeepOnScreen` | bool | `true` | Cegah drag keluar layar |
| `Accordion` | bool | `false` | Buka 1 section = tutup yang lain |
| `SearchEnabled` | bool | `true` | Tampilkan search box di sidebar |
| `OpenButton` | table/false | `{}` | Tombol toggle melayang |
| `Loading` | table | `—` | Konfigurasi loading screen |
| `ConfigurationSaving` | table | `—` | Config save/load |
| `DisplayOrder` | number | `100` | ZIndex ScreenGui |
| `Parent` | Instance | CoreGui | Parent custom |
| `CloseBehavior` | string | `"Hide"` | `"Destroy"` untuk hancurin window |

### Contoh Lengkap

```lua
local Window = Akbar:CreateWindow({
    Name = "King Akbar Hub",
    LoadingSubtitle = "Premium Auto Farm v2",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(800, 600),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Accordion = false,
    SearchEnabled = true,
    MaxNotifications = 5,
    KeepOnScreen = true,
    OpenButton = {
        Icon = "crown",
        Position = UDim2.new(0, 16, 0, 16)
    },
    Loading = {
        Enabled = true,
        Title = "King Akbar Hub",
        Text = "Mohon tunggu",
        Steps = {
            "Verifying license...",
            "Loading modules...",
            "Preparing interface..."
        },
        Duration = 1.5
    },
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KingAkbar",
        FileName = "config"
    },
    CloseBehavior = "Hide",
    DisplayOrder = 100
})
```

### Daftar Ikon Bawaan

```
crown, anchor, fish, pickaxe, bot, sprout, settings, home, info, 
user, users, zap, shield, wrench, refresh-cw, layout-dashboard, 
scroll-text, search, x, minus, maximize, chevron-down, 
chevron-up, check, save, palette
```

**Custom icon?** Bisa pakai `rbxassetid://123456` atau URL gambar.

---

## 📂 Tab & Section

### Membuat Tab

```lua
-- Cara 1: Config lengkap
local FarmTab = Window:CreateTab({
    Name = "Auto Farm",
    Desc = "Semua fitur farming",
    Icon = "sprout"
})

-- Cara 2: Shortcut (nama + icon)
local SettingsTab = Window:CreateTab("Settings", "settings")
```

**Parameter Tab:**

| Field | Tipe | Keterangan |
|-------|------|------------|
| `Name` | string | Nama tab (wajib) |
| `Desc` | string | Deskripsi tab |
| `Icon` | string | Ikon preset atau asset ID |

**Method Tab:**
```lua
Tab:Select()  -- Pindah ke tab ini secara programmatic
```

### Membuat Section (Grup Collapsible)

```lua
local Section = Tab:Section({
    Title = "⚙️ Advanced Settings",
    Open = true  -- true = terbuka, false = tertutup
})

-- Tambah komponen KE DALAM section
Section:Toggle({ Title = "Anti-AFK", Flag = "AntiAFK" })
Section:Slider({ Title = "Delay", Min = 0, Max = 5, Flag = "Delay" })
```

**Parameter Section:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Section"` | Judul section |
| `Open` | bool | `true` | State awal (terbuka/tertutup) |

**Method Section:**
```lua
Section:Expand()              -- Buka section
Section:Collapse()            -- Tutup section
Section:SetExpanded(bool)     -- Set state
```

> 💡 **Tip:** Kalau `Accordion = true` di Window, buka 1 section akan otomatis tutup section lain.

---

## 🧩 Komponen UI

### 🔘 Toggle

Switch ON/OFF.

```lua
local myToggle = Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Aktifkan auto farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Toggle"` | Judul |
| `Desc` | string | `""` | Deskripsi (opsional) |
| `Default` | bool | `false` | Status awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**
```lua
myToggle:Set(true)         -- Nyalakan
myToggle:Set(false, true)  -- Matikan tanpa trigger callback (silent)
print(myToggle:Get())      -- Cek status (true/false)
print(myToggle.Value)      -- Langsung akses nilai
```

---

### 🎚️ Slider

Geser untuk ubah nilai numerik.

```lua
local mySlider = Tab:Slider({
    Title = "Jarak Farm",
    Desc = "Jarak maksimum",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Precision = 0,
    Suffix = " studs",
    Flag = "FarmRange",
    Callback = function(value)
        print("Jarak:", value)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Slider"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Min` | number | `0` | Nilai minimum |
| `Max` | number | `100` | Nilai maksimum |
| `Default` | number | `Min` | Nilai awal |
| `Step` | number | `nil` | Kelipatan (opsional) |
| `Precision` | number | `0` | Jumlah desimal |
| `Suffix` | string | `""` | Teks di belakang angka |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**
```lua
mySlider:Set(75)
mySlider:Set(80, true)  -- silent (tidak trigger callback)
print(mySlider:Get())
```

---

### 📋 Dropdown

Pilihan single atau multi select.

**Single Select:**
```lua
local myDrop = Tab:Dropdown({
    Title = "Pilih Map",
    Options = {"Spawn", "Desert", "Forest"},
    Default = "Spawn",
    Flag = "SelectedMap",
    Callback = function(selected)
        print("Map:", selected)
    end,
})
```

**Multi Select:**
```lua
local myDrop = Tab:Dropdown({
    Title = "Pilih Item",
    Options = {"Weapon", "Armor", "Potion"},
    Multi = true,
    Default = {"Weapon"},
    Flag = "SelectedItems",
    Callback = function(selectedTable)
        print("Items:", table.concat(selectedTable, ", "))
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Dropdown"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Options` | table | `{}` | Daftar opsi (array of strings) |
| `Default` | string/table | `Options[1]` | Nilai awal |
| `Multi` | bool | `false` | Multi-select mode |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**
```lua
myDrop:Set("Desert")                     -- Set value
myDrop:Refresh({"A", "B", "C"}, false)   -- Update opsi (false = reset selection)
myDrop:Refresh({"A", "B", "C"}, true)    -- Update opsi tapi pertahankan selection
print(myDrop:Get())                       -- Ambil value (string atau table)
```

---

### 🔘 Button

Tombol aksi.

```lua
-- Button biasa
Tab:Button({
    Title = "Teleport",
    Desc = "Klik untuk teleport",
    Callback = function()
        print("Teleporting...")
    end,
})

-- Button Primary (menonjol, ada glow)
Tab:Button({
    Title = "💾 Simpan Config",
    Primary = true,
    Height = 45,
    Callback = function()
        Window:SaveConfig()
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Button"` | Teks tombol |
| `Desc` | string | `""` | Deskripsi |
| `Primary` | bool | `false` | Warna accent + glow |
| `Height` | number | `40` | Tinggi tombol (px) |
| `Callback` | function | `nil` | Dipanggil saat diklik |

**Return:**
```lua
local btn = Tab:Button({ Title = "Klik", Callback = function() end })
btn:Set("Teks Baru")   -- Ubah teks tombol
btn.Instance            -- Akses TextButton instance langsung
```

---

### ⌨️ Keybind

Bind tombol keyboard.

```lua
local myKey = Tab:Keybind({
    Title = "Toggle Farm",
    Desc = "Tekan untuk toggle",
    Default = "E",
    Flag = "FarmKey",
    Callback = function(keyName)
        -- Dipanggil saat tombol DITEKAN di game
        print(keyName, "ditekan!")
    end,
    OnChanged = function(newKey)
        -- Dipanggil saat keybind DIGANTI user
        print("Keybind diubah ke:", newKey)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Keybind"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Default` | string/EnumItem | `"None"` | Tombol default |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat key ditekan di game |
| `OnChanged` | function | `nil` | Dipanggil saat user ganti key |

**Method:**
```lua
myKey:Set("Q")
myKey:Set(Enum.KeyCode.F)
print(myKey:Get())  -- Return EnumItem
```

> 💡 **Tip:** Tekan **Escape** saat binding untuk batal.

---

### 🎨 ColorPicker

Pilih warna RGB/HSV.

```lua
local myColor = Tab:ColorPicker({
    Title = "Warna ESP",
    Desc = "Pilih warna highlight",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("R:", color.R * 255)
        print("G:", color.G * 255)
        print("B:", color.B * 255)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Color"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Default` | Color3 | Accent theme | Warna awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat warna berubah |

**Method:**
```lua
myColor:Set(Color3.fromRGB(0, 255, 0))
myColor:Set(Color3.fromRGB(0, 0, 255), true)  -- silent
print(myColor:Get())  -- Return Color3
```

---

### ⌨️ Input

Text box untuk input teks.

```lua
local myInput = Tab:Input({
    Title = "Nickname",
    Desc = "Masukkan nama kamu",
    Placeholder = "Ketik di sini...",
    Default = "",
    Flag = "UserNick",
    Callback = function(text, enterPressed)
        print("Text:", text)
        if enterPressed then
            print("User tekan Enter!")
        end
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Input"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Placeholder` | string | `"Type here..."` | Teks placeholder |
| `Default` | string | `""` | Teks awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat `FocusLost` |

**Method:**
```lua
myInput:Set("Akbar")
print(myInput:Get())  -- Return string
```

---

### 🔢 Stepper

Tombol + / - untuk increment/decrement.

```lua
local myStepper = Tab:Stepper({
    Title = "Jumlah Loop",
    Desc = "Berapa kali diulang",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Flag = "LoopCount",
    Callback = function(value)
        print("Loop:", value)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Stepper"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Range` | table | `{0, 100}` | `{min, max}` |
| `Increment` | number | `1` | Kelipatan |
| `CurrentValue` | number | `Range[1]` | Nilai awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**
```lua
myStepper:Set(7)
myStepper:Set(8, true)  -- silent
print(myStepper:Get())
```

---

### 📊 Progress

Progress bar dari 0 sampai 1.

```lua
local myProgress = Tab:Progress({
    Title = "Progress Upgrade",
    CurrentValue = 0.4,
    Format = function(v)
        return math.floor(v * 100) .. "%"
    end,
})

-- Update dari script
myProgress:Set(0.75)  -- 75%
myProgress:Set(1.0)   -- 100%
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Progress"` | Judul |
| `CurrentValue` | number | `0` | Nilai awal (0 sampai 1) |
| `Format` | function | `function(v) return math.floor(v*100).."%" end` | Format teks |

**Method:**
```lua
myProgress:Set(0.5)
print(myProgress:Get())  -- Return number (0-1)
```

---

### 📝 Label

Teks statis satu baris.

```lua
local myLabel = Tab:Label({
    Title = "Versi: 2.0.1"
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` / `Text` | string | `"Label"` | Teks yang ditampilkan |

**Method:**
```lua
myLabel:Set("Versi: 3.0.0")
print(myLabel:Get())
```

---

### 📄 Paragraph

Teks dengan judul + deskripsi panjang.

```lua
local myPara = Tab:Paragraph({
    Title = "Cara Pakai:",
    Desc = "1. Aktifkan Auto Farm\n2. Pilih map\n3. Tekan E untuk toggle"
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Title"` | Judul |
| `Desc` / `Text` | string | `""` | Konten |

**Method:**
```lua
myPara:Set("Judul Baru", "Deskripsi baru")
```

---

### ℹ️ Tooltip

Info yang bisa di-expand/collapse.

```lua
local myTip = Tab:Tooltip({
    Title = "Apa itu Flag?",
    Text = "Flag adalah nama unik untuk menyimpan pengaturan. Setiap komponen yang punya Flag akan otomatis tersimpan di config."
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Info"` | Judul |
| `Text` | string | `""` | Konten yang di-expand |

**Method:**
```lua
myTip:Expand()
myTip:Collapse()
```

---

### ➖ Divider

Garis pemisah tipis.

```lua
Tab:Divider()  -- Tanpa parameter
```

---

## 🔔 Notifikasi & Dialog

### Notify

Tampilkan notifikasi melayang.

```lua
Window:Notify({
    Title = "Berhasil!",
    Content = "Auto farm diaktifkan",
    Duration = 3,
    Icon = "check",
    Type = "success"
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Akbar UI"` | Judul notifikasi |
| `Content` | string | `""` | Isi notifikasi |
| `Duration` | number | `3.5` | Durasi (detik) |
| `Icon` | string | `"info"` | Ikon preset |
| `Type` | string | `nil` | `"success"` / `"warning"` / `"error"` / `nil` |

**Type & Warna:**
- `"success"` → Hijau + icon check
- `"warning"` → Kuning + icon info
- `"error"` → Merah + icon x
- `nil` / default → Biru (accent) + icon info

**Return:**
```lua
local notif = Window:Notify({ Title = "Info" })
notif.Close()  -- Tutup manual
```

### Confirm Dialog (Ya/Batal)

```lua
Window:Confirm({
    Title = "Yakin?",
    Content = "Reset semua pengaturan?",
    ConfirmText = "Ya, Reset",
    CancelText = "Batal",
    Callback = function(confirmed)
        if confirmed then
            print("User konfirmasi!")
            Window:DeleteConfig()
        else
            print("User batal")
        end
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Confirmation"` | Judul |
| `Content` | string | `"Are you sure?"` | Isi |
| `ConfirmText` | string | `"Confirm"` | Teks tombol konfirmasi |
| `CancelText` | string | `"Cancel"` | Teks tombol batal |
| `Callback` | function | `function() end` | Dipanggil dengan bool |

### Custom Dialog (Tombol Bebas)

```lua
Window:Dialog({
    Title = "Pilih Aksi",
    Content = "Mau ngapain?",
    Buttons = {
        {
            Name = "Simpan",
            Primary = true,
            Callback = function()
                Window:SaveConfig()
            end
        },
        {
            Name = "Reset",
            Callback = function()
                Window:DeleteConfig()
            end
        },
        {
            Name = "Batal",
            Callback = function()
                print("Batal")
            end
        }
    }
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Title` | string | `"Akbar"` | Judul |
| `Content` | string | `""` | Isi |
| `Buttons` | table | `{{Name="OK"}}` | Array of button configs |

**Button config:**

| Field | Tipe | Keterangan |
|-------|------|------------|
| `Name` | string | Teks tombol |
| `Primary` | bool | Warna accent |
| `Callback` | function | Dipanggil saat diklik |

---

## 💾 Config System

Setiap komponen yang punya `Flag` akan otomatis tersimpan.

### Prinsip Dasar

- Nilai disimpan sebagai JSON
- Support: `boolean`, `number`, `string`, `Color3`, `EnumItem` (Keybind)
- File disimpan di `workspace/[FolderName]/[FileName].json`
- Fallback ke `_G` kalau executor tidak support file system

### Method

```lua
-- Simpan config (nama file opsional, default = "default")
Window:SaveConfig("profil1")

-- Load config (panggil SETELAH semua komponen dibuat)
Window:LoadConfig("profil1")

-- List semua config yang tersimpan
local configs = Window:ListConfigs()
-- Return: {"default", "profil1", "profil2", ...}

-- Hapus config
Window:DeleteConfig("profil1")
```

### Best Practice: Auto-Load

```lua
-- 1. Buat semua komponen dengan Flag
Tab:Toggle({ Title = "Auto Farm", Flag = "AutoFarm" })
Tab:Slider({ Title = "Speed", Flag = "Speed", Min = 0, Max = 100 })
Tab:Dropdown({ Title = "Map", Flag = "Map", Options = {...} })

-- 2. Load config di akhir script
task.defer(function()
    Window:LoadConfig()
end)
```

### Lokasi Penyimpanan

| Executor | Lokasi |
|----------|--------|
| Fluxus, Delta, Synapse, Arceus X | `workspace/[FolderName]/[FileName].json` |
| Executor Web / Terbatas | `_G["AKBAR_CONFIG_..."]` (sementara) |

---

## 🎨 Tema & Preset

### Ganti Preset Warna

```lua
Akbar:SetPreset("Royal Purple")
```

**7 Preset bawaan:**
- `Default Blue` (default)
- `Royal Purple`
- `Crimson Red`
- `Emerald Green`
- `Sunset Orange`
- `Ocean Teal`
- `Midnight Pink`

### Custom Accent Color

```lua
Akbar:SetAccentColor(Color3.fromRGB(255, 200, 0))  -- Kuning custom
```

### Custom Theme Lengkap

```lua
Akbar:SetTheme({
    Background = Color3.fromRGB(10, 10, 15),
    Surface = Color3.fromRGB(20, 20, 30),
    Surface2 = Color3.fromRGB(30, 30, 45),
    Border = Color3.fromRGB(60, 60, 80),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(140, 147, 168),
    Accent = Color3.fromRGB(100, 149, 237),
})
```

### List Preset

```lua
local presets = Akbar:ListPresets()
print(presets)
-- {"Crimson Red", "Default Blue", "Emerald Green", ...}
```

### Matikan Animasi (Device Low-End)

```lua
Akbar:SetAnimations(false)  -- Semua tween jadi instan
```

### Refresh Theme Manual

```lua
Akbar:RefreshTheme()  -- Paksa update semua komponen
```

---

## 🎛️ Window Methods

Semua method untuk kontrol window secara programmatic:

```lua
-- Show/Hide
Window:Toggle()

-- Posisi & Ukuran
Window:Center()                              -- Ke tengah layar
Window:SetSize(UDim2.fromOffset(800, 600))
Window:SetMinSize(Vector2.new(500, 400))
Window:SetMaxSize(Vector2.new(1200, 800))
print(Window:GetSize())

-- Header
Window:SetTitle("Judul Baru")
Window:SetSubtitle("Subjudul Baru")
Window:SetIcon("crown")

-- Keybind
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Fitur
Window:SetAccordion(true)       -- Mode accordion
Window:SetSearchEnabled(false)  -- Matikan search box

-- Config
Window:SaveConfig("profil1")
Window:LoadConfig("profil1")
Window:DeleteConfig("profil1")
print(Window:ListConfigs())

-- Notifikasi & Dialog
Window:Notify({ Title = "Info", Content = "Pesan", Type = "success" })
Window:Confirm({ Title = "Yakin?", Callback = function(ok) end })
Window:Dialog({ Title = "Pilih", Buttons = {...} })

-- Navigasi Tab
Window:SelectTab("Auto Farm")  -- By nama
Window:SelectTab(2)             -- By index
Window:SelectTab(tabObject)     -- By reference

-- Destroy
Window:Destroy()  -- Hancurkan window & semua koneksi
```

---

## 💡 Best Practices

### ✅ DO (Yang Harus Dilakukan)

1. **Selalu pakai `Flag`** untuk komponen yang perlu disimpan ke config
2. **Pakai `task.defer`** untuk load config setelah semua komponen dibuat
3. **Wrap callback di `pcall`** kalau script kamu rawan error
4. **Group pakai Section** biar UI rapi & tidak overwhelming
5. **Pakai `Primary = true`** HANYA untuk tombol penting (rare)
6. **Test di mobile** — pastikan semua tombol cukup besar (min 44px)
7. **Beri deskripsi singkat** di komponen kompleks biar user paham

### ❌ DON'T (Yang Harus Dihindari)

1. ❌ Jangan pakai prefix `Create` selain `CreateWindow`/`CreateTab`
2. ❌ Jangan bikin terlalu banyak tab (max 5-7 idealnya)
3. ❌ Jangan set `Accordion = true` kalau user perlu lihat banyak section sekaligus
4. ❌ Jangan lupa panggil `Window:LoadConfig()` kalau pakai config saving
5. ❌ Jangan biarkan callback error tanpa penanganan — akan bikin UI aneh
6. ❌ Jangan simpan data sensitif (password, token) di config

---

## 🔥 Pro Tips

### Tip 1: Matikan animasi di HP kentang
```lua
if workspace.Gravity < 100 then  -- deteksi mobile
    Akbar:SetAnimations(false)
end
```

### Tip 2: Auto-save setiap 30 detik
```lua
task.spawn(function()
    while task.wait(30) do
        pcall(function() Window:SaveConfig() end)
    end
end)
```

### Tip 3: Dynamic dropdown berdasarkan kondisi
```lua
local mapDrop = Tab:Dropdown({ Title = "Map", Options = {} })
task.spawn(function()
    local maps = getAvailableMaps()  -- fungsi kamu
    mapDrop:Refresh(maps)
end)
```

### Tip 4: Real-time label update
```lua
local fpsLabel = Tab:Label({ Title = "FPS: 0" })
RunService.RenderStepped:Connect(function(dt)
    fpsLabel:Set("FPS: " .. math.floor(1/dt))
end)
```

### Tip 5: Progress bar dengan loop
```lua
local progress = Tab:Progress({ Title = "Loading...", CurrentValue = 0 })
task.spawn(function()
    for i = 0, 100, 5 do
        progress:Set(i / 100)
        task.wait(0.1)
    end
end)
```

### Tip 6: Keybind sebagai toggle shortcut
```lua
local autoFarm = Tab:Toggle({ Title = "Auto Farm", Flag = "AutoFarm" })
Tab:Keybind({
    Title = "Toggle Farm",
    Default = "E",
    Callback = function()
        autoFarm:Set(not autoFarm:Get())
    end,
})
```

---

## 🩹 Troubleshooting

### Masalah Umum & Solusi

| Gejala | Penyebab | Solusi |
|--------|----------|--------|
| `attempt to call a nil value` | Pakai `Create` prefix salah | Hapus `Create`, pakai `Tab:Toggle` bukan `Tab:CreateToggle` |
| Config tidak tersimpan | Executor tidak support `writefile` | Pakai Fluxus/Delta/Synapse/Arceus X |
| Config tidak ter-load | Komponen dibuat setelah `LoadConfig` | Panggil `LoadConfig()` SETELAH semua komponen dibuat |
| Section tidak bisa diklik | Versi lama (bug overlap) | Update ke v2.0.1+ |
| Warna tidak berubah | Tidak pakai `Themed()` | Semua komponen resmi sudah otomatis |
| Mobile drag tidak smooth | Animasi terlalu berat | `Akbar:SetAnimations(false)` |
| Notifikasi numpuk terus | `MaxNotifications` terlalu besar | Set `MaxNotifications = 3` atau 5 |
| UI hilang setelah respawn | Parent ke PlayerGui | Pakai default (CoreGui) atau `gethui()` |

---

## ❓ FAQ

**Q: Kenapa `ToggleUIKeybind` tidak jalan?**  
A: Pastikan formatnya benar: `"RightControl"` (string) atau `Enum.KeyCode.RightControl` (EnumItem). Beberapa executor block keyboard input.

**Q: Bisa pakai di game yang ada anti-cheat?**  
A: Akbar UI tidak inject apa-apa ke game, hanya bikin ScreenGui. Aman. Tapi script logic kamu sendiri yang bisa kena deteksi.

**Q: Berapa batas maksimal komponen per tab?**  
A: Tidak ada batas teknis, tapi untuk UX maksimal 20-30 komponen per tab. Pakai Section untuk grouping.

**Q: Bisa custom font?**  
A: Belum built-in, tapi bisa override pakai `Akbar.Theme` atau edit langsung di source code.

**Q: Support executor apa saja?**  
A: Semua executor modern: Fluxus, Delta, Arceus X, Synapse, Krnl, Evon, VegaX, dll. Untuk executor web, config saving terbatas (fallback ke `_G`).

**Q: Apakah library ini open source?**  
A: Ya! Bebas dipakai dan dimodifikasi untuk proyek pribadi maupun publik. Mohon cantumkan credit kalau di-redistribute.

**Q: Beda Akbar UI dengan Rayfield/Fluent/Orion?**  
A: Akbar UI fokus pada:
- Mobile-first (touch-friendly sejak awal)
- Loading screen built-in
- Accordion section
- Live theme system yang lebih fleksibel
- File size lebih kecil

**Q: Kenapa callback saya error tapi UI tidak crash?**  
A: Semua callback dibungkus `pcall` — ini fitur, bukan bug. UI kamu tetap jalan meskipun ada error di logic.

---

## 📝 Changelog

### v2.0.1 — 26 September 2026

**🐛 Bug Fixes:**
- Fix: `task.wait` di Button diganti `task.delay` (non-blocking)
- Fix: `SelectTab` index out of bounds tidak lagi crash
- Fix: `SetMinSize`/`SetMaxSize` sekarang validasi input
- Fix: Loading screen aman kalau `Steps` kosong
- Fix: Elemen di dalam `Section` tidak lagi tumpang tindih dengan header
- Fix: Instance tombol sidebar tab tidak lagi ketiban method `:Button()`

**✨ Fitur Baru:**
- Komponen `Stepper`, `Progress`, `Tooltip`
- 7 preset warna via `Akbar:SetPreset()`
- Animasi tactile (`PressFeedback`) & glow di tombol Primary
- API `Get()` konsisten di semua komponen (Keybind, ColorPicker, Input, Label, Progress)

### v2.0.0 — Awal Rilis

- Rilis awal: Window, Tab, Section, Toggle, Slider, Dropdown, Button
- Label, Paragraph, Divider, Keybind, ColorPicker, Input
- Notify, Confirm, Dialog
- Config Save/Load, Live Theme

---

## 📞 Butuh Bantuan?

- 📖 Baca ulang dokumentasi ini
- 💬 Instagram: [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)
- 🐛 Laporkan bug via [GitHub Issues](https://github.com/Akbar025zzz/Akbar_ui/issues)
- 📁 Lihat contoh script di folder [`contoh/`](contoh/)

---

<div align="center">

*Dibuat dengan ❤️ oleh **King Akbar***

**Happy coding! 🚀👑**

</div>
