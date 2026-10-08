# WARDON POS - Point of Sale System

Sistem Point of Sale (POS) dan manajemen operasional terintegrasi untuk bisnis makanan dan minuman (F&B), warung kopi, dan eatery. Dibangun menggunakan kerangka kerja Flutter dan arsitektur State Management berbasis Riverpod, aplikasi ini dirancang untuk memberikan kinerja tinggi, responsivitas lintas platform, dan kemudahan operasional kasir harian.

---

## Daftar Isi

1. [Gambaran Umum](#gambaran-umum)
2. [Fitur Utama](#fitur-utama)
3. [Arsitektur dan Struktur Proyek](#arsitektur-dan-struktur-proyek)
4. [Teknologi dan Dependensi](#teknologi-dan-dependensi)
5. [Hak Akses Pengguna](#hak-akses-pengguna)
6. [Panduan Instalasi dan Menjalankan Aplikasi](#panduan-instalasi-dan-menjalankan-aplikasi)
7. [Lisensi dan Kontribusi](#lisensi-dan-kontribusi)

---

## Gambaran Umum

WARDON POS menghadirkan solusi digital menyeluruh bagi pemilik usaha dan staf kasir. Sistem ini mengintegrasikan pemrosesan transaksi cepat, pelacakan inventaris stok menu, visualisasi metrik performa penjualan, kustomisasi profil toko dan struk belanja, serta pembuatan laporan pembukuan otomatis dalam format spreadsheet (Microsoft Excel).

---

## Fitur Utama

### 1. Transaksi Kasir (Point of Sale)
- Antarmuka penjualan responsif yang dioptimalkan untuk perangkat mobile, tablet, maupun desktop.
- Katalog menu berbasis kategori (Kopi, Non-Kopi, Makanan, Camilan) disertai pencarian instan.
- Panel keranjang belanja dinamis dengan dukungan penambahan catatan khusus per item pesanan.
- Dukungan berbagai metode pembayaran:
  - Tunai (disertai kalkulasi otomatis uang yang diterima dan nilai kembalian).
  - QRIS.
  - Pembayaran Digital / Transfer.
- Integrasi penghitungan diskon dan pajak pertambahan nilai (PPN).
- Pembuatan dan pratinjau struk digital dengan format teks rapi yang siap dicetak.

### 2. Dashboard Analitik dan Metrik Bisnis
- Ringkasan indikator kinerja utama (KPI) harian:
  - Total omzet / pendapatan harian.
  - Jumlah transaksi yang berhasil diproses.
  - Nilai rata-rata per transaksi (Average Ticket Size).
  - Kuantitas item menu yang terjual.
- Visualisasi grafik interaktif menggunakan fl_chart:
  - Grafik batang tren pendapatan mingguan.
  - Distribusi metode pembayaran.

### 3. Riwayat dan Audit Transaksi
- Pencatatan seluruh transaksi secara kronologis.
- Pencarian dan filter transaksi berdasarkan nomor pesanan, nama kasir, atau nama pelanggan.
- Kemampuan untuk meninjau detail rincian pesanan dan mencetak ulang struk transaksi.

### 4. Manajemen Menu dan Inventaris (Admin)
- Operasi CRUD (Tambah, Ubah, Hapus) untuk item menu dan penetapan harga jual.
- Pengelompokan kategori produk.
- Pemantauan dan penyesuaian ketersediaan stok produk secara berkala.

### 5. Laporan Penjualan dan Ekspor Excel (Admin)
- Filter rentang waktu laporan: Hari Ini, Minggu Ini, Bulan Ini, Tahun Ini, dan Semua Periode.
- Ekspor data transaksi ke dalam format spreadsheet (.xlsx) melalui mesin Syncfusion XlsIO:
  - Lembar Ringkasan Eksekutif: Metrik agregat dan tanggal ekspor.
  - Lembar Daftar Transaksi: Rincian komprehensif nomor pesanan, waktu, kasir, metode pembayaran, subtotal, diskon, dan total penerimaan.
- Kemudahan pembagian berkas laporan langsung dari perangkat.

### 6. Pengaturan Toko dan Personalisasi Sistem
- Konfigurasi profil identitas usaha: nama toko, slogan, alamat, nomor kontak, dan catatan kaki pada struk belanja.
- Pengaturan tarif pajak operasional dan opsi pengaktifan kalkulasi pajak.
- Dukungan tema visual adaptif: Mode Terang (Light Mode) dan Mode Gelap (Dark Mode).

---

## Arsitektur dan Struktur Proyek

Aplikasi dirancang dengan pendekatan modular berbasis fitur (feature-first approach) untuk menjaga skalabilitas dan keterbacaan kode:

```text
lib/
├── core/
│   ├── constants/       # Data awal dan konstanta sistem
│   ├── theme/           # Definisi tema Material 3 dan palet warna
│   └── utils/           # Format mata uang (Rupiah), tanggal, dan waktu
├── features/
│   ├── auth/            # Halaman autentikasi dan login pengguna
│   ├── dashboard/       # Tampilan dashboard performa dan grafik analitik
│   ├── menu/            # Pengelolaan katalog produk dan stok inventaris
│   ├── orders/          # Riwayat transaksi penjualan
│   ├── pos/             # Antarmuka utama kasir dan keranjang transaksi
│   ├── reports/         # Rekapitulasi laporan operasional dan ekspor Excel
│   ├── settings/        # Konfigurasi profil usaha dan preferensi aplikasi
│   └── main_layout.dart # Tata letak navigasi adaptif (Sidebar Desktop / Navigasi Bawah Mobile)
├── models/              # Definisi model data (User, Menu, Order, StoreSettings)
├── providers/           # State management berbasis Riverpod
├── services/            # Layanan persistensi lokal, format struk, dan ekspor berkas
└── main.dart            # Titik masuk utama aplikasi (Entry Point)
```

---

## Teknologi dan Dependensi

- Bahasa Pemrograman: Dart (SDK versi ^3.9.2)
- Framework: Flutter (Material Design 3)
- State Management: Flutter Riverpod (^3.3.2)
- Navigasi: GoRouter (^17.2.3)
- Penyimpanan Data Lokal: shared_preferences (^2.5.5)
- Pengolahan Dokumen Excel: syncfusion_flutter_xlsio (^33.2.13)
- Visualisasi Grafik: fl_chart (^1.2.0)
- Tipografi: Google Fonts (^8.1.0)
- Lokalisasi dan Format: intl (^0.20.3)
- Utilitas Berkas dan Pembagian: path_provider (^2.1.5) dan share_plus (^12.0.2)

---

## Hak Akses Pengguna

Sistem menerapkan Role-Based Access Control (RBAC) dengan dua tingkatan peran:

1. Administrator (Owner)
   - Akses penuh ke seluruh modul sistem: Kasir, Dashboard, Riwayat Transaksi, Manajemen Menu & Stok, Laporan & Ekspor Excel, serta Pengaturan Toko.
2. Kasir
   - Akses operasional harian: Modul Transaksi Kasir, Dashboard Ringkasan, dan Riwayat Transaksi. Akses ke menu stok dan laporan eksekutif dibatasi demi keamanan operasional.

Akun pengujian bawaan yang tersedia pada sistem:
- Administrator: admin@wardon.com
- Kasir: kasir@wardon.com

---

## Panduan Instalasi dan Menjalankan Aplikasi

### Prasyarat
- Flutter SDK versi 3.x ke atas telah terpasang di sistem.
- Perangkat lunak editor kode (VS Code, Android Studio, atau setara).
- Perangkat target yang didukung: Windows Desktop, macOS, Linux, Web, Android, atau iOS.

### Langkah-langkah

1. Buka terminal pada direktori proyek:
   ```bash
   cd project-wardon
   ```

2. Unduh seluruh dependensi yang diperlukan:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi pada perangkat atau simulator yang aktif:
   ```bash
   flutter run
   ```

4. Untuk membuat paket rilis (misalnya untuk sistem operasi Windows atau Android):
   ```bash
   # Windows Desktop
   flutter build windows

   # Android APK
   flutter build apk --release
   ```

---

## Lisensi dan Hak Cipta

Hak Cipta (c) WARDON POS. Seluruh hak cipta dilindungi undang-undang.
Proyek ini dikembangkan untuk kebutuhan operasional manajemen kasir WARDON.