# Panduan Lengkap Proyek: Lost & Found TelU (LaporIn)

## 1. Deskripsi Proyek
**Lost & Found TelU** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk komunitas Telkom University. Aplikasi ini berfungsi sebagai platform digital untuk melaporkan barang yang hilang atau ditemukan di lingkungan kampus, memudahkan proses pengembalian barang kepada pemilik aslinya.

## 2. Fitur Utama
*   **Laporan Barang Hilang**: Pengguna dapat mengunggah detail barang yang hilang beserta foto, lokasi terakhir, dan deskripsi.
*   **Laporan Barang Temuan**: Pengguna yang menemukan barang dapat melaporkannya agar pemilik dapat segera mengenalinya.
*   **Integrasi WhatsApp (Hubungi Pelapor)**: Memungkinkan komunikasi langsung antara penemu dan pemilik barang melalui tombol "Hubungi" yang terhubung ke WhatsApp.
*   **Sistem Notifikasi**: Memberikan pembaruan real-time terkait status laporan atau komentar baru.
*   **Papan Laporan (Feed)**: Menampilkan daftar semua barang yang dilaporkan dengan kategori yang jelas (Hilang/Temu).
*   **Status Selesai**: Laporan dapat ditandai sebagai "Selesai" jika barang sudah berhasil dikembalikan.
*   **Manajemen Profil & Riwayat**: Pengguna dapat melihat daftar laporan yang pernah mereka buat.
*   **Panel Admin**: Fitur khusus untuk moderator dalam memvalidasi atau menghapus laporan yang tidak sesuai.

## 3. Teknologi yang Digunakan
*   **Frontend**: [Flutter](https://flutter.dev/) (Dart) - Untuk pengembangan aplikasi lintas platform (Android & iOS).
*   **Backend & Database**: [Firebase Firestore](https://firebase.google.com/docs/firestore) - Untuk penyimpanan data laporan dan pengguna secara real-time.
*   **Penyimpanan Gambar**: [Cloudinary](https://cloudinary.com/) - Untuk manajemen unggahan foto barang yang efisien.
*   **Autentikasi**: [Firebase Auth](https://firebase.google.com/docs/auth) - Untuk sistem login dan pendaftaran pengguna.
*   **Integrasi Pihak Ketiga**: `url_launcher` untuk fitur WhatsApp.

## 4. Cara Instalasi & Menjalankan Proyek

### Prasyarat
1.  **Flutter SDK**: Pastikan Flutter sudah terinstal di komputer Anda.
2.  **Editor**: VS Code atau Android Studio dengan ekstensi Dart & Flutter.
3.  **Akun Firebase**: Proyek memerlukan file `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS).

### Langkah-langkah
1.  **Clone Repositori**:
    ```bash
    git clone https://github.com/hsenastanaufal/Lost-n-Found.git
    ```
2.  **Masuk ke Direktori Proyek**:
    ```bash
    cd lostnfound
    ```
3.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```
4.  **Konfigurasi Firebase**: Masukkan file konfigurasi Firebase yang valid ke dalam folder `android/app/` dan `ios/Runner/`.
5.  **Jalankan Aplikasi**:
    ```bash
    flutter run
    ```

## 5. Penjelasan Teknis Fitur WhatsApp

Fitur "Hubungi" memungkinkan aplikasi untuk membuka WhatsApp secara otomatis dengan pesan yang sudah terisi. Berikut adalah detail cara kerjanya:

### A. Teknologi yang Digunakan
*   **Package**: `url_launcher` - Plugin Flutter untuk membuka URL di browser atau aplikasi eksternal.
*   **API WhatsApp**: Menggunakan skema URL Universal (`https://wa.me/`) dan skema kustom (`whatsapp://`).

### B. Alur Kerja (Workflow)
1.  **Format Nomor**: Aplikasi mendeteksi nomor telepon pelapor. Jika dimulai dengan `0`, aplikasi secara otomatis mengubahnya ke kode negara Indonesia `62` (misal: `0812...` menjadi `62812...`).
2.  **Konstruksi Pesan**: Pesan teks dibuat secara dinamis menggunakan `Uri.encodeComponent` agar karakter khusus (seperti spasi dan simbol) dapat terbaca oleh WhatsApp.
3.  **Peluncuran Aplikasi**: 
    *   Aplikasi pertama-tama mencoba membuka link `https://wa.me/`.
    *   Jika gagal (misal: di beberapa perangkat Android 11+), aplikasi akan menggunakan fallback ke skema `whatsapp://send?phone=...`.

### C. Konfigurasi Keamanan (PENTING)
Agar aplikasi diizinkan membuka WhatsApp, konfigurasi berikut telah diterapkan:
*   **Android (`AndroidManifest.xml`)**: Menambahkan bagian `<queries>` untuk mendeklarasikan bahwa aplikasi akan mengakses skema `https` dan `whatsapp`. Tanpa ini, sistem Android akan memblokir perintah buka aplikasi demi keamanan.
*   **iOS (`Info.plist`)**: Menambahkan kunci `LSApplicationQueriesSchemes` dengan daftar `whatsapp` dan `https` agar sistem iOS mengenali izin peluncuran aplikasi tersebut.

## 6. Catatan Penting untuk Pengembangan
*   **Responsivitas**: Desain menggunakan teknik responsivitas (seperti `Expanded` dan `TextOverflow`) untuk memastikan tampilan tetap rapi di berbagai ukuran layar HP.
*   **Mode Eksternal**: Saat memanggil `launchUrl`, digunakan `LaunchMode.externalApplication` agar link dibuka langsung di aplikasi WhatsApp, bukan di dalam webview internal aplikasi.

---
**Lost & Found TelU** - *Membantu Mengembalikan Barang Anda dengan Lebih Cepat.*

