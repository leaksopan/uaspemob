# Aplikasi Catatan Pengeluaran 📱💰

Aplikasi mobile untuk mencatat dan mengelola pengeluaran harian menggunakan Flutter.

## ✨ Fitur Utama

### 🔐 Autentikasi

- Login dan registrasi user
- Session management

### 💸 Manajemen Pengeluaran

- Tambah pengeluaran baru
- Edit dan hapus pengeluaran
- Kategorisasi pengeluaran
- **📷 FOTO STRUK BELANJA** - Fitur baru!

### 📊 Laporan

- Total pengeluaran
- Pengeluaran per kategori
- Riwayat transaksi

## 🆕 Fitur Kamera untuk Foto Struk

Aplikasi sekarang mendukung pengambilan foto struk belanja untuk setiap pengeluaran:

### Cara Menggunakan:

1. **Buka halaman "Tambah Pengeluaran"**
2. **Scroll ke bagian "Foto Struk (Opsional)"**
3. **Tap tombol "Tambah Foto Struk"**
4. **Pilih salah satu opsi:**
   - 📷 **Ambil Foto** - Langsung menggunakan kamera
   - 🖼️ **Dari Galeri** - Pilih foto yang sudah ada

### Fitur Foto:

- ✅ Akses kamera real-time
- ✅ Permission handling otomatis
- ✅ Preview foto sebelum menyimpan
- ✅ Kompres gambar otomatis (800x800px, quality 85%)
- ✅ Penyimpanan lokal yang aman
- ✅ Hapus foto dengan mudah
- ✅ Support Web dan Mobile
- ✅ Error handling yang baik

### Keamanan & Performance:

- 🔒 Request permission kamera secara aman
- 📱 Otomatis fallback ke galeri di Web
- 💾 Optimasi ukuran file gambar
- 🗂️ Penyimpanan terorganisir di folder khusus

## 🛠️ Teknologi

- **Flutter** - Framework UI cross-platform
- **SQLite** - Database lokal
- **Provider** - State management
- **Image Picker** - Akses kamera dan galeri
- **Permission Handler** - Manajemen izin
- **Path Provider** - Penyimpanan file

## 📋 Requirements

- Flutter SDK >= 3.7.2
- Dart >= 3.0.0
- Android SDK (untuk Android)
- Xcode (untuk iOS)

## 🚀 Instalasi

1. **Clone repository:**

   ```bash
   git clone [repository-url]
   cd catatanpengeluaran
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ **Android** - Full support dengan kamera dan galeri
- ✅ **iOS** - Full support dengan kamera dan galeri
- ✅ **Web** - Support galeri/file picker
- ✅ **Windows/Linux/macOS** - Support file picker

## 🔧 Konfigurasi Permission

### Android

Permission sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS

Tambahkan ke `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk mengambil foto struk belanja</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk memilih foto struk</string>
```

## 📷 Tips Penggunaan Foto Struk

1. **Pastikan pencahayaan cukup** saat mengambil foto
2. **Posisikan struk rata** untuk hasil terbaik
3. **Gunakan mode landscape** untuk struk yang panjang
4. **Foto akan otomatis dikompres** untuk menghemat storage
5. **Hapus foto lama** yang tidak diperlukan untuk menghemat ruang

## 🏗️ Struktur Project

```
lib/
├── models/          # Data models
├── views/           # UI screens
├── viewmodels/      # Business logic
├── repositories/    # Data layer
├── services/        # External services (image, database)
└── utils/          # Helper functions
```

## 🤝 Contributing

1. Fork repository
2. Buat feature branch
3. Commit changes
4. Push ke branch
5. Buat Pull Request

## 📄 License

This project is licensed under the MIT License.

---

**Dibuat dengan ❤️ menggunakan Flutter**
