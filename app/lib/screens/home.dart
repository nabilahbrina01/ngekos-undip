import 'package:flutter/material.dart';

import '../models/area.dart';
import '../models/kos.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../widget/network_image_box.dart';
import 'kos_detail.dart';

class HomePage extends StatefulWidget {
  /// Dipanggil untuk pindah tab bottom navigation (1 = Kos, 2 = Kontrakan)
  final void Function(int index) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Area>> _areas;
  late Future<List<Kos>> _kos;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _areas = ApiService.getAreas();
    _kos = ApiService.getKos();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    try {
      await Future.wait([_areas, _kos]);
    } catch (_) {
      // Error sudah ditampilkan oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama depan user yang sedang login, misalnya "Nabilah"
    final fullName = AuthService.instance.user?.name ?? 'Mahasiswa';
    final firstName = fullName.split(' ').first;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===== Header bergradasi =====
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 20,
                20,
                64,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.gold,
                        child: Text(
                          firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $firstName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Mau ngekos di mana hari ini?',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Kotak "pencarian": ketuk untuk membuka tab Kos
                  InkWell(
                    onTap: () => widget.onNavigate(1),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Cari kos di sekitar Undip...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Menu cepat (sedikit menutupi header) =====
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _MenuCard(
                        icon: Icons.bed_rounded,
                        title: 'Cari Kos',
                        subtitle: 'Bayar bulanan',
                        onTap: () => widget.onNavigate(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MenuCard(
                        icon: Icons.house_rounded,
                        title: 'Kontrakan',
                        subtitle: 'Bayar tahunan',
                        onTap: () => widget.onNavigate(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Area populer (GET /api/areas) =====
            const _SectionTitle('Area Populer'),
            FutureBuilder<List<Area>>(
              future: _areas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Gagal memuat area. Tarik ke bawah untuk muat ulang.',
                    ),
                  );
                }
                final areas = snapshot.data ?? [];
                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: areas.length,
                    separatorBuilder: (context, i) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final area = areas[i];
                      return Chip(
                        avatar: const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        label: Text(
                          area.distanceKm == null
                              ? area.name
                              : '${area.name} · ${area.distanceKm!.toStringAsFixed(1)} km',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ===== Kos termurah (GET /api/kos, sudah urut harga) =====
            _SectionTitle(
              'Kos Termurah',
              actionLabel: 'Lihat semua',
              onAction: () => widget.onNavigate(1),
            ),
            FutureBuilder<List<Kos>>(
              future: _kos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 230,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final list = (snapshot.data ?? []).take(5).toList();
                return SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    itemCount: list.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, i) => _KosMiniCard(kos: list[i]),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // ===== Banner ajakan ke tab Kontrakan =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => widget.onNavigate(2),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 40,
                        color: AppColors.navy,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mau tinggal bareng teman?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Lihat pilihan kontrakan di sekitar kampus',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.navy),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle(this.text, {this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.navyLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.navy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu kecil untuk daftar "Kos Termurah" yang bisa digeser ke samping.
class _KosMiniCard extends StatelessWidget {
  final Kos kos;
  const _KosMiniCard({required this.kos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KosDetailPage(kosId: kos.id),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkImageBox(url: kos.imageUrl, height: 110),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kos.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kos.areaName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatRupiah(kos.pricePerMonth),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyLight,
                            ),
                          ),
                          const TextSpan(
                            text: ' /bln',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}