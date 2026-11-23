import 'package:flutter/material.dart';

import '../models/kontrakan.dart';
import '../services/api_service.dart';
import '../utils/formatter.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontrakan'),
        actions: [FavoriteButton(type: 'kontrakan', id: widget.kontrakanId)],
      ),
      body: FutureBuilder<Kontrakan>(
        future: _kontrakan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat detail kontrakan.\n${snapshot.error}',
              onRetry: () => setState(() {
                _kontrakan = ApiService.getKontrakanById(widget.kontrakanId);
              }),
            );
          }

          final item = snapshot.data!;
          final colors = Theme.of(context).colorScheme;

          return ListView(
            children: [
              NetworkImageBox(url: item.imageUrl, height: 230),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(
                        item.isAvailable ? 'Tersedia' : 'Sudah penuh',
                      ),
                      backgroundColor: item.isAvailable
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.areaName ?? '-'} · ${item.address ?? '-'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatRupiah(item.pricePerYear),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const TextSpan(
                            text: ' /tahun',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    Text(item.description ?? '-'),
                    const DetailSectionTitle('Fasilitas'),
                    FacilityChips(facilities: item.facilities),
                    const DetailSectionTitle('Pemilik'),
                    OwnerCard(name: item.ownerName, phone: item.ownerPhone),
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