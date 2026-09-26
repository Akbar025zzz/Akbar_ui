
# Akbar UI Framework

**Modern Dark Glassmorphism UI Library untuk Roblox Luau**

UI framework ringan, cepat, dan responsif (PC + Mobile) buat script Roblox — dipakai di seluruh proyek King Akbar (Drag Race Simulator, Indo Hangout Hub, Car Driving Indonesia).

- 🎨 Dark glassmorphism, 7 preset warna siap pakai, custom theme
- 📱 Full mobile support — drag, resize, semua komponen touch-friendly
- 🧩 14 komponen siap pakai (Toggle, Slider, Dropdown, Stepper, Progress Bar, dll)
- 💾 Config save/load otomatis (per-flag, tersimpan sebagai JSON)
- ⚡ Animasi tactile & glow di tombol Primary
- 🛡️ Callback dibungkus `pcall` — error di script kamu nggak bikin UI crash total

---

## 📦 Instalasi

Load langsung dari GitHub pakai `loadstring`:

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()
```

> ⚠️ **Penting:** semua nama method komponen **tidak pakai prefix "Create"** — jadi `Tab:Section(...)`, bukan `Tab:CreateSection(...)`. Cuma dua method di level atas yang pakai prefix "Create": `Akbar:CreateWindow(...)` dan `Window:CreateTab(...)`.

---

## 🚀 Quick Start

```lua
local Akbar = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/refs/heads/main/AkbarUI.lua"
))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "Auto Farm Suite",
    Icon = "crown",
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled = true, FolderName = "KingAkbar", FileName = "config" },
})

local Tab = Window:CreateTab({ Name = "Utama", Icon = "home" })

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
    end,
})
```

---

## 📖 Referensi API

### `Akbar:CreateWindow(config)`

Bikin window utama. Balikin objek `Window`.

| Field | Tipe | Default | Keterangan |
|---|---|---|---|
| `Name` | string | `"King Akbar"` | Judul window |
| `LoadingSubtitle` / `Subtitle` | string | `"King Akbar"` | Subjudul di header |
| `Icon` | string | `"crown"` | Nama ikon bawaan atau `rbxassetid://...` |
| `ToggleUIKeybind` / `ToggleKey` | string/EnumItem | `"RightControl"` | Tombol buat show/hide window |
| `Size` | UDim2 | `760x520` | Ukuran awal window |
| `MinSize` / `MaxSize` | Vector2 | `480x360` / `1100x750` | Batas resize |
| `MaxNotifications` | number | `5` | Maksimal notifikasi numpuk sekaligus |
| `KeepOnScreen` | bool | `true` | Cegah window ke-drag keluar layar |
| `Accordion` | bool | `false` | Kalau `true`, buka 1 section otomatis nutup section lain |
| `SearchEnabled` | bool | `true` | Tampilkan search box buat filter tab |
| `OpenButton` | table/false | `{}` | Tombol melayang buat toggle window. `false` buat matiin. Isi: `{ Icon, Position }` |
| `Loading` | table | — | `{ Enabled, Title, Text, Steps = {...}, Duration }` — layar loading di awal |
| `ConfigurationSaving` | table | — | `{ Enabled, FolderName, FileName }` |
| `DisplayOrder` | number | `100` | ZIndex ScreenGui |
| `Parent` | Instance | CoreGui/gethui | Parent custom buat ScreenGui |
| `CloseBehavior` | string | — | `"Destroy"` biar tombol close langsung hancurin window (default cuma sembunyiin) |

### Metode `Window`

| Metode | Keterangan |
|---|---|
| `Window:Toggle()` | Show/hide window |
| `Window:Center()` | Pindahin window ke tengah layar |
| `Window:SetSize(UDim2)` / `Window:GetSize()` | Atur/ambil ukuran |
| `Window:SetMinSize(Vector2)` / `Window:SetMaxSize(Vector2)` | Batas resize |
| `Window:SetTitle(text)` / `Window:SetSubtitle(text)` | Ganti judul/subjudul |
| `Window:SetIcon(iconAsset)` | Ganti ikon header |
| `Window:SetToggleKey(key)` | Ganti keybind toggle |
| `Window:SetAccordion(bool)` | Ganti mode accordion section |
| `Window:SetSearchEnabled(bool)` | Nyalain/matiin search box |
| `Window:SaveConfig(name?)` / `Window:LoadConfig(name?)` | Simpan/muat config (default file: `default`) |
| `Window:DeleteConfig(name?)` / `Window:ListConfigs()` | Hapus/list config tersimpan |
| `Window:Notify(data)` | Tampilkan notifikasi melayang |
| `Window:Confirm(data)` | Modal konfirmasi (Ya/Batal) |
| `Window:Dialog(data)` | Modal custom dengan tombol bebas |
| `Window:CreateTab(config)` | Bikin tab baru |
| `Window:SelectTab(tab / nama / index)` | Pindah ke tab tertentu |
| `Window:Destroy()` | Hancurin window & lepas semua koneksi |

---

### `Window:CreateTab(config)`

```lua
local Tab = Window:CreateTab({ Name = "Farming", Desc = "Fitur auto farm", Icon = "sprout" })
```

| Field | Tipe | Keterangan |
|---|---|---|
| `Name` | string | Nama tab (wajib) |
| `Desc` / `Description` | string | Subjudul di header konten |
| `Icon` | string | Nama ikon bawaan atau asset id |

Bisa juga dipanggil singkat: `Window:CreateTab("Farming", "sprout")`.

Setiap `Tab` (dan setiap `Section`, lihat di bawah) punya method yang sama buat bikin komponen:

---

### Komponen

Semua contoh di bawah pakai `Tab:...`, tapi persis sama kalau dipanggil dari dalam `Section:...`.

#### `Tab:Section(config)` — Grup collapsible

```lua
local Sec = Tab:Section({ Title = "Pengaturan Lanjutan", Open = true })
Sec:Toggle({ Title = "Contoh di dalam section", Callback = function(v) end })
```
| Field | Tipe | Default |
|---|---|---|
| `Title` | string | `"Section"` |
| `Open` | bool | `true` |

Balikan: `Section:Collapse()`, `Section:Expand()`, `Section:SetExpanded(bool)`, plus semua method komponen (nested).

#### `Tab:Toggle(config)`

```lua
Tab:Toggle({
    Title = "Auto Farm", Desc = "Deskripsi opsional",
    Default = false, Flag = "AutoFarm",
    Callback = function(value) end,
})
```
Balikan: `{ Value, Set(value, silent), Get() }`

#### `Tab:Slider(config)`

```lua
Tab:Slider({
    Title = "Jarak Farm", Min = 0, Max = 100, Default = 50,
    Precision = 0, Step = nil, Suffix = " studs", Flag = "FarmRange",
    Callback = function(value) end,
})
```
Balikan: `{ Value, Set(value, silent), Get() }`

#### `Tab:Dropdown(config)`

```lua
-- Single select
Tab:Dropdown({ Title = "Pilih Map", Options = {"Map A","Map B"}, Default = "Map A", Callback = function(v) end })

-- Multi select
Tab:Dropdown({ Title = "Pilih Item", Options = {"A","B","C"}, Multi = true, Default = {"A"}, Callback = function(v) end })
```
Balikan: `{ Value, Set(v, silent), Get(), Refresh(newOptions, keepSelection) }`

#### `Tab:Button(config)`

```lua
Tab:Button({ Title = "Jalankan", Primary = true, Height = 40, Callback = function() end })
```
`Primary = true` kasih warna accent + glow tipis. Balikan: `{ Instance, Set(text) }`

#### `Tab:Label(config)` & `Tab:Paragraph(config)`

```lua
Tab:Label({ Title = "Teks statis singkat" })
Tab:Paragraph({ Title = "Judul", Desc = "Teks panjang di bawah judul." })
```

#### `Tab:Divider()`

Garis pemisah tipis, tanpa parameter.

#### `Tab:Keybind(config)`

```lua
Tab:Keybind({
    Title = "Toggle Farm", Default = "E", Flag = "FarmKey",
    Callback = function(keyName) end,     -- dipanggil pas keybind ditekan
    OnChanged = function(newKey) end,     -- dipanggil pas keybind diganti
})
```

#### `Tab:ColorPicker(config)`

```lua
Tab:ColorPicker({ Title = "Warna ESP", Default = Color3.fromRGB(255,0,0), Callback = function(color) end })
```

#### `Tab:Input(config)`

```lua
Tab:Input({
    Title = "Nickname", Placeholder = "Ketik di sini...",
    Callback = function(text, enterPressed) end,
})
```

#### `Tab:Stepper(config)`

```lua
Tab:Stepper({
    Title = "Jumlah Loop", Range = {1, 10}, Increment = 1, CurrentValue = 1,
    Callback = function(value) end,
})
```
Balikan: `{ Value, Set(v, silent), Get() }`

#### `Tab:Progress(config)`

```lua
local Bar = Tab:Progress({ Title = "Progress Upgrade", CurrentValue = 0.4, Format = function(v) return math.floor(v*100).."%" end })
Bar:Set(0.7) -- update progress kapan saja
```
Balikan: `{ Value, Set(v) }`

#### `Tab:Tooltip(config)`

```lua
Tab:Tooltip({ Title = "Apa itu Flag?", Text = "Penjelasan panjang di sini, bisa diklik buka-tutup." })
```
Balikan: `{ Expand(), Collapse() }`

---

### Notifikasi & Modal

```lua
Window:Notify({ Title = "Berhasil", Content = "Auto farm diaktifkan.", Duration = 3, Icon = "check", Type = "success" })
-- Type: "success" | "warning" | "error" | nil (info/default)

Window:Confirm({
    Title = "Yakin?", Content = "Reset semua pengaturan?",
    ConfirmText = "Ya", CancelText = "Batal",
    Callback = function(confirmed) end,
})

Window:Dialog({
    Title = "Pilih Aksi", Content = "Mau ngapain?",
    Buttons = {
        { Name = "Simpan", Primary = true, Callback = function() end },
        { Name = "Batal", Callback = function() end },
    },
})
```

---

### Config Save/Load

Setiap komponen yang punya `Flag = "NamaUnik"` otomatis kedaftar ke sistem config. Nilainya (termasuk `Color3` dan `EnumItem`/Keybind) disimpan sebagai JSON di `writefile` (fallback ke `_G` kalau executor nggak dukung file system).

```lua
Window:SaveConfig("profil1")   -- simpan
Window:LoadConfig("profil1")   -- muat lagi (dipanggil kapan saja, misal pas script start)
Window:ListConfigs()           -- {"profil1", "default", ...}
Window:DeleteConfig("profil1")
```

---

### Tema & Preset Warna

```lua
Akbar:SetPreset("Royal Purple")   -- ganti accent color instan, live ke semua elemen
Akbar:ListPresets()               -- daftar semua nama preset

Akbar:SetAccentColor(Color3.fromRGB(255, 200, 0))  -- warna custom bebas

Akbar:SetTheme({ Background = Color3.fromRGB(10,10,15) })  -- override field tema manapun

Akbar:SetAnimations(false)  -- matiin semua tween (instan, buat device low-end)
```

**Preset bawaan:** `Default Blue`, `Royal Purple`, `Crimson Red`, `Emerald Green`, `Sunset Orange`, `Ocean Teal`, `Midnight Pink`.

---

### Ikon Bawaan

`crown`, `anchor`, `fish`, `pickaxe`, `bot`, `sprout`, `settings`, `home`, `info`, `user`, `users`, `zap`, `shield`, `wrench`, `refresh-cw`, `layout-dashboard`, `scroll-text`, `search`, `x`, `minus`, `maximize`, `chevron-down`, `chevron-up`, `check`, `save`, `palette`.

Bisa juga langsung pakai `rbxassetid://...` atau URL gambar buat ikon custom.

---

## 🩹 Troubleshooting

| Gejala | Penyebab Umum |
|---|---|
| Method error `attempt to call a nil value` | Salah nama method — cek nggak pakai prefix `Create` (kecuali `CreateWindow`/`CreateTab`) |
| Komponen di dalam Section nggak bisa diklik | Pastikan pakai versi terbaru — bug overlap Header/Section sudah diperbaiki di v2.0.1 |
| Config nggak kesimpen | Pastikan tiap komponen punya `Flag` unik, dan executor mendukung `writefile`/`readfile` |
| Warna nggak berubah abis `SetTheme`/`SetPreset` | Pastikan komponen dibuat pakai fungsi `Themed()` bawaan (semua komponen resmi sudah otomatis) |

---

## 📝 Changelog

**v2.0.1**
- Fix: elemen di dalam `Section` (collapsible) saling tumpang tindih dengan header-nya
- Fix: instance tombol sidebar tab ketiban method `:Button()` sehingga tab kedua dst. gagal dibuat
- Fix: callback `Button` dibungkus `pcall` biar error di script user nggak menghentikan seluruh UI
- Baru: komponen `Stepper`, `Progress`, `Tooltip`
- Baru: 7 preset warna via `Akbar:SetPreset()`
- Baru: animasi tactile (`PressFeedback`) & glow di tombol Primary

**v2.0.0**
- Rilis awal: Window, Tab, Section, Toggle, Slider, Dropdown, Button, Label, Paragraph, Divider, Keybind, ColorPicker, Input, Notify, Confirm, Dialog, Config Save/Load, Live Theme

---

## 📄 Lisensi

Dibuat oleh **King Akbar**. Bebas dipakai untuk proyek pribadi maupun publik — mohon cantumkan credit kalau di-redistribute.

- Instagram: [@akbaritusiapa](https://www.instagram.com/akbaritusiapa)
