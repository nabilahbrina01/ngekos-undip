import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../widget/detail_widgets.dart';
import '../widget/favorite_button.dart';
import '../widget/network_image_box.dart';
import '../widget/state_views.dart';

class KosDetailPage extends StatefulWidget {
  final String kosId;

  const KosDetailPage({super.key, required this.kosId});

  @override
  State<KosDetailPage> createState() => _KosDetailPageState();
}

class _KosDetailPageState extends State<KosDetailPage> {
  late Future<Kos> _kos;

  @override
  void initState() {
    super.initState();
    // GET /api/kos/:id
    _kos = ApiService.getKosById(widget.kosId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Kos>(
      future: _kos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Kos')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Kos')),
            body: ErrorView(
              message: 'Gagal memuat detail kos.\n${snapshot.error}',
              onRetry: () => setState(() {
                _kos = ApiService.getKosById(widget.kosId);
              }),
            ),
          );
        }

        final kos = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Foto besar yang mengecil saat halaman di-scroll
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                title: const Text('Detail Kos'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: FavoriteButton(type: 'kos', id: kos.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: NetworkImageBox(
                    url: kos.imageUrl,
                    height: double.infinity,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Badge(text: 'Kos ${capitalize(kos.type)}'),
                      const SizedBox(height: 10),
                      Text(
                        kos.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${kos.areaName ?? '-'} · ${kos.address ?? '-'}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          InfoBox(
                            icon: Icons.directions_walk,
                            label: 'ke kampus',
                            value: kos.distanceKm == null
                                ? '-'
                                : '${kos.distanceKm!.toStringAsFixed(1)} km',
                          ),
                          const SizedBox(width: 8),
                          InfoBox(
                            icon: Icons.meeting_room,
                            label: 'kamar kosong',
                            value: '${kos.availableRooms}',
                          ),
                          const SizedBox(width: 8),
                          InfoBox(
                            icon: Icons.wc,
                            label: 'tipe',
                            value: capitalize(kos.type),
                          ),
                        ],
                      ),
                      const DetailSectionTitle('Deskripsi'),
                      Text(
                        kos.description ?? '-',
                        style: const TextStyle(height: 1.5),
                      ),
                      const DetailSectionTitle('Fasilitas'),
                      FacilityChips(facilities: kos.facilities),
                      const DetailSectionTitle('Pemilik'),
                      OwnerCard(name: kos.ownerName, phone: kos.ownerPhone),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bar bawah: harga + tombol salin kontak pemilik
          bottomNavigationBar: _PriceBar(
            price: formatRupiah(kos.pricePerMonth),
            suffix: '/bulan',
            phone: kos.ownerPhone,
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriceBar extends StatelessWidget {
  final String price;
  final String suffix;
  final String? phone;

  const _PriceBar({
    required this.price,
    required this.suffix,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      TextSpan(
                        text: ' $suffix',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: FilledButton.icon(
              onPressed: phone == null
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: phone!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor pemilik disalin')),
                      );
                    },
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text('Kontak'),
            ),
          ),
        ],
      ),
    );
  }
}