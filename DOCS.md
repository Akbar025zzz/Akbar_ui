# 📘 Akbar UI — Dokumentasi Lengkap & API Reference

> Panduan lengkap penggunaan **Akbar UI v2.0.1** — Framework UI modern untuk Roblox Luau.
> Dibuat agar mudah dipahami baik oleh pemula maupun developer berpengalaman.

---

## 📑 Daftar Isi

1. [Instalasi](#-instalasi)
2. [Quick Start](#-quick-start)
3. [Membuat Window](#-window)
4. [Tab & Section](#-tab--section)
5. [Komponen UI](#-komponen-ui)
   - [Toggle](#-toggle)
   - [Slider](#-slider)
   - [Dropdown](#-dropdown)
   - [Button](#-button)
   - [Keybind](#️-keybind)
   - [ColorPicker](#-colorpicker)
   - [Input](#-input)
   - [Stepper](#-stepper)
   - [Progress](#-progress)
   - [Label & Paragraph](#-label--paragraph)
   - [Tooltip](#-tooltip)
   - [Divider](#-divider)
6. [Notifikasi & Dialog](#-notifikasi--dialog)
7. [Config System](#-config-system)
8. [Tema & Preset](#-tema--preset)
9. [Best Practices](#-best-practices)
10. [Troubleshooting](#-troubleshooting)

---

## 📦 Instalasi

Load library dari GitHub dengan 1 baris:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()
```

> ⚠️ **PENTING:** Semua method komponen **TIDAK** pakai prefix `Create`. 
> 
> ❌ `Tab:CreateToggle(...)` 
> ✅ `Tab:Toggle(...)`
> 
> Hanya `Akbar:CreateWindow(...)` dan `Window:CreateTab(...)` yang pakai `Create`.

---

## 🚀 Quick Start

Script paling minimal yang langsung jalan:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()

-- Buat Window
local Window = Akbar:CreateWindow({
    Name = "My Script",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
})

-- Buat Tab
local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })

-- Tambah Toggle
Tab:Toggle({
    Title = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

-- Tambah Button
Tab:Button({
    Title = "Klik Aku!",
    Primary = true,
    Callback = function()
        Window:Notify({ Title = "Halo!", Type = "success" })
    end,
})
```

---

## 🪟 Window

Window adalah container utama semua UI kamu.

### Syntax
```lua
local Window = Akbar:CreateWindow(config)
```

### Parameter `config`

| Field | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `Name` | string | `"King Akbar"` | Judul window |
| `LoadingSubtitle` | string | `"King Akbar"` | Subjudul di header |
| `Icon` | string | `"crown"` | Nama ikon preset atau `rbxassetid://...` |
| `ToggleUIKeybind` | string/Enum | `"RightControl"` | Tombol show/hide |
| `Size` | UDim2 | `760x520` | Ukuran awal |
| `MinSize` | Vector2 | `480x360` | Ukuran minimum |
| `MaxSize` | Vector2 | `1100x750` | Ukuran maksimum |
| `MaxNotifications` | number | `5` | Max notifikasi numpuk |
| `KeepOnScreen` | bool | `true` | Cegah drag keluar layar |
| `Accordion` | bool | `false` | Mode accordion section |
| `SearchEnabled` | bool | `true` | Tampilkan search box |
| `OpenButton` | table/false | `{}` | Tombol toggle melayang |
| `Loading` | table | `—` | Konfigurasi loading screen |
| `ConfigurationSaving` | table | `—` | Config save/load |
| `DisplayOrder` | number | `100` | ZIndex ScreenGui |
| `Parent` | Instance | CoreGui | Parent custom |
| `CloseBehavior` | string | `"Hide"` | `"Destroy"` untuk hancurin |

### Contoh Lengkap

```lua
local Window = Akbar:CreateWindow({
    Name = "King Akbar Hub",
    LoadingSubtitle = "Premium Auto Farm",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(800, 600),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Accordion = false,
    SearchEnabled = true,
    OpenButton = {
        Icon = "crown",
        Position = UDim2.new(0, 16, 0, 16)
    },
    Loading = {
        Enabled = true,
        Title = "Loading...",
        Steps = {"Verifying...", "Loading...", "Ready!"},
        Duration = 1.5
    },
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KingAkbar",
        FileName = "config"
    }
})
```

### Method Window

```lua
Window:Toggle()                          -- Show/hide window
Window:Center()                          -- Center ke tengah layar
Window:SetSize(UDim2)                    -- Set ukuran
Window:GetSize()                         -- Ambil ukuran
Window:SetMinSize(Vector2)               -- Set ukuran minimum
Window:SetMaxSize(Vector2)               -- Set ukuran maximum
Window:SetTitle(text)                    -- Ganti judul
Window:SetSubtitle(text)                 -- Ganti subjudul
Window:SetIcon(iconAsset)                -- Ganti ikon
Window:SetToggleKey(key)                 -- Ganti keybind toggle
Window:SetAccordion(bool)                -- Toggle mode accordion
Window:SetSearchEnabled(bool)            -- Toggle search box
Window:SaveConfig(name?)                 -- Simpan config
Window:LoadConfig(name?)                 -- Load config
Window:DeleteConfig(name?)               -- Hapus config
Window:ListConfigs()                     -- List semua config
Window:Notify(data)                      -- Tampilkan notifikasi
Window:Confirm(data)                     -- Dialog Ya/Batal
Window:Dialog(data)                      -- Dialog custom
Window:CreateTab(config)                 -- Bikin tab baru
Window:SelectTab(tab/nama/index)         -- Pindah ke tab
Window:Destroy()                         -- Hancurin window
```

---

## 📂 Tab & Section

### Membuat Tab

```lua
-- Cara 1: Config lengkap
local Tab = Window:CreateTab({
    Name = "Auto Farm",
    Desc = "Semua fitur farming",
    Icon = "sprout"
})

-- Cara 2: Shortcut
local Tab = Window:CreateTab("Settings", "settings")
```

| Field | Tipe | Keterangan |
|-------|------|------------|
| `Name` | string | Nama tab (wajib) |
| `Desc` | string | Deskripsi tab |
| `Icon` | string | Ikon preset atau asset ID |

### Membuat Section (Grup Collapsible)

```lua
local Section = Tab:Section({
    Title = "⚙️ Pengaturan Lanjutan",
    Open = true  -- true = terbuka, false = tertutup
})

-- Tambah komponen ke dalam section
Section:Toggle({ Title = "Anti-AFK", Flag = "AntiAFK" })
Section:Slider({ Title = "Delay", Min = 0, Max = 5, Flag = "Delay" })
```

### Method Section

```lua
Section:Expand()           -- Buka section
Section:Collapse()         -- Tutup section
Section:SetExpanded(bool)  -- Set state
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

**Return:** `{ Value, Set(value, silent), Get() }`

```lua
myToggle:Set(true)         -- Nyalakan
myToggle:Set(false, true)  -- Matikan tanpa trigger callback
print(myToggle:Get())      -- Cek status
```

---

### 🎚️ Slider

Geser untuk ubah nilai.

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

**Return:** `{ Value, Set(value, silent), Get() }`

| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `Min` | number | Nilai minimum |
| `Max` | number | Nilai maksimum |
| `Default` | number | Nilai awal |
| `Step` | number | Kelipatan (opsional) |
| `Precision` | number | Jumlah desimal |
| `Suffix` | string | Teks di belakang angka |

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

**Return:** `{ Value, Set(v, silent), Get(), Refresh(newOptions, keepSelection) }`

```lua
myDrop:Set("Desert")
myDrop:Refresh({"A", "B", "C"}, false)  -- Update opsi
```

---

### 🔘 Button

Tombol aksi.

```lua
Tab:Button({
    Title = "Teleport",
    Desc = "Klik untuk teleport",
    Primary = false,   -- true = warna accent + glow
    Height = 40,       -- opsional
    Callback = function()
        print("Teleporting...")
    end,
})
```

**Return:** `{ Instance, Set(text) }`

```lua
local btn = Tab:Button({ Title = "Klik" })
btn:Set("Teks Baru")  -- Ubah teks
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
        -- Dipanggil saat tombol DITEKAN
        print(keyName, "ditekan!")
    end,
    OnChanged = function(newKey)
        -- Dipanggil saat keybind DIGANTI user
        print("Keybind diubah ke:", newKey)
    end,
})
```

**Return:** `{ Value, Set(key, silent), Get() }`

> 💡 Tekan **Escape** saat binding untuk batal.

---

### 🎨 ColorPicker

Pilih warna RGB/HSV.

```lua
local myColor = Tab:ColorPicker({
    Title = "Warna ESP",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("R:", color.R, "G:", color.G, "B:", color.B)
    end,
})
```

**Return:** `{ Value, Set(color, silent), Get() }`

---

### ⌨️ Input

Text box untuk input teks.

```lua
local myInput = Tab:Input({
    Title = "Nickname",
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

**Return:** `{ Value, Set(text), Get() }`

---

### 🔢 Stepper

Tombol + / - untuk increment/decrement.

```lua
local myStepper = Tab:Stepper({
    Title = "Jumlah Loop",
    Desc = "Berapa kali diulang",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 1,
    Flag = "LoopCount",
    Callback = function(value)
        print("Loop:", value)
    end,
})
```

**Return:** `{ Value, Set(v, silent), Get() }`

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

**Return:** `{ Value, Set(v), Get() }`

---

### 📝 Label & Paragraph

Teks statis.

```lua
local myLabel = Tab:Label({
    Title = "Versi: 2.0.1"
})
myLabel:Set("Versi: 3.0.0")  -- Update

Tab:Paragraph({
    Title = "Cara Pakai:",
    Desc = "1. Aktifkan Auto Farm\n2. Pilih map\n3. Tekan E"
})
```

---

### ℹ️ Tooltip

Info yang bisa di-expand/collapse.

```lua
local myTip = Tab:Tooltip({
    Title = "Apa itu Flag?",
    Text = "Flag adalah nama unik untuk config saving."
})

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

```lua
Window:Notify({
    Title = "Berhasil!",
    Content = "Config tersimpan",
    Duration = 3,
    Icon = "check",
    Type = "success"  -- "success" | "warning" | "error" | nil
})
```

**Return:** `{ Frame, Close() }`

```lua
local notif = Window:Notify({ Title = "Info" })
notif.Close()  -- Tutup manual
```

### Confirm (Ya/Batal)

```lua
Window:Confirm({
    Title = "Yakin?",
    Content = "Reset semua?",
    ConfirmText = "Ya, Reset",
    CancelText = "Batal",
    Callback = function(confirmed)
        if confirmed then
            print("User konfirmasi")
        end
    end,
})
```

### Dialog (Tombol Custom)

```lua
Window:Dialog({
    Title = "Pilih Aksi",
    Content = "Mau ngapain?",
    Buttons = {
        { Name = "Simpan", Primary = true, Callback = function() end },
        { Name = "Reset", Callback = function() end },
        { Name = "Batal", Callback = function() end },
    }
})
```

---

## 💾 Config System

Setiap komponen yang punya `Flag` otomatis tersimpan.

### Save & Load

```lua
-- Simpan
Window:SaveConfig("profil1")

-- Load (panggil SETELAH semua komponen dibuat)
Window:LoadConfig("profil1")

-- List semua config
local configs = Window:ListConfigs()
-- Return: {"default", "profil1", ...}

-- Hapus config
Window:DeleteConfig("profil1")
```

### Auto-Load Pattern

```lua
local Window = Akbar:CreateWindow({
    Name = "My Script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyScript",
        FileName = "config"
    }
})

-- 1. Buat semua komponen dulu
Tab:Toggle({ Title = "Auto Farm", Flag = "AutoFarm" })
Tab:Slider({ Title = "Speed", Flag = "Speed" })

-- 2. Load config di akhir
task.defer(function()
    Window:LoadConfig()
end)
```

### Lokasi Penyimpanan

| Executor | Lokasi |
|----------|--------|
| Fluxus, Delta, Synapse | `workspace/[FolderName]/[FileName].json` |
| Executor Web / Terbatas | `_G["AKBAR_CONFIG_..."]` (sementara) |

---

## 🎨 Tema & Preset

### Ganti Preset

```lua
Akbar:SetPreset("Royal Purple")
```

**7 Preset Bawaan:**
- `Default Blue`
- `Royal Purple`
- `Crimson Red`
- `Emerald Green`
- `Sunset Orange`
- `Ocean Teal`
- `Midnight Pink`

### Custom Accent

```lua
Akbar:SetAccentColor(Color3.fromRGB(255, 200, 0))
```

### Custom Theme

```lua
Akbar:SetTheme({
    Background = Color3.fromRGB(10, 10, 15),
    Surface = Color3.fromRGB(20, 20, 30),
    Accent = Color3.fromRGB(100, 149, 237),
    Text = Color3.fromRGB(255, 255, 255),
})
```

### List Preset

```lua
local presets = Akbar:ListPresets()
```

### Matikan Animasi

```lua
Akbar:SetAnimations(false)  -- Buat HP kentang
```

---

## 💡 Best Practices

### ✅ DO (Yang Harus Dilakukan)

1. **Selalu pakai `Flag`** untuk komponen yang perlu disimpan
2. **Pakai `task.defer`** untuk load config setelah semua komponen dibuat
3. **Wrap callback di `pcall`** kalau rawan error
4. **Pakai Section** untuk grouping biar UI rapi
5. **Test di mobile** sebelum publish
6. **Pakai `Primary = true`** HANYA untuk tombol penting (rare)

### ❌ DON'T (Yang Harus Dihindari)

1. ❌ Jangan pakai prefix `Create` selain `CreateWindow`/`CreateTab`
2. ❌ Jangan bikin lebih dari 7 tab
3. ❌ Jangan lupa `Window:LoadConfig()` kalau pakai config
4. ❌ Jangan biarkan callback error tanpa handling

### 🔥 Pro Tips

```lua
-- Matikan animasi di HP kentang
if workspace.Gravity < 100 then
    Akbar:SetAnimations(false)
end

-- Auto-save tiap 30 detik
task.spawn(function()
    while task.wait(30) do
        pcall(function() Window:SaveConfig() end)
    end
end)

-- Real-time label update
local fpsLabel = Tab:Label({ Title = "FPS: 0" })
RunService.RenderStepped:Connect(function(dt)
    fpsLabel:Set("FPS: " .. math.floor(1/dt))
end)

-- Dynamic dropdown
local mapDrop = Tab:Dropdown({ Title = "Map", Options = {} })
task.spawn(function()
    local maps = getAvailableMaps()
    mapDrop:Refresh(maps)
end)
```

---

## 🩹 Troubleshooting

### Masalah Umum

| Gejala | Penyebab | Solusi |
|--------|----------|--------|
| `attempt to call a nil value` | Pakai `Create` prefix salah | Hapus `Create`, pakai `Tab:Toggle` bukan `Tab:CreateToggle` |
| Config tidak tersimpan | Executor tidak support `writefile` | Pakai Fluxus/Delta/Synapse |
| Config tidak ter-load | Komponen dibuat setelah `LoadConfig` | Panggil `LoadConfig()` SETELAH semua komponen dibuat |
| Section tidak bisa diklik | Versi lama | Update ke v2.0.1+ |
| Warna tidak berubah | Tidak pakai `Themed()` | Semua komponen resmi sudah otomatis |
| Mobile drag tidak smooth | Animasi terlalu berat | `Akbar:SetAnimations(false)` |

### FAQ

**Q: Kenapa `ToggleUIKeybind` tidak jalan?**  
A: Pastikan format benar: `"RightControl"` (string) atau `Enum.KeyCode.RightControl`. Beberapa executor block keyboard input.

**Q: Bisa pakai di game yang ada anti-cheat?**  
A: Akbar UI hanya bikin ScreenGui, aman. Tapi script logic kamu yang bisa kena deteksi.

**Q: Berapa batas maksimal komponen?**  
A: Tidak ada batas teknis, tapi untuk UX max 20-30 komponen per tab.

**Q: Support executor apa saja?**  
A: Semua executor modern: Fluxus, Delta, Arceus X, Synapse, Krnl, dll.

---

## 📞 Butuh Bantuan?

- 📖 Baca ulang dokumentasi ini
- 💬 Instagram: [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)
- 🐛 Laporkan bug via GitHub Issues

---

*Dibuat dengan ❤️ oleh **King Akbar** — Happy coding! 🚀*
