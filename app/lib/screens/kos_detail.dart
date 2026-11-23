import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kos'),
        actions: [FavoriteButton(type: 'kos', id: widget.kosId)],
      ),
      body: FutureBuilder<Kos>(
        future: _kos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat detail kos.\n${snapshot.error}',
              onRetry: () => setState(() {
                _kos = ApiService.getKosById(widget.kosId);
              }),
            );
          }

          final kos = snapshot.data!;
          final colors = Theme.of(context).colorScheme;

          return ListView(
            children: [
              NetworkImageBox(url: kos.imageUrl, height: 230),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(label: Text('Kos ${capitalize(kos.type)}')),
                    const SizedBox(height: 4),
                    Text(
                      kos.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${kos.areaName ?? '-'} · ${kos.address ?? '-'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatRupiah(kos.pricePerMonth),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const TextSpan(
                            text: ' /bulan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    Text(kos.description ?? '-'),
                    const DetailSectionTitle('Fasilitas'),
                    FacilityChips(facilities: kos.facilities),
                    const DetailSectionTitle('Pemilik'),
                    OwnerCard(name: kos.ownerName, phone: kos.ownerPhone),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}