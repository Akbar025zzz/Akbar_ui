# 📘 Akbar UI — Dokumentasi Lengkap

Panduan resmi penggunaan **Akbar UI Framework v3.0.0** untuk Roblox Luau.
Dari instalasi dasar sampai advanced tricks — semua ada di sini.

[← Kembali ke README](README.md) • [Instalasi](#-instalasi) • [Quick Start](#-quick-start) • [Komponen](#-komponen-ui)

---

## 📑 Daftar Isi

1. 📦 [Instalasi](#-instalasi)
2. 🚀 [Quick Start](#-quick-start)
3. 🧠 [Konsep Dasar](#-konsep-dasar)
4. 🪟 [Window](#-window)
5. 📂 [Tab & Section](#-tab--section)
6. 🧩 [Komponen UI](#-komponen-ui)
   - [Toggle](#-toggle)
   - [Slider](#-slider)
   - [Dropdown](#-dropdown)
   - [Button](#-button)
   - [Keybind](#-keybind)
   - [ColorPicker](#-colorpicker)
   - [Input](#-input)
   - [Stepper](#-stepper)
   - [Progress](#-progress)
   - [Console](#-console)
   - [Spinner](#-spinner)
   - [Checklist](#-checklist)
   - [Image](#-image)
   - [Label](#-label)
   - [Paragraph](#-paragraph)
   - [Tooltip](#-tooltip)
   - [ThemePicker](#-themepicker)
   - [Divider](#-divider)
7. 🔄 [Element States](#-element-states)
8. 🔔 [Notifikasi & Dialog](#-notifikasi--dialog)
9. 💾 [Config System](#-config-system)
10. 🎨 [Tema & Preset](#-tema--preset)
11. 🖼️ [Icon Library](#-icon-library)
12. 📱 [Mobile Support](#-mobile-support)
13. 🎛️ [Window Methods](#-window-methods)
14. 💡 [Best Practices](#-best-practices)
15. 🔥 [Pro Tips](#-pro-tips)
16. 🩹 [Troubleshooting](#-troubleshooting)
17. ❓ [FAQ](#-faq)

---

## 📦 Instalasi

Load library dari GitHub dengan 1 baris di paling atas script kamu:

```lua
local Akbar = loadstring(game:HttpGet(
    "[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua)"
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
    "[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua)"
))()

-- 1. Buat Window
local Window = Akbar:CreateWindow({
    Name = "My Script",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Blur = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyScript",
        FileName = "config"
    },
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })

-- 3. Tambah Section
local Section = Tab:Section({ Title = "Features" })

-- 4. Tambah komponen
Section:Toggle({
    Title = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

Section:Button({
    Title = "💾 Simpan Config",
    Primary = true,
    Callback = function()
        Window:SaveConfig()
        Window:Notify({ Title = "Berhasil!", Type = "success" })
    end,
})

-- 5. Auto-generate tab Settings (Save/Load/Theme UI)
Window:AddConfigTab()

-- 6. Auto-load config
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
- Semua komponen punya `SetDisabled()`, `SetVisible()`, `Destroy()`
- 100+ icons built-in, bisa ditambah custom icon/spritesheet
- Background blur otomatis saat window aktif (bisa dimatikan)

---

## 🪟 Window

`Akbar:CreateWindow(config)` adalah pintu masuk utama.

### Syntax

```lua
local Window = Akbar:CreateWindow(config)
```

### Parameter `config` Lengkap

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
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
| `Blur` | bool | `true` | Background blur saat UI aktif |
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
    LoadingSubtitle = "Premium Auto Farm v3",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(800, 600),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Accordion = false,
    SearchEnabled = true,
    MaxNotifications = 5,
    KeepOnScreen = true,
    Blur = true,
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
| --- | --- | --- |
| `Name` | string | Nama tab (wajib) |
| `Desc` | string | Deskripsi tab |
| `Icon` | string | Ikon preset atau asset ID |

**Method Tab:**

```lua
Tab:Select()           -- Pindah ke tab ini secara programmatic
Tab:SetBadge(5)        -- Tampilkan badge merah dengan angka 5
Tab:SetBadge(0)        -- Sembunyikan badge
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
| --- | --- | --- | --- |
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
local myToggle = Section:Toggle({
    Title = "Auto Farm",
    Desc = "Aktifkan auto farm",
    Default = false,
    Flag = "AutoFarm",
    Tooltip = "Hover untuk info tambahan",
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Toggle"` | Judul |
| `Desc` | string | `""` | Deskripsi (opsional) |
| `Default` | bool | `false` | Status awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
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
local mySlider = Section:Slider({
    Title = "Jarak Farm",
    Desc = "Jarak maksimum",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Precision = 0,
    Suffix = " studs",
    ShowTooltip = true,
    CallbackOnlyOnRelease = true,
    Flag = "FarmRange",
    Callback = function(value)
        print("Jarak:", value)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Slider"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Min` | number | `0` | Nilai minimum |
| `Max` | number | `100` | Nilai maksimum |
| `Default` | number | `Min` | Nilai awal |
| `Step` | number | `nil` | Kelipatan (opsional) |
| `Precision` | number | `0` | Jumlah desimal |
| `Suffix` | string | `""` | Teks di belakang angka |
| `ShowTooltip` | bool | `true` | Tooltip nilai saat drag |
| `CallbackOnlyOnRelease` | bool | `false` | Callback hanya saat mouse dilepas |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**

```lua
mySlider:Set(75)
mySlider:Set(80, true)  -- silent (tidak trigger callback)
print(mySlider:Get())
```

---

### 📋 Dropdown

Pilihan single atau multi select dengan search filter.

**Single Select:**

```lua
local myDrop = Section:Dropdown({
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
local myDrop = Section:Dropdown({
    Title = "Pilih Item",
    Options = {"Weapon", "Armor", "Potion", "Ring", "Amulet", "Boots", "Helm", "Shield"},
    Multi = true,
    Search = true,
    Default = {"Weapon"},
    Flag = "SelectedItems",
    Callback = function(selectedTable)
        print("Items:", table.concat(selectedTable, ", "))
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Dropdown"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Options` | table | `{}` | Daftar opsi (array of strings) |
| `Default` | string/table | `Options[1]` | Nilai awal |
| `Multi` | bool | `false` | Multi-select mode |
| `Search` | bool | auto | Search filter (auto aktif jika opsi > 8) |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
| `Callback` | function | `nil` | Dipanggil saat nilai berubah |

**Method:**

```lua
myDrop:Set("Desert")                     -- Set value
myDrop:Refresh({"A", "B", "C"}, false)   -- Update opsi (false = reset selection)
myDrop:Refresh({"A", "B", "C"}, true)    -- Update opsi tapi pertahankan selection
myDrop:AddOption("NewOption")            -- Tambah opsi runtime
myDrop:RemoveOption("OldOption")         -- Hapus opsi runtime
print(myDrop:Get())                      -- Ambil value (string atau table)
```

---

### 🔘 Button

Tombol aksi.

```lua
-- Button biasa
Section:Button({
    Title = "Teleport",
    Desc = "Klik untuk teleport",
    Tooltip = "Teleport ke spawn point",
    Callback = function()
        print("Teleporting...")
    end,
})

-- Button Primary (menonjol, ada glow)
Section:Button({
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
| --- | --- | --- | --- |
| `Title` | string | `"Button"` | Teks tombol |
| `Desc` | string | `""` | Deskripsi |
| `Primary` | bool | `false` | Warna accent + glow |
| `Height` | number | `40` | Tinggi tombol (px) |
| `Tooltip` | string | `nil` | Tooltip saat hover |
| `Callback` | function | `nil` | Dipanggil saat diklik |

**Return:**

```lua
local btn = Section:Button({ Title = "Klik", Callback = function() end })
btn:Set("Teks Baru")   -- Ubah teks tombol
btn.Instance            -- Akses TextButton instance langsung
```

---

### ⌨️ Keybind

Bind tombol keyboard.

```lua
local myKey = Section:Keybind({
    Title = "Toggle Farm",
    Desc = "Tekan untuk toggle",
    Default = "E",
    Flag = "FarmKey",
    Tooltip = "Tekan saat binding untuk batal",
    Callback = function(keyName)
        print(keyName, "ditekan!")
    end,
    OnChanged = function(newKey)
        print("Keybind diubah ke:", newKey)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Keybind"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Default` | string/EnumItem | `"None"` | Tombol default |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
| `Callback` | function | `nil` | Dipanggil saat key ditekan di game |
| `OnChanged` | function | `nil` | Dipanggil saat user ganti key |

**Method:**

```lua
myKey:Set("Q")
myKey:Set(Enum.KeyCode.F)
print(myKey:Get())  -- Return EnumItem
```

---

### 🎨 ColorPicker

Pilih warna RGB/HSV.

```lua
local myColor = Section:ColorPicker({
    Title = "Warna ESP",
    Desc = "Pilih warna highlight",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Tooltip = "Klik swatch untuk buka picker",
    Callback = function(color)
        print("R:", color.R * 255)
        print("G:", color.G * 255)
        print("B:", color.B * 255)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Color"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Default` | Color3 | Accent theme | Warna awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
| `Callback` | function | `nil` | Dipanggil saat warna berubah |

**Method:**

```lua
myColor:Set(Color3.fromRGB(0, 255, 0))
myColor:Set(Color3.fromRGB(0, 255, 255), true)  -- silent
print(myColor:Get())  -- Return Color3
```

---

### ⌨️ Input

Text box untuk input teks.

```lua
local myInput = Section:Input({
    Title = "Nickname",
    Desc = "Masukkan nama kamu",
    Placeholder = "Ketik di sini...",
    Default = "",
    Flag = "UserNick",
    Tooltip = "Maks 20 karakter",
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
| --- | --- | --- | --- |
| `Title` | string | `"Input"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Placeholder` | string | `"Type here..."` | Teks placeholder |
| `Default` | string | `""` | Teks awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
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
local myStepper = Section:Stepper({
    Title = "Jumlah Loop",
    Desc = "Berapa kali diulang",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Flag = "LoopCount",
    Tooltip = "Default: 5x",
    Callback = function(value)
        print("Loop:", value)
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Stepper"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Range` | table | `{0, 100}` | `{min, max}` |
| `Increment` | number | `1` | Kelipatan |
| `CurrentValue` | number | `Range[1]` | Nilai awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Tooltip` | string | `nil` | Tooltip saat hover |
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
local myProgress = Section:Progress({
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
| --- | --- | --- | --- |
| `Title` | string | `"Progress"` | Judul |
| `CurrentValue` | number | `0` | Nilai awal (0 sampai 1) |
| `Format` | function | `function(v) return math.floor(v*100).."%" end` | Format teks |

**Method:**

```lua
myProgress:Set(0.5)
print(myProgress:Get())  -- Return number (0-1)
```

---

### 🖥️ Console

Terminal output real-time dengan 6 log level.

```lua
local console = Section:Console({
    Title = "Script Output",
    Height = 200,
    MaxLines = 100
})

-- Log dengan level berbeda
console:Log("Pesan biasa")
console:Info("Informasi")
console:Warn("Peringatan")
console:Error("Error terjadi!")
console:Success("Berhasil!")
console:Debug("Debug info")

-- Method tambahan
console:Clear()           -- Hapus semua log
console:GetLines()        -- Return table berisi semua teks log
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Console"` | Judul header |
| `Height` | number | `200` | Tinggi console (px) |
| `MaxLines` | number | `100` | Maksimal baris tersimpan |

**Log Levels & Warna:**

| Method | Warna | Prefix |
| --- | --- | --- |
| `Log(text)` | Abu-abu | — |
| `Info(text)` | Biru | `[INFO]` |
| `Warn(text)` | Kuning | `[WARN]` |
| `Error(text)` | Merah | `[ERROR]` |
| `Success(text)` | Hijau | `[OK]` |
| `Debug(text)` | Abu-abu muda | `[DEBUG]` |

---

### ⏳ Spinner

Loading indicator dengan kontrol start/stop.

```lua
local spinner = Section:Spinner({
    Title = "Loading data...",
    Desc = "Mohon tunggu"
})

-- Kontrol
spinner:Stop()                -- Stop animasi
spinner:Start()               -- Lanjut animasi
spinner:SetText("New text")   -- Ganti teks
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Loading"` | Judul |
| `Desc` | string | `""` | Deskripsi |

---

### ✅ Checklist

Multi-select checkbox (beda dari Dropdown Multi).

```lua
local checklist = Section:Checklist({
    Title = "Pilih Fitur",
    Desc = "Aktifkan fitur yang diinginkan",
    Options = {"Auto Farm", "Auto Sell", "Auto Fish", "Auto Upgrade", "Auto Rebirth"},
    Default = {"Auto Farm"},
    Flag = "EnabledFeatures",
    Callback = function(selected)
        for _, feature in ipairs(selected) do
            print("Enabled:", feature)
        end
    end,
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Checklist"` | Judul |
| `Desc` | string | `""` | Deskripsi |
| `Options` | table | `{}` | Daftar opsi (array of strings) |
| `Default` | table | `{}` | Opsi terpilih awal |
| `Flag` | string | `nil` | Nama unik untuk config |
| `Callback` | function | `nil` | Dipanggil saat selection berubah |

**Method:**

```lua
checklist:Set({"Auto Farm", "Auto Sell"})
checklist:Get()  -- Return table
```

---

### 🖼️ Image

Embed gambar custom.

```lua
local img = Section:Image({
    Image = "rbxassetid://123456789",
    Height = 120,
    ScaleType = Enum.ScaleType.Fit
})

-- Ganti gambar runtime
img:Set("rbxassetid://987654321")
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Image` | string | `""` | Asset ID gambar |
| `Height` | number | `120` | Tinggi (px) |
| `ScaleType` | Enum | `Fit` | ScaleType gambar |

---

### 📝 Label

Teks statis satu baris.

```lua
local myLabel = Section:Label({
    Title = "Versi: 3.0.0",
    RichText = true
})

-- RichText example
Section:Label({
    Title = '<font color="#3882ff">Blue</font> dan <b>bold</b>',
    RichText = true
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` / `Text` | string | `"Label"` | Teks yang ditampilkan |
| `RichText` | bool | `false` | Enable RichText formatting |

**Method:**

```lua
myLabel:Set("Versi: 3.0.0")
print(myLabel:Get())
```

---

### 📄 Paragraph

Teks dengan judul + deskripsi panjang.

```lua
local myPara = Section:Paragraph({
    Title = "Cara Pakai:",
    Desc = "1. Aktifkan Auto Farm\n2. Pilih map\n3. Tekan E untuk toggle"
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
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
local myTip = Section:Tooltip({
    Title = "Apa itu Flag?",
    Text = "Flag adalah nama unik untuk menyimpan pengaturan. Setiap komponen yang punya Flag akan otomatis tersimpan di config."
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Info"` | Judul |
| `Text` | string | `""` | Konten yang di-expand |

**Method:**

```lua
myTip:Expand()
myTip:Collapse()
```

---

### 🎨 ThemePicker

Auto-generate preset dropdown + custom color picker.

```lua
Section:ThemePicker({
    Title = "Tema"
})
```

**Parameter:**

| Field | Tipe | Default | Keterangan |
| --- | --- | --- | --- |
| `Title` | string | `"Theme"` | Judul section |

Ini akan otomatis membuat:
1. Dropdown dengan 10 preset warna
2. ColorPicker untuk custom accent color

---

### ➖ Divider

Garis pemisah tipis.

```lua
Section:Divider()  -- Tanpa parameter
```

---

## 🔄 Element States

Semua komponen (Toggle, Slider, Dropdown, dll) punya 3 method state:

### SetDisabled

```lua
local myToggle = Section:Toggle({ Title = "Feature" })

myToggle:SetDisabled(true)   -- Abu-abu & tidak bisa diklik
myToggle:SetDisabled(false)  -- Kembali normal
```

### SetVisible

```lua
myToggle:SetVisible(false)   -- Sembunyikan (bisa di-show lagi)
myToggle:SetVisible(true)    -- Tampilkan kembali
```

### Destroy

```lua
myToggle:Destroy()  -- Hapus permanen dari UI
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
| --- | --- | --- | --- |
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

---

## 💾 Config System

Setiap komponen yang punya `Flag` akan otomatis tersimpan.

### Auto-Generated Config Tab

```lua
Window:AddConfigTab()
```

Ini otomatis membuat tab "Settings" berisi:
- Input nama config
- Dropdown config tersimpan
- Tombol Save / Load / Delete
- ThemePicker (ganti preset + custom color)
- Indikator support file system

### Method Manual

```lua
-- Simpan config
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
Section:Toggle({ Title = "Auto Farm", Flag = "AutoFarm" })
Section:Slider({ Title = "Speed", Flag = "Speed", Min = 0, Max = 100 })
Section:Dropdown({ Title = "Map", Flag = "Map", Options = {...} })

-- 2. Load config di akhir script
task.defer(function()
    Window:LoadConfig()
end)
```

### Lokasi Penyimpanan

| Executor | Lokasi |
| --- | --- |
| Fluxus, Delta, Synapse, Arceus X | `workspace/[FolderName]/[FileName].json` |
| Executor Web / Terbatas | `_G["AKBAR_CONFIG_..."]` (sementara) |

---

## 🎨 Tema & Preset

### Ganti Preset Warna

```lua
Akbar:SetPreset("Royal Purple")
```

**10 Preset bawaan:**

- `Default Blue` (default)
- `Royal Purple`
- `Crimson Red`
- `Emerald Green`
- `Sunset Orange`
- `Ocean Teal`
- `Midnight Pink`
- `Cotton Candy`
- `Cyber Lime`
- `Deep Violet`

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
-- {"Cotton Candy", "Crimson Red", "Cyber Lime", "Default Blue", ...}
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

## 🖼️ Icon Library

100+ Lucide icons built-in.

### Cara Pakai

```lua
-- Di parameter Icon
Window:CreateTab({ Name = "Home", Icon = "home" })
Window:CreateTab({ Name = "Settings", Icon = "settings" })

-- Di parameter Icon Window
Akbar:CreateWindow({ Icon = "crown" })
```

### Custom Icon

```lua
-- Tambah icon sendiri
Akbar.AddIcon("my-icon", "rbxassetid://123456789")

-- Pakai langsung rbxassetid
Window:CreateTab({ Name = "Custom", Icon = "rbxassetid://123456789" })

-- Pakai URL gambar
Window:CreateTab({ Name = "Custom", Icon = "[https://example.com/icon.png](https://example.com/icon.png)" })
```

### Register Spritesheet

```lua
-- Untuk banyak icon sekaligus (lebih hemat memory)
IconLib:RegisterSpritesheet("MySet", "rbxassetid://123456789", {
    ["icon1"] = { Position = Vector2.new(0, 0),  Size = Vector2.new(24, 24) },
    ["icon2"] = { Position = Vector2.new(24, 0), Size = Vector2.new(24, 24) },
    ["icon3"] = { Position = Vector2.new(48, 0), Size = Vector2.new(24, 24) },
})

-- Kemudian pakai seperti biasa
Window:CreateTab({ Name = "Custom", Icon = "icon1" })
```

### Daftar Icon Lengkap

<details>
<summary><b>Klik untuk lihat semua 100+ icons</b></summary>

| Kategori | Icons |
|----------|-------|
| Navigasi | `home`, `anchor`, `compass`, `map-pin`, `globe`, `navigation` |
| User | `user`, `users`, `crown`, `heart`, `star`, `bookmark` |
| Settings | `settings`, `wrench`, `sliders`, `filter`, `tool`, `cog` |
| Files | `file`, `folder`, `save`, `copy`, `edit`, `trash`, `trash-2` |
| UI | `x`, `check`, `plus`, `minus`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `maximize`, `search` |
| Komunikasi | `mail`, `message-circle`, `message-square`, `send`, `bell`, `bell-off`, `bell-ring`, `phone` |
| Media | `play`, `pause`, `video`, `camera`, `image`, `music`, `volume`, `volume-2`, `volume-x`, `mic`, `mic-off`, `headphones` |
| Tech | `cpu`, `monitor`, `laptop`, `smartphone`, `tablet`, `tv`, `wifi`, `wifi-off`, `bluetooth`, `battery-full`, `battery-low` |
| Data | `database`, `server`, `hard-drive`, `cloud-download`, `cloud-upload`, `terminal`, `code` |
| Finance | `dollar-sign`, `credit-card`, `wallet`, `shopping-bag`, `shopping-cart`, `gift`, `ticket` |
| Charts | `bar-chart`, `pie-chart`, `activity`, `trending-up`, `trending-down`, `calendar`, `clock` |
| Security | `shield`, `lock`, `key`, `eye`, `eye-off`, `power` |
| Status | `circle-alert`, `circle-check`, `circle-x`, `circle-question`, `info`, `zap` |
| Misc | `flag`, `tag`, `rocket`, `gamepad`, `bot`, `fish`, `pickaxe`, `sprout`, `sun`, `moon`, `palette`, `link`, `share`, `download`, `upload`, `printer`, `arrow-right`, `arrow-left`, `arrow-up`, `arrow-down`, `loader-circle` |

</details>

---

## 📱 Mobile Support

Akbar UI otomatis mendeteksi device mobile dan beradaptasi.

### Fitur Mobile

| Fitur | Behavior |
|-------|----------|
| **Auto-Fit** | Window otomatis 95% dari ukuran layar HP |
| **Touch Drag** | Drag window pakai jari |
| **Touch Resize** | Resize dari pojok kanan bawah (grip diperbesar) |
| **Slider Hitbox** | Area sentuh diperluas (34px vertikal) |
| **Press Feedback** | Feedback visual saat tap |
| **Floating Button** | Tombol toggle selalu tersedia (nggak perlu keyboard) |
| **Safe Area** | Window nggak bisa keluar dari layar |

### Deteksi Manual

```lua
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobile then
    Akbar:SetAnimations(false)  -- Opsional: matikan animasi
end
```

---

## 🎛️ Window Methods

Semua method untuk kontrol window secara programmatic:

```lua
-- Show/Hide
Window:Show()
Window:Hide()
Window:Toggle()
print(Window:IsVisible())

-- Posisi & Ukuran
Window:Center()
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
Window:SetBlur(false)           -- Matikan background blur

-- Config
Window:SaveConfig("profil1")
Window:LoadConfig("profil1")
Window:DeleteConfig("profil1")
print(Window:ListConfigs())

-- Auto-generate Settings tab
Window:AddConfigTab()

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

-- Cleanup semua window sekaligus
Akbar:DestroyAll()
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
8. **Pakai Tooltip** untuk info tambahan yang nggak muat di Desc
9. **Pakai Console** untuk debug output real-time
10. **Pakai `SetDisabled`** untuk disable fitur yang belum tersedia

### ❌ DON'T (Yang Harus Dihindari)

1. ❌ Jangan pakai prefix `Create` selain `CreateWindow`/`CreateTab`
2. ❌ Jangan bikin terlalu banyak tab (max 5-7 idealnya)
3. ❌ Jangan set `Accordion = true` kalau user perlu lihat banyak section sekaligus
4. ❌ Jangan lupa panggil `Window:LoadConfig()` kalau pakai config saving
5. ❌ Jangan biarkan callback error tanpa penanganan — akan bikin UI aneh
6. ❌ Jangan simpan data sensitif (password, token) di config
7. ❌ Jangan lupa `Element:Destroy()` untuk elemen yang nggak dipakai lagi
8. ❌ Jangan pakai `Blur = true` kalau target user banyak yang pakai HP kentang

---

## 🔥 Pro Tips

### Tip 1: Matikan animasi di HP kentang

```lua
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
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
local mapDrop = Section:Dropdown({ Title = "Map", Options = {} })

task.spawn(function()
    local maps = getAvailableMaps()  -- fungsi kamu
    mapDrop:Refresh(maps)
end)
```

### Tip 4: Real-time label update

```lua
local fpsLabel = Section:Label({ Title = "FPS: 0" })

RunService.RenderStepped:Connect(function(dt)
    fpsLabel:Set("FPS: " .. math.floor(1/dt))
end)
```

### Tip 5: Progress bar dengan loop

```lua
local progress = Section:Progress({ Title = "Loading...", CurrentValue = 0 })

task.spawn(function()
    for i = 0, 100, 5 do
        progress:Set(i / 100)
        task.wait(0.1)
    end
end)
```

### Tip 6: Keybind sebagai toggle shortcut

```lua
local autoFarm = Section:Toggle({ Title = "Auto Farm", Flag = "AutoFarm" })

Section:Keybind({
    Title = "Toggle Farm",
    Default = "E",
    Callback = function()
        autoFarm:Set(not autoFarm:Get())
    end,
})
```

### Tip 7: Console untuk debugging

```lua
local console = Section:Console({ Title = "Debug", Height = 150 })

local function safeCall(fn, ...)
    local args = {...}
    console:Debug("Calling function...")
    local ok, result = pcall(fn, table.unpack(args))
    if ok then
        console:Success("Success!")
    else
        console:Error("Failed: " .. tostring(result))
    end
    return ok, result
end
```

### Tip 8: Spinner untuk async loading

```lua
local spinner = Section:Spinner({ Title = "Fetching data..." })

task.spawn(function()
    local success, data = pcall(function()
        return game:HttpGet("[https://api.example.com/data](https://api.example.com/data)")
    end)

    spinner:Stop()

    if success then
        spinner:SetText("Data loaded!")
        console:Success("Data fetched: " .. #data .. " bytes")
    else
        spinner:SetText("Failed to load")
    end
end)
```

### Tip 9: Checklist untuk multiple features

```lua
local featureChecklist = Section:Checklist({
    Title = "Active Features",
    Options = {"Auto Farm", "Auto Sell", "Auto Fish", "Auto Upgrade"},
    Default = {"Auto Farm"},
    Callback = function(selected)
        -- Update game logic berdasarkan selection
        for _, feature in ipairs(selected) do
            enableFeature(feature)
        end
    end
})
```

### Tip 10: Badge untuk notifikasi count

```lua
local alertTab = Window:CreateTab({ Name = "Alerts", Icon = "bell" })

-- Set badge count
alertTab:SetBadge(3)

-- Clear badge saat tab diklik
-- (otomatis di-clear oleh framework)
```

---

## 🩹 Troubleshooting

### Masalah Umum & Solusi

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| `attempt to call a nil value` | Pakai `Create` prefix salah | Hapus `Create`, pakai `Tab:Toggle` bukan `Tab:CreateToggle` |
| Config tidak tersimpan | Executor tidak support `writefile` | Pakai Fluxus/Delta/Synapse/Arceus X |
| Config tidak ter-load | Komponen dibuat setelah `LoadConfig` | Panggil `LoadConfig()` SETELAH semua komponen dibuat |
| Section tidak bisa diklik | Versi lama (bug overlap) | Update ke v3.0.0+ |
| Warna tidak berubah | Tidak pakai `Themed()` | Semua komponen resmi sudah otomatis |
| Mobile drag tidak smooth | Animasi terlalu berat | `Akbar:SetAnimations(false)` |
| Notifikasi numpuk terus | `MaxNotifications` terlalu besar | Set `MaxNotifications = 3` atau 5 |
| UI hilang setelah respawn | Parent ke PlayerGui | Pakai default (CoreGui) atau `gethui()` |
| Komponen overlapping | Komponen langsung di Tab, bukan Section | Bungkus dengan `Tab:Section()` dulu |
| Blur tidak muncul | Executor memblokir `Lighting` | Set `Blur = false` di config |
| `SetDisabled` tidak bekerja | Elemen dibuat sebelum v3.0.0 | Update ke v3.0.0+ |
| Dropdown search tidak muncul | Search auto-aktif hanya jika opsi > 8 | Set `Search = true` manual |
| Icon tidak muncul | Nama icon salah atau asset moderated | Cek daftar icon, pakai `fallback` |

---

## ❓ FAQ

**Q: Kenapa `ToggleUIKeybind` tidak jalan?**
A: Pastikan formatnya benar: `"RightControl"` (string) atau `Enum.KeyCode.RightControl` (EnumItem). Beberapa executor block keyboard input.

**Q: Bisa pakai di game yang ada anti-cheat?**
A: Akbar UI tidak inject apa-apa ke game, hanya bikin ScreenGui. Aman. Tapi script logic kamu sendiri yang bisa kena deteksi.

**Q: Berapa batas maksimal komponen per tab?**
A: Tidak ada batas keras, tapi 15-20 komponen idealnya. Kalau lebih, pertimbangkan pakai Section untuk grouping.

**Q: Bisa custom font?**
A: Saat ini hanya Gotham family. Custom font butuh asset font yang di-upload ke Roblox.

**Q: Kenapa background blur tidak muncul?**
A: Beberapa executor memblokir akses ke `Lighting`. Coba restart executor atau set `Blur = false`.

**Q: Bisa pakai 2 window sekaligus?**
A: Bisa! Panggil `Akbar:CreateWindow()` 2x dengan config berbeda. Tapi pastikan `ToggleUIKeybind` berbeda.

**Q: Gimana cara hapus semua UI sekaligus?**
A: Pakai `Akbar:DestroyAll()` untuk hancurkan semua window yang aktif.

**Q: Console bisa auto-scroll?**
A: Sudah otomatis! Setiap ada log baru, console otomatis scroll ke bawah.

**Q: Bisa ganti icon runtime?**
A: Bisa! `Window:SetIcon("star")` atau `Tab.IconImage.Image = "rbxassetid://123456"`.

**Q: Checklist vs Dropdown Multi, bedanya apa?**
A: Checklist pakai checkbox visual (lebih intuitif), Dropdown Multi pakai list dropdown (lebih hemat tempat). Fungsinya sama.

---

Dibuat dengan ❤️ oleh **King Akbar**

📱 Instagram: [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)
