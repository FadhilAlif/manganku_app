# ManganKu App

ManganKu adalah aplikasi Flutter untuk memproses dan menganalisis gambar dengan fitur pengambilan foto, pemilihan dari galeri, dan pemotongan gambar.

## Fitur Utama

### 🏠 Home Page

- **Ambil Foto**: Mengambil foto langsung dari kamera
- **Pilih dari Galeri**: Memilih gambar dari galeri perangkat
- **Manajemen Izin**: Otomatis meminta izin kamera dan galeri
- **Loading States**: Indikator loading yang konsisten
- **Error Handling**: Penanganan error yang baik dengan snackbar

### 📷 Preview Page

- **Preview Gambar**: Menampilkan gambar yang dipilih/diambil
- **Crop Image**: Memotong gambar dengan berbagai aspect ratio:
  - Original (free crop)
  - Square (1:1)
  - 3:2
  - 4:3
  - 16:9
- **Analyze Image**: Tombol placeholder untuk analisis gambar (akan diimplementasi)
- **Retake Photo**: Kembali ke halaman utama untuk mengambil foto baru

## Arsitektur Aplikasi

### 🏗️ Struktur Folder Modular

```
lib/
├── core/
│   ├── services/        # Service layer (ImageService)
│   ├── theme/          # Konfigurasi tema aplikasi
│   ├── utils/          # Utilities (UI Utils, SnackBar Utils)
│   └── widgets/        # Widget yang dapat digunakan kembali
├── features/
│   ├── home/           # Halaman utama
│   └── preview/        # Halaman preview dan crop
└── routes/             # Konfigurasi routing (go_router)
```

### 🧩 Komponen Modular

#### Global Widgets

- **LoadingWidget**: Loading indicator yang konsisten
- **ErrorWidget**: Widget error dengan tombol retry
- **PrimaryButton**: Button utama dengan loading state
- **SecondaryButton**: Button sekunder
- **CustomImageWidget**: Widget gambar dengan error handling

#### Services

- **ImageService**: Service untuk semua operasi gambar
  - `pickImageFromCamera()`: Mengambil foto dari kamera
  - `pickImageFromGallery()`: Memilih dari galeri
  - `cropImage()`: Memotong gambar dengan aspect ratio options
  - `requestPermissions()`: Meminta izin kamera dan galeri

## 🎨 Tema dan Styling

- Material Design 3 dengan color scheme hijau
- Dark dan light theme support
- Consistent button dan card styling
- Custom snackbar dan dialog utilities

## 🚀 Cara Penggunaan

### 1. Mengambil/Memilih Gambar

1. Buka aplikasi dan pilih "Capture Image" atau "Select from Gallery"
2. Aplikasi akan otomatis meminta izin jika diperlukan
3. Gambar akan ditampilkan di halaman Preview

### 2. Memotong Gambar (Crop)

1. Di halaman Preview, tekan tombol "Crop Image"
2. UI cropper akan terbuka dengan opsi:
   - **Free crop**: Drag untuk memotong bebas
   - **Aspect ratio presets**: 1:1, 3:2, 4:3, 16:9
3. Setelah crop, tekan "Done" dan gambar akan diperbarui

### 3. Fitur Lainnya

- **Analyze Image**: Placeholder untuk fitur analisis (coming soon)
- **Retake Photo**: Kembali untuk mengambil foto baru

## 🛠️ Pengembangan

### Dependencies Utama

```yaml
go_router: ^14.8.1 # Routing
image_picker: ^1.2.0 # Pengambilan gambar
image_cropper: ^9.1.0 # Pemotongan gambar
permission_handler: ^12.0.1 # Manajemen izin
provider: ^6.1.5 # State management
```

### Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

### Testing

```bash
flutter test
flutter analyze
```

## 🎯 Perbaikan yang Dilakukan

### ✅ Masalah Force Close pada Crop

- **Root cause**: Context tidak valid dan memory issues
- **Solusi**:
  - Tambahkan `mounted` check sebelum setState
  - Reduce image quality untuk mencegah memory issues
  - Proper error handling dengan try-catch
  - File existence validation

### ✅ Arsitektur Modular

- **Sebelum**: Code terduplikasi di multiple files
- **Sesudah**:
  - Global widgets yang reusable
  - Centralized service untuk image operations
  - Consistent UI utilities dan theme
  - Clean separation of concerns

## 📱 Permissions Setup

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to capture images.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images.</string>
```

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
