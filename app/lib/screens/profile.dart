import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Data pembuat aplikasi
  static const String nama = 'Nabilah Brina Assyifa';
  static const String nim = '21120123120025';
  static const String prodi = 'Teknik Komputer, Universitas Diponegoro';

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    // Setelah logout, main.dart otomatis menampilkan halaman Login
    if (yes == true) await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final userName = user?.name ?? '-';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== Header akun yang sedang login =====
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    userName.isEmpty || userName == '-'
                        ? '?'
                        : userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== Data pembuat aplikasi =====
          const _SectionLabel('Pembuat Aplikasi'),
          const _InfoCard(
            children: [
              _InfoTile(icon: Icons.person_rounded, title: 'Nama', value: nama),
              _InfoTile(icon: Icons.badge_rounded, title: 'NIM', value: nim),
              _InfoTile(
                icon: Icons.school_rounded,
                title: 'Program Studi',
                value: prodi,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== Tentang aplikasi =====
          const _SectionLabel('Tentang Aplikasi'),
          const _InfoCard(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'NgekosUndip membantu mahasiswa Universitas Diponegoro '
                  'mencari kos dan kontrakan di sekitar kampus Tembalang, '
                  'seperti Sumurboto, Meteseh, Jatimulyo, dan Banyumanik. '
                  'Pengguna dapat melihat harga, fasilitas, '
                  'jarak ke kampus, menghubungi pemilik lewat WhatsApp, '
                  'membuka lokasi di Google Maps, dan menyimpan pilihan '
                  'ke daftar favorit.',
                  style: TextStyle(height: 1.5),
                ),
              ),
              _InfoTile(
                icon: Icons.info_outline,
                title: 'Versi',
                value: '1.0.0',
              ),
              _InfoTile(
                icon: Icons.phone_android,
                title: 'Dibuat dengan',
                value: 'Flutter',
              ),
              _InfoTile(
                icon: Icons.cloud_outlined,
                title: 'Backend',
                value: 'Express.js + Supabase, deploy di Vercel',
              ),
              _InfoTile(
                icon: Icons.assignment_outlined,
                title: 'Keperluan',
                value: 'Tugas Akhir Praktikum PPB 2026',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ===== Tombol keluar =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar dari akun'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.navy, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
