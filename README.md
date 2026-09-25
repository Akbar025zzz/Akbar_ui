
# Akbar UI Framework

[![Luau](https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square)](https://luau-lang.org/)
[![Version](https://img.shields.io/badge/Version-1.1.2-3882FF?style=flat-square)]()
[![Tested](https://img.shields.io/badge/Environment-Delta%20%7C%20Codex%20%7C%20Wave%20%7C%20Studio-3882FF?style=flat-square)]()
[![Platform](https://img.shields.io/badge/Platform-Mobile%20%2F%20PC-1e1e2e?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

Akbar UI adalah framework antarmuka dark glassmorphism modern untuk Roblox Luau[span_0](start_span)[span_0](end_span)[span_1](start_span)[span_1](end_span). Dirancang dengan performa stabil, tata letak responsif untuk Mobile (layar sentuh) maupun PC (mouse & keyboard), tombol floating fleksibel, dan sistem penyimpanan konfigurasi berbasis JSON[span_2](start_span)[span_2](end_span)[span_3](start_span)[span_3](end_span).

---

## Daftar Isi
1. [Panduan Pemasangan Cepat](#panduan-pemasangan-cepat)
   - [Eksekutor Mobile / PC](#1-eksekutor-mobile--pc-delta-codex-wave-dll)
   - [Roblox Studio](#2-roblox-studio)
2. [Konfigurasi Jendela Utama (CreateWindow)](#konfigurasi-jendela-utama-createwindow)
3. [Manajemen Tab & Grup Menu](#manajemen-tab--grup-menu)
4. [Dokumentasi Lengkap Komponen](#dokumentasi-lengkap-komponen)
   - [Toggle](#toggle)
   - [Button](#button)
   - [Slider (Touch-Lock)](#slider)
   - [Stepper](#stepper)
   - [Dropdown](#dropdown)
   - [Input Field](#input-field)
   - [Keybind](#keybind)
   - [Color Picker](#color-picker)
   - [Progress Bar](#progress-bar)
   - [Label & Live Updater](#label)
   - [Paragraph, Section, & Divider](#elemen-tampilan)
5. [Notifikasi, Dialog, & Konfirmasi](#notifikasi-dialog--konfirmasi)
6. [Sistem Simpan Pengaturan (Config Engine)](#sistem-simpan-pengaturan-config-engine)
7. [Daftar Icon Bawaan](#daftar-icon-bawaan)
8. [Solusi Masalah Umum (Troubleshooting)](#solusi-masalah-umum-troubleshooting)

---

## Panduan Pemasangan Cepat

### 1. Eksekutor Mobile / PC (Delta, Codex, Wave, dll.)
Gunakan fungsi `loadstring` dan `game:HttpGet` untuk memuat library langsung dari GitHub[span_4](start_span)[span_4](end_span):

```lua
local Akbar = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua](https://raw.githubusercontent.com/Akbar025zzz/Akbar_ui/main/AkbarUI.lua)"))()

local Window = Akbar:CreateWindow({
    Name = "King Akbar",
    LoadingSubtitle = "v1.1.2 Mobile Edition",
    Icon = "crown"
})

local Tab = Window:CreateTab({
    Name = "Beranda",
    Icon = "home"
})

Tab:CreateButton({
    Name = "Tes Tombol",
    Callback = function()
        print("UI berjalan dengan lancar!")
    end
})
```

### 2. Roblox Studio
1. Buat **ModuleScript** baru di dalam `ReplicatedStorage` atau `StarterPlayerScripts`, beri nama `AkbarUI`.
2. Tempelkan seluruh kode dari `AkbarUI.lua` ke dalam ModuleScript tersebut[span_5](start_span)[span_5](end_span).
3. Panggil melalui **LocalScript**[span_6](start_span)[span_6](end_span):

```lua
local Akbar = require(game:GetService("ReplicatedStorage"):WaitForChild("AkbarUI"))

local Window = Akbar:CreateWindow({
    Name = "Studio Project",
    Icon = "wrench"
})
```

---

## Konfigurasi Jendela Utama (CreateWindow)

Fungsi `Akbar:CreateWindow(config)` menerima tabel konfigurasi untuk mengatur ukuran, perilaku, dan animasi awal[span_7](start_span)[span_7](end_span):

```lua
local Window = Akbar:CreateWindow({
    Name = "King Akbar",             -- Judul utama di bar navigasi atas[span_8](start_span)[span_8](end_span)
    LoadingSubtitle = "Mobile Suite",-- Deskripsi subjudul kecil[span_9](start_span)[span_9](end_span)
    Icon = "crown",                  -- Icon branding utama[span_10](start_span)[span_10](end_span)
    ToggleUIKeybind = "RightControl",-- Tombol keyboard PC untuk menyembunyikan/menampilkan UI[span_11](start_span)[span_11](end_span)
    
    -- Dimensi rekomendasi Mobile: (520, 310) | Dimensi PC: (760, 520)
    Size = UDim2.fromOffset(520, 310), 
    MinSize = Vector2.new(420, 260),
    MaxSize = Vector2.new(1050, 720),
    
    KeepOnScreen = true,             -- Menjaga posisi jendela tidak keluar dari layar kamera[span_12](start_span)[span_12](end_span)
    Accordion = false,               -- Jika true, hanya satu menu lipat yang bisa terbuka dalam satu waktu[span_13](start_span)[span_13](end_span)
    
    OpenButton = {                   -- Tombol ikon floating pojok kiri atas[span_14](start_span)[span_14](end_span)
        Icon = "crown",
        Position = UDim2.new(0, 16, 0, 16)
    },
    
    Loading = {                      -- Layar splash loading saat script baru dijalankan[span_15](start_span)[span_15](end_span)
        Enabled = true,
        Title = "AKBAR UI",
        Text = "Menyiapkan sistem...",
        Steps = {
            "Mengunduh aset",
            "Membangun antarmuka",
            "Siap digunakan"
        },
        Duration = 1.5
    },
    
    ConfigurationSaving = {          -- Sistem manajemen file pengaturan JSON[span_16](start_span)[span_16](end_span)
        Enabled = true,
        FolderName = "AkbarConfigs",  -- Nama folder penyimpanan di direktori workspace[span_17](start_span)[span_17](end_span)
        FileName = "default"         -- Nama file konfigurasi awal[span_18](start_span)[span_18](end_span)
    }
})
```

---

## Manajemen Tab & Grup Menu

### Membuat Tab
Navigasi diletakkan di sidebar sebelah kiri[span_19](start_span)[span_19](end_span):

```lua
local TabUtama = Window:CreateTab({
    Name = "Farming",
    Desc = "Otomatisasi Panen & Mining",
    Icon = "sprout"
})
```

### Membuat Collapsible Group (Menu Lipat)
Sangat berguna untuk merapikan fitur agar layar HP tidak penuh dengan scroll panjang[span_20](start_span)[span_20](end_span)[span_21](start_span)[span_21](end_span):

```lua
local GrupPanen = TabUtama:CreateCollapsible({
    Name = "Pengaturan Panen Cepat",
    Desc = "Loop panen otomatis dan jeda waktu",
    Icon = "bot",
    Open = true -- Set true agar grup langsung terbuka saat tab dimuat[span_22](start_span)[span_22](end_span)
})
```

---

## Dokumentasi Lengkap Komponen

Semua elemen di bawah ini dapat dimasukkan ke dalam `Tab` ataupun ke dalam `Collapsible Group`[span_23](start_span)[span_23](end_span).

### Toggle
Saklar switch on/off dengan area sentuh kartu menyeluruh[span_24](start_span)[span_24](end_span):
```lua
local MyToggle = TabUtama:CreateToggle({
    Name = "Auto Fishing",
    Desc = "Menangkap ikan otomatis saat umpan ditarik",
    CurrentValue = false,
    Flag = "AutoFishFlag", -- Wajib diisi jika statusnya ingin disimpan ke JSON[span_25](start_span)[span_25](end_span)
    Callback = function(state)
        print("Status toggle:", state) -- Bernilai true atau false
    end
})

-- Kontrol eksternal:
MyToggle:Set(true)   -- Mengubah status saklar secara manual[span_26](start_span)[span_26](end_span)
print(MyToggle:Get())-- Mengambil status aktif saklar saat ini[span_27](start_span)[span_27](end_span)
```

### Button
Tombol aksi interaktif dengan animasi tekanan tactile[span_28](start_span)[span_28](end_span):
```lua
TabUtama:CreateButton({
    Name = "Klaim Hadiah Harian",
    Desc = "Menjalankan fungsi penukaran hadiah",
    Icon = "zap",
    Style = "Primary", -- Pilihan tampilan: "Default" atau "Primary" (aksen biru)[span_29](start_span)[span_29](end_span)
    Callback = function()
        print("Tombol berhasil ditekan!")
    end
})
```

### Slider
Pengatur angka linear yang dilengkapi fitur pengunci scrolling agar tidak goyang di mobile[span_30](start_span)[span_30](end_span):
```lua
local MySlider = TabUtama:CreateSlider({
    Name = "Kecepatan Pemain (WalkSpeed)",
    Desc = "Mengatur batas kecepatan langkah karakter",
    Range = {16, 200},        -- Batas minimum dan maksimum[span_31](start_span)[span_31](end_span)
    Increment = 1,            -- Nilai interval pergeseran[span_32](start_span)[span_32](end_span)
    CurrentValue = 16,        -- Nilai default awal[span_33](start_span)[span_33](end_span)
    Suffix = " spd",          -- Satuan teks di samping kanan angka[span_34](start_span)[span_34](end_span)
    Flag = "WalkSpeedFlag",   -- Flag konfigurasi JSON[span_35](start_span)[span_35](end_span)
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

MySlider:Set(50) -- Memperbarui nilai slider lewat script[span_36](start_span)[span_36](end_span)
```

### Stepper
Pengatur angka presisi menggunakan tombol minus (`-`) dan plus (`+`)[span_37](start_span)[span_37](end_span):
```lua
TabUtama:CreateStepper({
    Name = "Radius Deteksi Target",
    Range = {5, 100},
    Increment = 5,
    CurrentValue = 25,
    Flag = "RadiusFlag",
    Callback = function(val)
        print("Radius saat ini:", val)
    end
})
```

### Dropdown
Menu pilihan yang mendukung mode pemilihan tunggal maupun banyak opsi sekaligus[span_38](start_span)[span_38](end_span):
```lua
local MyDropdown = TabUtama:CreateDropdown({
    Name = "Sasaran Monster",
    Options = {"Goblin", "Bandit", "Lava Golem", "Dragon"},
    CurrentOption = "Goblin",
    MultipleOptions = false, -- Ganti true jika ingin bisa memilih lebih dari satu opsi[span_39](start_span)[span_39](end_span)
    Flag = "MonsterTargetFlag",
    Callback = function(selected)
        print("Opsi terpilih:", selected)
    end
})

-- Memperbarui daftar opsi saat runtime:
MyDropdown:Refresh({"NPC Baru A", "NPC Baru B"})[span_40](start_span)[span_40](end_span)
```

### Input Field
Kolom pengetikan teks atau angka dari pemain[span_41](start_span)[span_41](end_span):
```lua
TabUtama:CreateInput({
    Name = "Target Teleportasi",
    PlaceholderText = "Ketik username...",
    Numeric = false, -- Ubah true jika input hanya boleh menerima karakter angka[span_42](start_span)[span_42](end_span)
    Flag = "TargetNameFlag",
    Callback = function(text, enterPressed)
        print("Teks:", text, "| Ditekan Enter:", enterPressed)
    end
})
```

### Keybind
Perekam shortcut keyboard (kompatibel PC)[span_43](start_span)[span_43](end_span):
```lua
TabUtama:CreateKeybind({
    Name = "Tombol Teleportasi Cepat",
    CurrentKeybind = "E",
    Flag = "QuickTeleportKey",
    Callback = function(keyName)
        print("Tombol dipicu:", keyName)
    end,
    OnChanged = function(newKey)
        print("Keybind berhasil diubah ke:", newKey)
    end
})
```

### Color Picker
Palet warna dinamis lengkap dengan preset warna instan[span_44](start_span)[span_44](end_span):
```lua
TabUtama:CreateColorPicker({
    Name = "Warna ESP Visual",
    Default = Color3.fromRGB(56, 130, 255),
    Flag = "VisualColorFlag",
    Callback = function(col)
        print("Warna terpilih:", col)
    end
})
```

### Progress Bar
Indikator visual kemajuan (rentang 0.0 hingga 1.0)[span_45](start_span)[span_45](end_span):
```lua
local MyBar = TabUtama:CreateProgress({
    Name = "Kapasitas Ransel",
    CurrentValue = 0.5, -- 50%[span_46](start_span)[span_46](end_span)
    Format = function(val)
        return math.floor(val * 100) .. "% Penuh[span_47](start_span)"[span_47](end_span)
    end
})

MyBar:Set(0.85) -- Mengubah progress bar menjadi 85%[span_48](start_span)[span_48](end_span)
```

### Label
Menampilkan teks informasi biasa atau teks dinamis yang diperbarui otomatis berdasarkan interval waktu[span_49](start_span)[span_49](end_span):
```lua
-- Label statis:
local Status = TabUtama:CreateLabel({
    Text = "Status: Idle"
})
Status:Set("Status: Sedang Berjalan")[span_50](start_span)[span_50](end_span)

-- Live Dynamic Label:
TabUtama:CreateLabel({
    Text = "Pemain Online: Menghitung...",
    UpdateRate = 2, -- Diperbarui setiap 2 detik[span_51](start_span)[span_51](end_span)[span_52](start_span)[span_52](end_span)
    Update = function()
        return "Pemain Online: " .. #game:GetService("Players"):GetPlayers()[span_53](start_span)[span_53](end_span)[span_54](start_span)[span_54](end_span)
    end
})
```

### Elemen Tampilan
```lua
TabUtama:CreateSection("Kategori Tambahan") -- Teks penanda kategori berwarna aksen[span_55](start_span)[span_55](end_span)
TabUtama:CreateDivider()                     -- Garis pembatas horizontal tipis[span_56](start_span)[span_56](end_span)

TabUtama:CreateParagraph({                   -- Kotak ringkasan penjelasan panjang[span_57](start_span)[span_57](end_span)
    Title = "Petunjuk Penggunaan",
    Content = "Pastikan fitur dieksekusi di zona yang aman agar proses loop berjalan lancar tanpa kendala lag."
})
```

---

## Notifikasi, Dialog, & Konfirmasi

### Notifikasi Melayang
Muncul di pojok kanan bawah dengan durasi progress bar otomatis[span_58](start_span)[span_58](end_span):
```lua
Window:Notify({
    Title = "King Akbar",
    Content = "Perubahan konfigurasi berhasil disimpan!",
    Duration = 3.5, -- Durasi tampil dalam detik[span_59](start_span)[span_59](end_span)
    Icon = "check"  -- Icon notifikasi[span_60](start_span)[span_60](end_span)
})
```

### Modal Konfirmasi (Yes / No)
Memblokir aksi berbahaya sampai dikonfirmasi pengguna[span_61](start_span)[span_61](end_span):
```lua
Window:Confirm({
    Title = "Reset Data",
    Content = "Apakah kamu yakin ingin menghapus file konfigurasi ini?",
    ConfirmText = "Ya, Hapus",
    CancelText = "Batal",
    Callback = function(confirmed)
        if confirmed then
            print("Pengguna menekan Konfirmasi.")
        else
            print("Pengguna membatalkan aksi.")
        end
    end
})
```

---

## Sistem Simpan Pengaturan (Config Engine)

Semua komponen yang memiliki parameter `Flag` otomatis terhubung dengan modul JSON terintegrasi[span_62](start_span)[span_62](end_span). File akan tersimpan ke folder eksekutor kamu (`writefile` / `readfile`)[span_63](start_span)[span_63](end_span):

```lua
-- Menyimpan state komponen saat ini ke file 'profil1.json'
Window:SaveConfig("profil1")[span_64](start_span)[span_64](end_span)

-- Memuat kembali data yang tersimpan dari 'profil1.json'
Window:LoadConfig("profil1")[span_65](start_span)[span_65](end_span)

-- Menghapus file 'profil1.json'
Window:DeleteConfig("profil1")[span_66](start_span)[span_66](end_span)

-- Mendapatkan array daftar semua nama file konfigurasi yang ada di folder
local list = Window:ListConfigs()[span_67](start_span)[span_67](end_span)
print("File tersedia:", table.concat(list, ", "))
```

---

## Daftar Icon Bawaan

Framework menyediakan pustaka ikon siap pakai tanpa perlu mencari URL gambar eksternal[span_68](start_span)[span_68](end_span):

| Nama Icon | Fungsi / Tema | Nama Icon | Fungsi / Tema |
| :--- | :--- | :--- | :--- |
| `crown` | Mahkota / Brand Utama | `fish` | Memancing |
| `anchor` | Jangkar / Tab Umum | `pickaxe` | Menambang / Mining |
| `bot` | Otomatisasi / Bot Farm | `sprout` | Pertanian / Farming |
| `zap` | Kilat / Aksi Cepat | `shield` | Proteksi / Pertahanan |
| `wrench` | Peralatan / Perkakas | `refresh-cw`| Reset / Sinkronisasi Ulang |
| `settings` | Pengaturan Menu | `search` | Kolom Pencarian |
| `home` | Halaman Awal | `info` | Petunjuk / Info Sistem |
| `user` | Profil Tunggal | `users` | Multi-pemain |
| `check` | Simbol Sukses / Simpan | `x` | Tombol Tutup |
| `minus` | Perkecil / Minimize | `maximize` | Perbesar / Fullscreen |
| `palette` | Palet Warna / Tema | `chevron-down` | Panah Lipat Bawah |

---

## Solusi Masalah Umum (Troubleshooting)

### 1. Tombol atau Switch Toggle Tidak Bisa Dipencet di HP
* **Penyebab:** Versi UI lama menggunakan event `.MouseButton1Click` yang sering tertelan oleh gestur sentuhan pada `ScrollingFrame`[span_69](start_span)[span_69](end_span).
* **Solusi:** Gunakan file `AkbarUI.lua` versi terbaru (v1.1.2) yang sudah diperbarui dengan event `.Activated` dan pembungkus hitbox tombol penuh[span_70](start_span)[span_70](end_span).

### 2. Error Merah: `attempt to index nil with 'WaitForChild'`
* **Penyebab:** Menggunakan `require(script.Parent...)` di dalam eksekutor Roblox[span_71](start_span)[span_71](end_span). Variabel `script` di eksekutor bernilai `nil`[span_72](start_span)[span_72](end_span).
* **Solusi:** Gunakan metode pemanggilan `loadstring(game:HttpGet(...))` resmi dari GitHub[span_73](start_span)[span_73](end_span)[span_74](start_span)[span_74](end_span).

### 3. Tampilan Halaman Kosong / Fitur Tidak Terlihat
* **Penyebab:** Fitur ditaruh di dalam `Collapsible Group` yang disetel `Open = false`[span_75](start_span)[span_75](end_span).
* **Solusi:** Klik judul menu lipat tersebut untuk membukanya, atau ubah konfigurasi menjadi `Open = true` pada skrip kamu[span_76](start_span)[span_76](end_span).

### 4. Tombol Ikon Floating Tidak Sengaja Terpencet Saat Menggeser Layar
* **Solusi:** Tombol floating dilengkapi threshold toleransi gerak seret[span_77](start_span)[span_77](end_span). Sentuh dan seret ikon ke area layar yang kosong agar tidak menghalangi kendali joystick game.

---

## Lisensi

Proyek ini berada di bawah naungan Lisensi **MIT**[span_78](start_span)[span_78](end_span). Kamu memiliki kebebasan penuh untuk menggunakan, mengadaptasi, serta memodifikasi kode untuk proyek skrip pribadi maupun publik[span_79](start_span)[span_79](end_span).
