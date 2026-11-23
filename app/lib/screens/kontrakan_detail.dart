import 'package:flutter/material.dart';

import '../models/kontrakan.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../widget/contact_actions.dart';
import '../widget/detail_widgets.dart';
import '../widget/favorite_button.dart';
import '../widget/network_image_box.dart';
import '../widget/state_views.dart';

class KontrakanDetailPage extends StatefulWidget {
  final String kontrakanId;

  const KontrakanDetailPage({super.key, required this.kontrakanId});

  @override
  State<KontrakanDetailPage> createState() => _KontrakanDetailPageState();
}

class _KontrakanDetailPageState extends State<KontrakanDetailPage> {
  late Future<Kontrakan> _kontrakan;

  @override
  void initState() {
    super.initState();
    // GET /api/kontrakan/:id
    _kontrakan = ApiService.getKontrakanById(widget.kontrakanId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Kontrakan>(
      future: _kontrakan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Kontrakan')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Kontrakan')),
            body: ErrorView(
              message: 'Gagal memuat detail kontrakan.\n${snapshot.error}',
              onRetry: () => setState(() {
                _kontrakan = ApiService.getKontrakanById(widget.kontrakanId);
              }),
            ),
          );
        }

        final item = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Foto besar yang mengecil saat halaman di-scroll
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                title: const Text('Detail Kontrakan'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: FavoriteButton(type: 'kontrakan', id: item.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: NetworkImageBox(
                    url: item.imageUrl,
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
                      _Badge(
                        text: item.isAvailable ? 'Tersedia' : 'Sudah penuh',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.name,
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
                              '${item.areaName ?? '-'} · ${item.address ?? '-'}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      MapsButton(
                        query:
                            item.address ??
                            '${item.name} ${item.areaName ?? ''} Semarang',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InfoBox(
                            icon: Icons.bed,
                            label: 'kamar tidur',
                            value: '${item.bedrooms}',
                          ),
                          const SizedBox(width: 8),
                          InfoBox(
                            icon: Icons.bathtub,
                            label: 'kamar mandi',
                            value: '${item.bathrooms}',
                          ),
                          const SizedBox(width: 8),
                          InfoBox(
                            icon: Icons.directions_walk,
                            label: 'ke kampus',
                            value: item.distanceKm == null
                                ? '-'
                                : '${item.distanceKm!.toStringAsFixed(1)} km',
                          ),
                        ],
                      ),
                      const DetailSectionTitle('Deskripsi'),
                      Text(
                        item.description ?? '-',
                        style: const TextStyle(height: 1.5),
                      ),
                      const DetailSectionTitle('Fasilitas'),
                      FacilityChips(facilities: item.facilities),
                      const DetailSectionTitle('Pemilik'),
                      OwnerCard(name: item.ownerName, phone: item.ownerPhone),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bar bawah: harga + tombol chat WhatsApp pemilik
          bottomNavigationBar: _PriceBar(
            price: formatRupiah(item.pricePerYear),
            suffix: '/tahun',
            phone: item.ownerPhone,
            message:
                'Halo, saya melihat kontrakan "${item.name}" di aplikasi NgekosUndip. '
                'Apakah masih tersedia?',
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
  final String message;

  const _PriceBar({
    required this.price,
    required this.suffix,
    required this.phone,
    required this.message,
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
                  : () =>
                        openWhatsApp(context, phone: phone!, message: message),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }
}
