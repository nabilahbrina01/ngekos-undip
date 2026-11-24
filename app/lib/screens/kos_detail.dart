import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../widget/contact_actions.dart';
import '../widget/form_widgets.dart';
import '../widget/detail_widgets.dart';
import '../widget/favorite_button.dart';
import '../widget/network_image_box.dart';
import '../widget/state_views.dart';
import 'kos_form.dart';

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

  // Buka form ubah; jika tersimpan, muat ulang detail
  Future<void> _edit(Kos data) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => KosFormPage(kos: data)),
    );
    if (saved == true) {
      setState(() {
        _kos = ApiService.getKosById(widget.kosId);
      });
    }
  }

  // Konfirmasi lalu DELETE /api/kos/:id
  Future<void> _delete(String id, String name) async {
    if (!await confirmDelete(context, name)) return;
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.deleteKos(id);
      navigator.pop(); // kembali ke daftar, daftar akan dimuat ulang
      messenger.showSnackBar(SnackBar(content: Text('"$name" dihapus')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
                  // Ubah data (Update)
                  _CircleAction(
                    icon: Icons.edit_rounded,
                    tooltip: 'Ubah',
                    onPressed: () => _edit(kos),
                  ),
                  // Hapus data (Delete)
                  _CircleAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Hapus',
                    color: Colors.red.shade700,
                    onPressed: () => _delete(kos.id, kos.name),
                  ),
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
                      MapsButton(
                        query:
                            kos.address ??
                            '${kos.name} ${kos.areaName ?? ''} Semarang',
                      ),
                      const SizedBox(height: 12),
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
          // Bar bawah: harga + tombol chat WhatsApp pemilik
          bottomNavigationBar: _PriceBar(
            price: formatRupiah(kos.pricePerMonth),
            suffix: '/bulan',
            phone: kos.ownerPhone,
            message:
                'Halo, saya melihat kos "${kos.name}" di aplikasi NgekosUndip. '
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

/// Tombol bulat putih di AppBar (ubah / hapus).
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, color: color ?? AppColors.navy),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
