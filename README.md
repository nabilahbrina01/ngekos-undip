# NgekosUndip

**Aplikasi Informasi Kos dan Kontrakan untuk Mahasiswa Universitas Diponegoro**

Tugas Akhir Praktikum Pemrograman Perangkat Bergerak (PPB) 2026

| | |
|---|---|
| Nama | Nabilah Brina Assyifa |
| NIM | 21120123120025 |
| Program Studi | Teknik Komputer, Universitas Diponegoro |

NgekosUndip membantu mahasiswa Undip mencari kos dan kontrakan di sekitar kampus (Tembalang, Sumurboto, Meteseh, Jatimulyo, Banyumanik). Pengguna bisa melihat daftar dan detail kos/kontrakan, mencari dan memfilter, menyimpan favorit, serta login dengan akun sendiri.

## Arsitektur

```
Aplikasi Flutter  --HTTP-->  REST API buatan sendiri (Express.js, Vercel)  -->  Database PostgreSQL (Supabase)
```

Aplikasi Flutter **hanya** memanggil API buatan sendiri di `https://ngekos-undip.vercel.app/api`. Aplikasi tidak mengakses Supabase secara langsung. Seluruh baca/tulis database dilakukan oleh backend Express.

## Struktur Folder

```
ngekos-undip/
├── api/                    # Backend: Express.js + Supabase (deploy di Vercel)
│   ├── database/           # schema.sql, seed.sql, users.sql
│   ├── src/
│   │   ├── config/         # koneksi Supabase
│   │   ├── models/         # query ke database
│   │   ├── controllers/    # logika tiap endpoint
│   │   ├── routes/         # definisi endpoint
│   │   ├── middleware/     # verifikasi token JWT
│   │   └── index.js        # entry point server
│   ├── .env.example
│   └── vercel.json
└── app/                    # Frontend: Flutter
    └── lib/
        ├── config/         # base URL API
        ├── models/         # Area, Kos, Kontrakan, User
        ├── services/       # pemanggilan API, login, favorit
        ├── screens/        # halaman-halaman aplikasi
        ├── widget/         # komponen UI & bottom navigation
        ├── utils/          # tema & formatter
        └── main.dart
```

## Fitur dan Halaman

- **Login & Daftar**: autentikasi akun (password di-hash bcrypt, token JWT)
- **Beranda**: sapaan, pencarian cepat, pilihan area, rekomendasi kos
- **List Kos → Detail Kos**: cari, filter area & tipe (putra/putri/campur)
- **List Kontrakan → Detail Kontrakan**: cari, filter area & ketersediaan
- **Favorit**: simpan kos/kontrakan favorit
- **Profil**: data pengguna, info pembuat aplikasi, logout

Navigasi utama menggunakan **Bottom Navigation Bar** (Beranda, Kos, Kontrakan, Favorit, Profil).

## Endpoint API

Base URL: `https://ngekos-undip.vercel.app/api`

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/auth/register` | Daftar akun (`name`, `email`, `password`) |
| POST | `/auth/login` | Login (`email`, `password`), mengembalikan token |
| GET | `/auth/me` | Data user yang login (header `Authorization: Bearer <token>`) |
| GET | `/areas` | Semua area |
| GET | `/areas/:id` | Detail area |
| POST / PUT / DELETE | `/areas`, `/areas/:id` | Tambah / ubah / hapus area |
| GET | `/kos` | Semua kos. Query opsional: `search`, `area_id`, `type` |
| GET | `/kos/:id` | Detail kos |
| POST / PUT / DELETE | `/kos`, `/kos/:id` | Tambah / ubah / hapus kos |
| GET | `/kontrakan` | Semua kontrakan. Query opsional: `search`, `area_id`, `available` |
| GET | `/kontrakan/:id` | Detail kontrakan |
| POST / PUT / DELETE | `/kontrakan`, `/kontrakan/:id` | Tambah / ubah / hapus kontrakan |

## Cara Menjalankan

### Backend (api)

1. Buat project di Supabase, lalu jalankan `api/database/schema.sql`, `seed.sql`, dan `users.sql` di SQL Editor.
2. Salin `.env.example` menjadi `.env`, lalu isi `SUPABASE_URL`, `SUPABASE_KEY`, dan `JWT_SECRET`.
3. Jalankan:
   ```bash
   cd api
   npm install
   npm run dev
   ```
   Server berjalan di `http://localhost:3000`.

### Frontend (app)

```bash
cd app
flutter pub get
flutter run
```

Base URL API diatur di `app/lib/config/api_config.dart`.

### Build APK

```bash
cd app
flutter build apk --release
```

Hasil: `app/build/app/outputs/flutter-apk/app-release.apk`

## Teknologi

- **Frontend:** Flutter (Dart), `http`, `shared_preferences`
- **Backend:** Node.js, Express.js, `@supabase/supabase-js`, `bcryptjs`, `jsonwebtoken`, `cors`, `dotenv`
- **Database:** PostgreSQL (Supabase)
- **Deploy:** Vercel