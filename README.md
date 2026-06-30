# 🌸 Cycle App

Cycle App adalah aplikasi mobile berbasis Flutter yang membantu pengguna mencatat, memantau, dan memprediksi siklus menstruasi secara praktis. Aplikasi ini memungkinkan pengguna menyimpan riwayat menstruasi, mengetahui prediksi haid berikutnya, masa ovulasi, masa subur, serta mencatat kondisi mood harian yang dilengkapi dengan tips kesehatan.

Selain menggunakan database lokal (SQLite), aplikasi juga dapat melakukan sinkronisasi data dengan server menggunakan PHP dan MySQL sehingga data pengguna tetap tersimpan dengan aman.

---

## ✨ Fitur Utama

### 🔐 Autentikasi
- Login akun
- Registrasi akun
- Logout

### 🩸 Pencatatan Siklus Menstruasi
- Menambahkan data menstruasi
- Melihat riwayat siklus
- Mengubah data siklus
- Menghapus data siklus

### 📅 Prediksi Siklus
- Prediksi tanggal haid berikutnya
- Prediksi masa ovulasi
- Prediksi masa subur
- Perhitungan otomatis berdasarkan panjang siklus dan durasi haid

### 😊 Mood Tracker
- Mencatat mood harian
- Menampilkan tips kesehatan sesuai mood yang dipilih

### 💾 Penyimpanan Data
- SQLite sebagai database lokal (offline)
- MySQL + PHP API sebagai database server
- Sinkronisasi data otomatis

---

## 🛠️ Teknologi yang Digunakan

- Flutter
- Dart
- SQLite (sqflite)
- PHP
- MySQL
- XAMPP
- HTTP REST API

---

## 📂 Struktur Project

```
lib/
│
├── pages/
│   ├── login.dart
│   ├── register.dart
│   ├── mainPage.dart
│   ├── main.dart
│   └── prediksi_page.dart
│
├── services/
│   ├── menstruasi_service.dart
│   ├── mood_service.dart
│
├── database/
│   └── db_helper.dart
│
├── models/
│
├── widgets/
│
└── main.dart
```

---

## 📊 Fitur CRUD

Aplikasi mendukung operasi CRUD pada data siklus menstruasi.

| Operasi | Keterangan |
|---------|------------|
| Create | Menambahkan data siklus menstruasi |
| Read | Menampilkan seluruh riwayat siklus |
| Update | Mengubah data yang telah disimpan |
| Delete | Menghapus data siklus |

---

## 📈 Perhitungan Prediksi

Cycle App secara otomatis menghitung:

- Tanggal selesai menstruasi
- Prediksi haid berikutnya
- Prediksi ovulasi
- Masa subur

Perhitungan dilakukan berdasarkan:

- Tanggal mulai haid terakhir
- Rata-rata panjang siklus
- Lama durasi menstruasi

---

## 😊 Mood Tracker

Pengguna dapat memilih mood seperti:

- 😊 Senang
- 😢 Sedih
- 😠 Marah
- 😰 Cemas
- 😌 Tenang
- 😩 Lelah
- 🤩 Semangat
- 😤 Kesal

Setelah memilih mood, aplikasi akan memberikan tips kesehatan yang sesuai.

---

## 💾 Database

### SQLite
Digunakan sebagai penyimpanan lokal sehingga aplikasi tetap dapat digunakan tanpa koneksi internet.

### MySQL
Digunakan sebagai penyimpanan server melalui REST API berbasis PHP.

---

## 🚀 Cara Menjalankan Project

### Clone Repository

```bash
git clone https://github.com/username/cycle_app.git
```

### Masuk Folder Project

```bash
cd cycle_app
```

### Install Dependency

```bash
flutter pub get
```

### Jalankan Aplikasi

```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  http:
  sqflite:
  path:
  intl:
  shared_preferences:
```

---

## 🎯 Tujuan Aplikasi

Cycle App dikembangkan untuk membantu pengguna dalam:

- Mencatat riwayat menstruasi
- Memantau kesehatan reproduksi
- Mengetahui perkiraan siklus berikutnya
- Mengetahui masa subur dan ovulasi
- Mencatat kondisi emosional selama siklus menstruasi
- Memberikan tips kesehatan berdasarkan mood pengguna

---

## 👩‍💻 Developer

**Salwa Adelia Winasti**

Universitas Pamulang Kampus Serang  
Program Studi Sistem Informasi

---

## 📄 License

Project ini dibuat untuk keperluan pembelajaran dan tugas mata kuliah **Mobile Programming**.
