import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // GANTI dengan data diri kamu
  static const String nama = 'Nama Lengkap Kamu';
  static const String nim = '211201231300XX';
  static const String prodi = 'Teknik Komputer, Universitas Diponegoro';
  static const String github = 'github.com/username-kamu';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Data pembuat =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(nim, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text(prodi, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== Tentang aplikasi =====
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang NgekosUndip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NgekosUndip membantu mahasiswa Universitas Diponegoro '
                    'mencari kos dan kontrakan di sekitar kampus Tembalang '
                    'dan Pleburan. Pengguna dapat melihat harga, fasilitas, '
                    'jarak ke kampus, kontak pemilik, dan menyimpan pilihan '
                    'ke daftar favorit.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== Info teknis =====
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versi'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Dibuat dengan'),
                  subtitle: Text('Flutter'),
                ),
                ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('Backend'),
                  subtitle: Text('Express.js + Supabase, deploy di Vercel'),
                ),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Source code'),
                  subtitle: Text(github),
                ),
                ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Keperluan'),
                  subtitle: Text('Tugas Akhir Praktikum PPB 2026'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}