# BLUEPRINT PROYEK: Calculator 2026 Pro

**Nama paket:** `quiet_luxury_calculator_flutter`  
**Versi:** 1.0.0+1  
**Platform:** Flutter (Android, iOS, Web, Windows, macOS, Linux)  
**Bahasa:** Dart SDK ^3.11.4  
**Repository:** https://github.com/sholahddn25-prog/calculator_2026  
**Branch pengembangan:** `blackboxai/fix-scroll-symbol-contrast`  
**Base branch:** `main`  
**Dokumen:** Blueprint v1.0 (per commit `94ff81e`)

---

## Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Visi, Misi, dan Prinsip Desain](#2-visi-misi-dan-prinsip-desain)
3. [Arsitektur Teknis](#3-arsitektur-teknis)
4. [Struktur Direktori](#4-struktur-direktori--inventaris-file)
5. [Lapisan Presentasi (UI/UX)](#5-lapisan-presentasi-uiux)
6. [Lapisan Domain & Logika Bisnis](#6-lapisan-domain--logika-bisnis)
7. [Pengaturan Pengguna](#7-pengaturan-pengguna)
8. [Sistem Desain](#8-sistem-desain-design-system)
9. [Alur Pengguna](#9-alur-pengguna-user-flows)
10. [Model Data](#10-model-data)
11. [Platform & Build](#11-platform--build)
12. [Keamanan & Privasi](#12-keamanan--privasi)
13. [Testing & Kualitas](#13-testing--kualitas-kode)
14. [Riwayat Git](#14-riwayat-git--branching)
15. [Known Issues](#15-keterbatasan-known-issues)
16. [Roadmap](#16-roadmap-pengembangan)
17. [Diagram Komponen](#17-diagram-komponen)
18. [State Machine](#18-diagram-state-machine-kalkulator)
19. [Spesifikasi Non-Fungsional](#19-spesifikasi-non-fungsional)
20. [Glosarium](#20-glosarium)

---

## 1. Ringkasan Eksekutif

**Calculator 2026 Pro** adalah aplikasi kalkulator multi-platform berbasis Flutter dengan positioning **premium / professional grade**. Aplikasi menggabungkan:

- Kalkulator standar (aritmatika dasar)
- Mode scientific (trigonometri, logaritma, pangkat, faktorial, dll.)
- Konverter satuan (panjang, berat, volume, suhu)
- Alat praktis (tip, diskon, persentase)
- Riwayat perhitungan, memori, undo, salin/tempel
- Pengaturan persisten lokal
- Splash screen animasi 3D saat startup
- Desain UI glassmorphism + palet teal–gold

Aplikasi **offline-first**: tidak memerlukan server; data pengaturan disimpan di perangkat.

---

## 2. Visi, Misi, dan Prinsip Desain

### 2.1 Visi

Menjadi kalkulator harian yang terasa setara aplikasi flagship (iOS Calculator, Samsung Calculator Pro) dengan identitas visual sendiri: modern, tenang (quiet luxury), dan kaya fitur tanpa terasa rumit.

### 2.2 Misi

1. Menyediakan perhitungan cepat dan akurat dengan feedback visual/haptik yang jelas.
2. Mengurangi kesalahan pengguna lewat pratinjau hasil, undo, dan pesan error eksplisit.
3. Menyimpan preferensi pengguna secara persisten.
4. Menyediakan alat kehidupan sehari-hari (tip, diskon, konverter) dalam satu aplikasi.

### 2.3 Prinsip UX/UI

| Prinsip | Implementasi |
|---------|----------------|
| Clarity | Kontras tinggi di mode terang (#0B1220 untuk hasil) |
| Depth | Tombol 3D press, splash 3D, bayangan berlapis |
| Feedback | Haptic, animasi scale/tilt, SnackBar konfirmasi |
| Consistency | Material 3, Plus Jakarta Sans, radius 18–32px |
| Accessibility | FittedBox pada display, tooltip pada tombol aksi |

---

## 3. Arsitektur Teknis

### 3.1 Pola Arsitektur

Layered architecture tanpa state management eksternal:

```
Presentation Layer
  SplashScreen, CalculatorScreen, Widgets (Keypad, Display, Sheets)

State / Controller
  CalculatorScreen State, CalculatorPreferences (ChangeNotifier)

Domain / Business Logic
  CalculatorEngine, ScientificCalculator, UnitConverter, NumberFormatting

Data / Models
  Operator, HistoryItem, CalcSnapshot, SharedPreferences
```

### 3.2 Alur Startup

1. `main.dart` → `WidgetsFlutterBinding.ensureInitialized`
2. `SystemChrome` status bar transparan
3. `CalculatorPreferences.instance.load()`
4. `runApp(Calculator2026App)`
5. `MaterialApp` → `SplashScreen` (animasi 3D ~2.4 detik)
6. Transisi fade+scale → `CalculatorScreen`

### 3.3 Dependency

| Paket | Fungsi |
|-------|--------|
| flutter | Framework UI |
| google_fonts | Plus Jakarta Sans |
| shared_preferences | Persistensi pengaturan |
| cupertino_icons | Ikon |

---

## 4. Struktur Direktori & Inventaris File

```
lib/
├── main.dart
└── app/calculator/
    ├── screens/
    │   ├── splash_screen.dart
    │   └── calculator_screen.dart
    ├── theme/app_theme.dart
    ├── models/
    │   ├── operator.dart
    │   ├── scientific_operator.dart
    │   ├── history_item.dart
    │   └── calc_snapshot.dart
    ├── utils/
    │   ├── calculator_engine.dart
    │   ├── calc_result.dart
    │   ├── scientific_calculator.dart
    │   ├── unit_converter.dart
    │   ├── number_formatting.dart
    │   ├── calculator_preferences.dart
    │   └── animations/
    └── widgets/
        ├── calc_key_button.dart
        ├── calculator_keypad.dart
        ├── memory_bar.dart
        ├── premium_background.dart
        ├── premium_display.dart
        ├── scientific_panel.dart
        ├── history_sheet.dart
        ├── converter_sheet.dart
        ├── settings_sheet.dart
        ├── tools_sheet.dart
        └── sheet_header.dart
```

**Total:** 27 file Dart di `lib/`

---

## 5. Lapisan Presentasi (UI/UX)

### 5.1 Splash Screen

- Durasi ~3 detik
- Kubus 3D dengan Matrix4 perspective (rotateX, rotateY)
- Orbs animasi, branding CALCULATOR 2026 PRO
- Transisi ke CalculatorScreen (550ms)

### 5.2 Calculator Screen

Layout (max 420px):

- Header: Riwayat | Judul gradien | Scientific | Menu
- Mode chip: Standard / Scientific
- PremiumDisplay (glass): Undo, Salin, Tempel, history, live preview, hasil
- MemoryBar: MC, MR, M+, M−
- CalculatorKeypad atau ScientificPanel

Overlays: History, Converter, Settings, Tools (modal + backdrop)

### 5.3 Keypad (5 baris)

| Baris | Tombol |
|-------|--------|
| 1 | AC, ⌫, +/−, ÷ |
| 2 | 7, 8, 9, × |
| 3 | 4, 5, 6, − |
| 4 | 1, 2, 3, + |
| 5 | 0 (2x), ., = |

### 5.4 Scientific Panel

sin, cos, tan, invers, ln, log, √, ∛, xʸ, n!, 1/x, π, e, eˣ (tombol `(`, `)`, `mod` nonaktif)

### 5.5 Sheets

- **History:** panel kiri, tap untuk pakai ulang, hapus semua
- **Converter:** panjang, berat, volume, suhu + swap
- **Settings:** 4 grup (tampilan, perhitungan, interaksi, riwayat)
- **Tools:** tip, diskon, % dari → apply ke kalkulator

---

## 6. Lapisan Domain & Logika Bisnis

### 6.1 State Kalkulator

| Variabel | Deskripsi |
|----------|-----------|
| display | Tampilan angka/error |
| history | Ekspresi ringkas |
| prevValue | Operand pertama |
| operator | Operator aktif |
| waitingForOperand | Menunggu operand 2 |
| hasError | Mode error |
| memoryValue | Memori |
| historyLog | Riwayat sesi |
| _undoStack | Maks 24 snapshot |

### 6.2 Calculator Engine

- `calculate()` → `CalcResult` (ok atau error)
- Pembagian nol → "Tidak dapat dibagi nol"
- `preview()` untuk live preview
- Rantai operasi: hitung intermediate saat operator baru

### 6.3 Scientific Calculator

Trig (derajat/radian via prefs), log, sqrt, cbrt, pow, factorial, reciprocal, π, e, exp.

### 6.4 Number Formatting

Desimal (0–8), pemisah ribuan, notasi ilmiah otomatis (|x| ≥ 1e10 atau sangat kecil).

### 6.5 Unit Converter

Panjang → meter, berat → kg, volume → liter, suhu formula khusus C/F/K.

### 6.6 Tools

- **Tip:** tip, total, per orang
- **Diskon:** diskon, harga akhir
- **% dari:** bagian dari nilai

### 6.7 Undo & Live Preview

Undo restore CalcSnapshot. Preview tampil `≈ hasil` saat operator + prevValue + operand aktif.

---

## 7. Pengaturan Pengguna

| Pengaturan | Default | Storage key |
|------------|---------|-------------|
| Angka desimal | 2 | decimal_places |
| Pemisah ribuan | on | thousand_separator |
| Getaran haptik | on | haptic_enabled |
| Trigonometri | derajat | use_degrees |
| Buka scientific | off | scientific_on_start |
| Tema | sistem | theme_preference |
| Ukuran display | 52 | display_font_size |
| Notasi ilmiah | off | scientific_notation |
| Maks riwayat | 50 | max_history_items |
| Konfirmasi hapus | on | confirm_clear_history |
| Salin otomatis | off | auto_copy_result |

Singleton: `CalculatorPreferences.instance` + ChangeNotifier.

---

## 8. Sistem Desain (Design System)

### 8.1 Warna

**Light:** primary #0F766E, gold #D4AF37, teks hasil #0B1220  
**Dark:** primary #5EEAD4, gold #D4AF37, background #030712

### 8.2 Tipografi

Plus Jakarta Sans — display 40–72px weight 300.

### 8.3 Animasi

Splash 3D 2200ms, key press 140ms, display switch 350ms, orbs 12s loop.

---

## 9. Alur Pengguna (User Flows)

1. **Dasar:** digit → operator → digit → = → riwayat
2. **Error:** 5 ÷ 0 = → pesan error → AC reset
3. **Undo:** salah tap → Undo → restore
4. **Scientific xʸ:** base → xʸ → exponent → =
5. **Tools:** hitung → Gunakan hasil di kalkulator

---

## 10. Model Data

**HistoryItem:** id, calculation, result, timestamp  
**CalcSnapshot:** display, history, prevValue, operator, waitingForOperand, hasError  
**CalcResult:** value | errorMessage

---

## 11. Platform & Build

```bash
flutter pub get
flutter run
flutter run -d chrome
flutter build apk --release
flutter build windows --release
```

---

## 12. Keamanan & Privasi

- Tidak ada server / analytics
- SharedPreferences hanya pengaturan
- Riwayat in-memory (hilang saat app ditutup)
- Clipboard untuk salin/tempel

---

## 13. Testing & Kualitas Kode

- `flutter analyze` — tanpa error
- Rekomendasi: unit test engine, converter, formatting, widget test keypad

---

## 14. Riwayat Git & Branching

- `main` — stabil
- `blackboxai/fix-scroll-symbol-contrast` — redesign utama

Commit penting: `38222b0` (UI redesign), `94ff81e` (3D splash, pro features)

---

## 15. Keterbatasan (Known Issues)

| Issue | Prioritas |
|-------|-----------|
| Riwayat tidak persisten ke disk | Medium |
| Tombol `(`, `)`, `mod` nonaktif | Low |
| Log input ≤ 0 return 0 | Low |
| Persen hanya via menu ⋯ | By design |

---

## 16. Roadmap Pengembangan

**Fase 2:** Persistensi riwayat (Hive), ekspor CSV, widget OS  
**Fase 3:** Mode programmer, parser ekspresi, grafik  
**Fase 4:** i18n, aksesibilitas  
**Fase 5:** Tema premium, backup cloud (opsional)

---

## 17. Diagram Komponen

```
main → Splash → CalculatorScreen
CalculatorScreen → PremiumBackground, PremiumDisplay, Keypad/Scientific
CalculatorScreen → CalculatorEngine, ScientificCalculator, Preferences
PremiumDisplay → NumberFormatting → Preferences
Sheets: History, Converter, Settings, Tools
```

---

## 18. Diagram State Machine Kalkulator

```
Idle → EnteringNumber → OperatorSelected → EnteringOperand2 → ResultShown
ResultShown → OperatorSelected (chain) | Idle (AC)
any → Error (divide zero) → Idle (AC)
any → PreviousState (Undo)
```

---

## 19. Spesifikasi Non-Fungsional

| Metrik | Target |
|--------|--------|
| Cold start | ~3 detik (dengan splash) |
| Response tap | < 50ms perceived |
| Offline | 100% fitur utama |
| FPS animasi | 60 FPS |

---

## 20. Glosarium

| Istilah | Arti |
|---------|------|
| AC | All Clear |
| ⌫ | Backspace |
| M+/M− | Memory add/subtract |
| Live preview | Pratinjau hasil sebelum = |
| Glass display | Panel hasil bergaya kaca |
| CalcSnapshot | State untuk undo |

---

## 21. Kontak & Referensi

- **Path lokal:** `d:\calculator_2026`
- **GitHub:** sholahddn25-prog/calculator_2026
- **Dokumen terkait:** `BLUEPRINT.md`, `BLUEPRINT.docx`, `README.md`

---

*Dokumen ini adalah blueprint resmi proyek Calculator 2026 Pro. Perbarui versi dokumen saat rilis mayor berikutnya.*
