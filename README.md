# Lost & Found TelU (LaporIn) 📱📍

**Lost & Found TelU** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk komunitas akademika Telkom University. Aplikasi ini berfungsi sebagai platform digital untuk melaporkan barang yang hilang (*Lost*) atau ditemukan (*Found*) di lingkungan kampus, guna mempermudah proses pengembalian barang kepada pemiliknya.

---

## 🚀 Fitur Utama

*   **Papan Laporan (Feed)**: Menampilkan daftar barang hilang dan temuan terbaru secara real-time.
*   **Lapor Kehilangan / Temuan**: Formulir untuk mengunggah detail barang disertai foto, deskripsi, dan lokasi.
*   **Peta Interaktif (OpenStreetMap)**: Integrasi peta ringan berbasis OSM untuk menentukan koordinat presisi titik penemuan atau kehilangan barang.
*   **Pencarian Lokasi Otomatis (Geocoding)**: Otomatis mendeteksi alamat/gedung berdasarkan titik koordinat yang dipilih di peta.
*   **Integrasi WhatsApp**: Hubungi pemilik/penemu barang langsung via WhatsApp dengan pesan otomatis terformat.
*   **Manajemen Riwayat & Status**: Pengguna dapat melihat daftar laporan mereka sendiri dan menandai laporan sebagai "Selesai" jika barang telah dikembalikan.
*   **Panel Moderator Admin**: Halaman manajemen khusus bagi admin untuk meninjau, menyetujui, atau menghapus laporan.

---

## 🛠️ Teknologi & Packages

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Database & Auth**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore) & [Firebase Authentication](https://firebase.google.com/docs/auth)
*   **Penyimpanan Gambar**: [Cloudinary](https://cloudinary.com/) (menggunakan API Cloudinary Service)
*   **Peta & Lokasi**:
    *   `flutter_map`: Render widget peta OpenStreetMap.
    *   `latlong2`: Utilitas matematika geografi koordinat.
    *   `geolocator`: Mengambil titik GPS terkini perangkat secara real-time.
    *   `geocoding`: Reverse geocode dari koordinat ke alamat tekstual.
*   **Utilitas Lain**: `url_launcher` untuk membuka tautan WhatsApp & Peta Navigasi Eksternal.

---

## ⚙️ Langkah Instalasi & Konfigurasi

### Prasyarat
1.  **Flutter SDK** (Dart versi 3.11 atau lebih baru).
2.  File kredensial Firebase:
    *   Android: `google-services.json` diletakkan di `android/app/`
    *   iOS: `GoogleService-Info.plist` diletakkan di `ios/Runner/`

### Cara Menjalankan Proyek

1.  **Clone Repositori**:
    ```bash
    git clone https://github.com/hsenastanaufal/Lost-n-Found.git
    cd lostnfound
    ```

2.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```

3.  **Jalankan Kompilasi Ulang Aplikasi**:
    *   *Penting:* Jika Anda baru pertama kali menjalankan aplikasi setelah dependensi peta ditambahkan, bersihkan cache terlebih dahulu agar modul native terkompilasi sempurna.
    ```bash
    flutter clean
    flutter pub get
    flutter run
    ```

---

## 🔒 Konfigurasi Izin Keamanan (*Permissions*)

Aplikasi memerlukan akses lokasi agar fitur peta dapat mendeteksi koordinat Anda secara tepat. Pengaturan native berikut telah diterapkan di proyek ini:

### Android (`AndroidManifest.xml`)
Izin berikut ditambahkan di dalam berkas manifest utama:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`Info.plist`)
Deskripsi berikut ditambahkan untuk memberi tahu pengguna alasan aplikasi meminta akses lokasi:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi ini memerlukan akses lokasi untuk menentukan di mana barang hilang atau ditemukan.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikasi ini memerlukan akses lokasi untuk menentukan di mana barang hilang atau ditemukan.</string>
```

---

## 📂 Struktur Folder Utama
```
lostnfound/
├── android/               # Konfigurasi platform Android
├── ios/                   # Konfigurasi platform iOS
├── assets/                # Gambar logo & ikon aplikasi
└── lib/
    ├── data/              # Konfigurasi data lokal/mock
    ├── models/            # Model data aplikasi (e.g. LostItem)
    ├── pages/
    │   ├── admin/         # Halaman moderator admin
    │   ├── auth/          # Halaman masuk & pendaftaran akun
    │   ├── main/          # Halaman beranda utama
    │   └── reports/       # Halaman buat laporan, detail laporan, & pemilih lokasi (map)
    ├── services/          # Logika integrasi Firestore & Cloudinary
    └── main.dart          # Titik masuk utama (Entry point) aplikasi
```
