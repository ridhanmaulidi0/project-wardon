# ☕ WARDON POS

<p align="center">
  <img src="assets/icon/app_icon.jpg" alt="WARDON POS Icon" width="120" style="border-radius: 24px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<div align="center">
  <img src="https://img.shields.io/static/v1?label=Platform&message=Android%20%7C%20Windows&color=059669&style=for-the-badge&logo=android&logoColor=white&labelColor=0f172a" alt="Platform" />
  <img src="https://img.shields.io/static/v1?label=Framework&message=Flutter%203.x&color=02569B&style=for-the-badge&logo=flutter&logoColor=white&labelColor=0f172a" alt="Framework" />
  <img src="https://img.shields.io/static/v1?label=Application%20ID&message=com.wardon.edonsky&color=6366f1&style=for-the-badge&logo=android&logoColor=white&labelColor=0f172a" alt="Application ID" />
  <img src="https://img.shields.io/static/v1?label=State&message=Riverpod%203&color=7c3aed&style=for-the-badge&logo=dart&logoColor=white&labelColor=0f172a" alt="State" />
  <img src="https://img.shields.io/static/v1?label=Version&message=v2.0.0&color=2563eb&style=for-the-badge&logo=github&logoColor=white&labelColor=0f172a" alt="Version" />
  <a href="LICENSE"><img src="https://img.shields.io/static/v1?label=License&message=GPLv3&color=475569&style=for-the-badge&logo=gnu&logoColor=white&labelColor=0f172a" alt="License" /></a>
</div>

<br/>

**WARDON POS** adalah sistem Point of Sale (POS) & manajemen operasional terintegrasi untuk bisnis F&B (warung kopi, kafe, dan eatery) - cepat, responsif, dan mudah digunakan di Android dan Windows Desktop.

---

## 📑 Daftar Isi

- [Gambaran Umum](#-gambaran-umum)
- [Fitur Utama](#-fitur-utama)
- [Hak Akses Pengguna](#-hak-akses-pengguna)
- [Arsitektur & Struktur Proyek](#-arsitektur--struktur-proyek)
- [Teknologi & Dependensi](#-teknologi--dependensi)
- [Panduan Instalasi](#-panduan-instalasi)
- [Catatan Rilis (Changelog)](#-catatan-rilis-changelog)
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
- Platform target: **Android** atau **Windows Desktop**

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

## 🚀 Catatan Rilis (Changelog)

### v2.0.0
- **Penggantian Application ID**: Diperbarui menjadi `com.wardon.edonsky` (sebelumnya `com.wardon.wardon_pos`).
- **Icon Aplikasi Baru**: Integrasi icon launcher Android HD (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) dan master asset `assets/icon/app_icon.jpg` bersumber dari repositori `phantek-video-toolkit`.
- **Optimalisasi Khusus Android & Windows**: Menghapus seluruh dependensi dan berkas platform non-target (iOS, Web, macOS, Linux) secara menyeluruh untuk efisiensi serta performa maksimal di Android dan Windows Desktop.
- **Pembersihan & Standardisasi Kode**: Kode 100% lolos pengujian dan verifikasi `flutter analyze` (0 issues), mengikuti aturan `flutter_lints` dan kaidah format resmi Dart.
- **Pembaruan Tampilan Dokumentasi**: Header baru dengan master icon melengkung berbayang dan badge bergaya `for-the-badge`.

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **GNU General Public License v3.0 (GPLv3)**. Lihat berkas [`LICENSE`](LICENSE) untuk informasi lisensi selengkapnya.
