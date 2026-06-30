# 🚴 Cycle App

Cycle App adalah aplikasi mobile berbasis Flutter yang membantu pengguna mengelola aktivitas kesehatan sehari-hari melalui pengingat (reminder) dan pelacakan aktivitas (tracker). Aplikasi ini dirancang dengan tampilan sederhana, mudah digunakan, serta mendukung penyimpanan data secara lokal menggunakan SQLite.

---

## ✨ Fitur Utama

- 📅 Menambahkan jadwal aktivitas kesehatan
- ⏰ Pengingat aktivitas harian
- 💊 Pengingat minum obat
- 💧 Pengingat minum air
- 🏃 Pengingat olahraga
- 😴 Pengingat waktu tidur
- 📋 Melihat daftar seluruh reminder
- ✏️ Mengubah data reminder
- 🗑️ Menghapus reminder
- 💾 Penyimpanan data lokal menggunakan SQLite
- 📱 Antarmuka sederhana dan responsif

---

## 📸 Tampilan Aplikasi

> Tambahkan screenshot aplikasi pada folder `screenshots/`

| Home | Tambah Reminder | Detail |
|------|-----------------|--------|
| ![](screenshots/home.png) | ![](screenshots/add.png) | ![](screenshots/detail.png) |

---

## 🛠️ Teknologi yang Digunakan

- Flutter
- Dart
- SQLite
- sqflite
- path_provider
- intl
- flutter_local_notifications *(opsional jika digunakan)*

---

## 📂 Struktur Project

```
lib/
│
├── db/
│   ├── db_helper.dart
│   └── reminder_model.dart
│
├── pages/
│   ├── home_page.dart
│   ├── add_reminder_page.dart
│   ├── edit_reminder_page.dart
│   └── detail_page.dart
│
├── widgets/
│
├── main.dart
│
assets/
│
android/
ios/
```

---

## 🚀 Cara Menjalankan Project

### 1. Clone Repository

```bash
git clone https://github.com/username/cycle_app.git
```

### 2. Masuk ke Folder Project

```bash
cd cycle_app
```

### 3. Install Dependency

```bash
flutter pub get
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

---

## 📦 Dependency

```yaml
dependencies:
  flutter:
    sdk: flutter

  sqflite:
  path:
  path_provider:
  intl:
```

---

## 💾 Database

Aplikasi menggunakan **SQLite** sebagai database lokal.

Tabel utama:

**reminders**

| Field | Tipe |
|--------|------|
| id | INTEGER |
| title | TEXT |
| description | TEXT |
| date | TEXT |
| time | TEXT |
| category | TEXT |

---

## 📱 Minimum Requirement

- Flutter 3.x
- Dart SDK
- Android 7.0+
- Android Studio / VS Code

---

## 🎯 Tujuan Aplikasi

Cycle App dibuat untuk membantu pengguna membangun kebiasaan hidup sehat dengan memberikan pengingat aktivitas secara teratur sehingga aktivitas harian menjadi lebih terorganisir.

---

## 👨‍💻 Pengembang

Dikembangkan sebagai proyek **Mobile Programming** menggunakan Flutter.

---

## 📄 Lisensi

Project ini dibuat untuk keperluan pembelajaran dan akademik.
