<div align="center">

# ☕ WARDON POS

**Sistem Point of Sale & Manajemen Operasional Terintegrasi untuk Bisnis F&B**

Solusi kasir modern untuk warung kopi, kafe, dan eatery - cepat, responsif, dan mudah digunakan di semua perangkat.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.9.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%203-00B8D4)](https://riverpod.dev)
[![Material 3](https://img.shields.io/badge/UI-Material%203-6750A4?logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Web-success)](#-panduan-instalasi)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-lightgrey)](#-lisensi)

</div>

---

## 📑 Daftar Isi

- [Gambaran Umum](#-gambaran-umum)
- [Fitur Utama](#-fitur-utama)
- [Hak Akses Pengguna](#-hak-akses-pengguna)
- [Arsitektur & Struktur Proyek](#-arsitektur--struktur-proyek)
- [Teknologi & Dependensi](#-teknologi--dependensi)
- [Panduan Instalasi](#-panduan-instalasi)
- [Lisensi](#-lisensi)

---

## 🎯 Gambaran Umum

**WARDON POS** adalah aplikasi Point of Sale (POS) dan manajemen operasional untuk bisnis makanan dan minuman (F&B). Dibangun dengan **Flutter** dan **Riverpod**, aplikasi ini dirancang untuk memberikan kinerja tinggi, responsivitas lintas platform, serta kemudahan operasional kasir harian.

Sistem ini menggabungkan:

| | Kapabilitas |
|---|---|
| 🧾 | Pemrosesan transaksi yang cepat |
| 📦 | Pelacakan inventaris stok menu |
| 📊 | Visualisasi metrik performa penjualan |
| 🏪 | Kustomisasi profil toko dan struk belanja |
| 📑 | Pembuatan laporan pembukuan otomatis dalam format Microsoft Excel |

---

## ✨ Fitur Utama

### 🛒 1. Transaksi Kasir (Point of Sale)

- Antarmuka penjualan responsif, dioptimalkan untuk **mobile, tablet, dan desktop**.
- Katalog menu berbasis kategori (*Kopi, Non-Kopi, Makanan, Camilan*) dengan **pencarian instan**.
- Keranjang belanja dinamis dengan **catatan khusus per item** pesanan.
- Dukungan beberapa metode pembayaran:

  | Metode | Keterangan |
  |---|---|
  | 💵 Tunai | Kalkulasi otomatis uang diterima dan kembalian |
  | 📱 QRIS | Pembayaran melalui kode QR |
  | 🏦 Digital / Transfer | Pembayaran non-tunai lainnya |

- Penghitungan **diskon** dan **Pajak Pertambahan Nilai (PPN)** terintegrasi.
- Pembuatan dan pratinjau **struk digital** dengan format teks rapi, siap cetak.

### 📊 2. Dashboard Analitik & Metrik Bisnis

Ringkasan indikator kinerja utama (KPI) harian:

| KPI | Deskripsi |
|---|---|
| **Total Omzet** | Pendapatan harian |
| **Jumlah Transaksi** | Transaksi yang berhasil diproses |
| **Average Ticket Size** | Nilai rata-rata per transaksi |
| **Item Terjual** | Kuantitas item menu yang terjual |

Visualisasi grafik interaktif menggunakan `fl_chart`:

- Grafik batang tren pendapatan mingguan
- Distribusi metode pembayaran

### 🕘 3. Riwayat & Audit Transaksi

- Pencatatan seluruh transaksi secara kronologis.
- Pencarian dan filter berdasarkan **nomor pesanan**, **nama kasir**, atau **nama pelanggan**.
- Peninjauan detail pesanan dan **cetak ulang struk**.

### 🍽️ 4. Manajemen Menu & Inventaris *(Admin)*

- Operasi **CRUD** (tambah, ubah, hapus) item menu beserta penetapan harga jual.
- Pengelompokan kategori produk.
- Pemantauan dan penyesuaian ketersediaan stok secara berkala.

### 📑 5. Laporan Penjualan & Ekspor Excel *(Admin)*

- Filter rentang waktu: **Hari Ini · Minggu Ini · Bulan Ini · Tahun Ini · Semua Periode**.
- Ekspor ke format **`.xlsx`** menggunakan mesin Syncfusion XlsIO, dengan dua lembar kerja:

  | Lembar | Isi |
  |---|---|
  | **Ringkasan Eksekutif** | Metrik agregat dan tanggal ekspor |
  | **Daftar Transaksi** | Nomor pesanan, waktu, kasir, metode pembayaran, subtotal, diskon, dan total penerimaan |

- Berbagi berkas laporan langsung dari perangkat.

### ⚙️ 6. Pengaturan Toko & Personalisasi

- Konfigurasi profil usaha: **nama toko, slogan, alamat, nomor kontak**, dan **catatan kaki struk**.
- Pengaturan tarif pajak operasional serta opsi aktif/nonaktif kalkulasi pajak.
- Tema visual adaptif: **Light Mode** dan **Dark Mode**.

---

## 🔐 Hak Akses Pengguna

Sistem menerapkan **Role-Based Access Control (RBAC)** dengan dua tingkatan peran:

| Modul | 👑 Administrator (Owner) | 🧑‍💼 Kasir |
|---|:---:|:---:|
| Transaksi Kasir | ✅ | ✅ |
| Dashboard | ✅ | ✅ |
| Riwayat Transaksi | ✅ | ✅ |
| Manajemen Menu & Stok | ✅ | ❌ |
| Laporan & Ekspor Excel | ✅ | ❌ |
| Pengaturan Toko | ✅ | ❌ |

> **Catatan:** Akses kasir ke menu stok dan laporan eksekutif dibatasi demi keamanan operasional.

---

## 🏗️ Arsitektur & Struktur Proyek

Aplikasi menggunakan pendekatan modular **feature-first** untuk menjaga skalabilitas dan keterbacaan kode.

```text
lib/
├── core/
│   ├── constants/        # Data awal dan konstanta sistem
│   ├── theme/            # Tema Material 3 dan palet warna
│   └── utils/            # Format mata uang (Rupiah), tanggal, dan waktu
├── features/
│   ├── auth/             # Autentikasi dan login pengguna
│   ├── dashboard/        # Dashboard performa dan grafik analitik
│   ├── menu/             # Pengelolaan katalog produk dan stok inventaris
│   ├── orders/           # Riwayat transaksi penjualan
│   ├── pos/              # Antarmuka kasir dan keranjang transaksi
│   ├── reports/          # Rekapitulasi laporan dan ekspor Excel
│   ├── settings/         # Konfigurasi profil usaha dan preferensi aplikasi
│   └── main_layout.dart  # Navigasi adaptif (Sidebar Desktop / Bottom Nav Mobile)
├── models/               # Model data (User, Menu, Order, StoreSettings)
├── providers/            # State management berbasis Riverpod
├── services/             # Persistensi lokal, format struk, dan ekspor berkas
└── main.dart             # Entry point aplikasi
```

---

## 🧰 Teknologi & Dependensi

| Kategori | Teknologi | Versi |
|---|---|---|
| Bahasa | Dart | `^3.9.2` |
| Framework | Flutter (Material Design 3) | `3.x` |
| State Management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | `^3.3.2` |
| Navigasi | [go_router](https://pub.dev/packages/go_router) | `^17.2.3` |
| Penyimpanan Lokal | [shared_preferences](https://pub.dev/packages/shared_preferences) | `^2.5.5` |
| Dokumen Excel | [syncfusion_flutter_xlsio](https://pub.dev/packages/syncfusion_flutter_xlsio) | `^33.2.13` |
| Grafik | [fl_chart](https://pub.dev/packages/fl_chart) | `^1.2.0` |
| Tipografi | [google_fonts](https://pub.dev/packages/google_fonts) | `^8.1.0` |
| Lokalisasi & Format | [intl](https://pub.dev/packages/intl) | `^0.20.3` |
| Berkas & Berbagi | [path_provider](https://pub.dev/packages/path_provider) · [share_plus](https://pub.dev/packages/share_plus) | `^2.1.5` · `^12.0.2` |

---

## 🚀 Panduan Instalasi

### Prasyarat

- **Flutter SDK** versi 3.x atau lebih baru
- Editor kode: VS Code, Android Studio, atau setara
- Salah satu platform target: **Windows, Android, Web, macOS, atau Linux**

### Menjalankan Aplikasi

**1. Masuk ke direktori proyek**

```bash
cd project-wardon
```

**2. Unduh dependensi**

```bash
flutter pub get
```

**3. Jalankan aplikasi** pada perangkat atau simulator yang aktif

```bash
flutter run
```

### Membuat Paket Rilis

```bash
# Windows Desktop
flutter build windows

# Android APK
flutter build apk --release
```

---

## 📄 Lisensi

© **WARDON POS**. Seluruh hak cipta dilindungi undang-undang.

Proyek ini dikembangkan untuk kebutuhan operasional manajemen kasir WARDON.
