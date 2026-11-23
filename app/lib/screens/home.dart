import 'package:flutter/material.dart';

import '../models/area.dart';
import '../models/kos.dart';
import '../services/api_service.dart';
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===== Header =====
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 24,
                20,
                28,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NgekosUndip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cari kos & kontrakan di sekitar Universitas Diponegoro',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Menu cepat =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.bed,
                      title: 'Cari Kos',
                      subtitle: 'Bayar bulanan',
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.house,
                      title: 'Cari Kontrakan',
                      subtitle: 'Bayar tahunan',
                      onTap: () => widget.onNavigate(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Gagal memuat area. Tarik ke bawah untuk muat ulang.',
                    ),
                  );
                }
                final areas = snapshot.data ?? [];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: areas
                        .map(
                          (area) => Chip(
                            avatar: const Icon(Icons.place, size: 18),
                            label: Text(
                              area.distanceKm == null
                                  ? area.name
                                  : '${area.name} · ${area.distanceKm!.toStringAsFixed(1)} km',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ===== Kos termurah (GET /api/kos, sudah urut harga) =====
            const _SectionTitle('Kos Termurah'),
            FutureBuilder<List<Kos>>(
              future: _kos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final list = (snapshot.data ?? []).take(3).toList();
                return Column(
                  children: list
                      .map(
                        (kos) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: NetworkImageBox(
                              url: kos.imageUrl,
                              height: 56,
                              width: 72,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            title: Text(kos.name),
                            subtitle: Text(
                              '${kos.areaName ?? '-'} · ${formatRupiah(kos.pricePerMonth)}/bln',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    KosDetailPage(kosId: kos.id),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
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
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}