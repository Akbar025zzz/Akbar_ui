# Changelog

Semua perubahan penting pada Akbar UI Framework dicatat di sini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/), versi pakai [Semantic Versioning](https://semver.org/).

## [3.0.1]
### Added
- `IconLib:Watch(imageInstance, iconId)` — validasi async pakai `ContentProvider:PreloadAsync`. Kalau sebuah ikon ternyata sudah dihapus/dimoderasi Roblox, otomatis diganti ke ikon fallback saat runtime alih-alih tampil kotak blank permanen. Dipasang di brand icon window & ikon tab sidebar.

### Fixed
- **Window tidak bisa di-drag**: `Header` dibuat sebagai `Frame`, yang defaultnya punya `Active = false`. Di Roblox, `Frame` (beda dengan `TextButton`/`ImageButton`) butuh `Active = true` secara eksplisit supaya event `InputBegan` kepicu oleh klik/sentuhan. Ditambahkan `Header.Active = true`.
- **ColorPicker (area Saturation/Value & Hue bar) tidak bisa di-drag**: bug yang sama persis — `SV` dan `HueBar` juga `Frame` tanpa `Active = true`. Ditambahkan `Active = true` di keduanya.

## [3.0.0]
### Added
- Komponen baru: `Stepper`, `Progress`, `Tooltip`, `ThemePicker` — total jadi 19 komponen
- 3 preset warna baru: `Cotton Candy`, `Cyber Lime`, `Deep Violet` (total 10 preset)
- Table of Contents di header file untuk navigasi source yang lebih mudah

### Changed
- Struktur kode dirapikan dengan section divider yang konsisten

## [2.0.0]
### Added
- Live Theme System — ganti tema/warna langsung reflect ke semua elemen tanpa reload UI
- 7 preset warna siap pakai (`Default Blue`, `Royal Purple`, `Crimson Red`, `Emerald Green`, `Sunset Orange`, `Ocean Teal`, `Midnight Pink`) via `Akbar:SetPreset()` dan `Akbar:ListPresets()`
- Efek glow di tombol Primary
- Animasi tactile `PressFeedback` (mengecil saat ditekan) di berbagai komponen
- Anti-spam-klik (debounce) pada `Button`
- `pcall` wrapper di callback `Button` agar error di kode user tidak meng-crash seluruh script

### Fixed
- **Section tidak bisa diklik**: Frame `Holder` di `api:Section` tidak punya `UIListLayout`, membuat Header dan isi section saling tumpang tindih sehingga hit-area toggle/slider/button di dalamnya kacau. Diperbaiki dengan menambahkan `UIListLayout` + `LayoutOrder` eksplisit (Header=1, Clip=2).
- **Script berhenti total saat membuat tab pertama** (`attempt to index function with 'BackgroundTransparency'` di `SelectTab`): disebabkan `Tab.Button` (instance tombol sidebar) ketiban oleh method `:Button()` (pembuat komponen tombol) saat proses merge `Tab.API` ke `Tab`, karena memakai nama key yang sama. Diperbaiki dengan rename field instance jadi `Tab.NavButton` dan update semua referensi terkait.

---

Format versi lama sebelum `2.0.0` tidak tercatat.
