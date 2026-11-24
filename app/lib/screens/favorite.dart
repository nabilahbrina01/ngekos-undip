import 'package:flutter/material.dart';

import '../models/kontrakan.dart';
import '../models/kos.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../utils/formatter.dart';
import '../widget/favorite_button.dart';
import '../widget/network_image_box.dart';
import '../widget/state_views.dart';
import 'kontrakan_detail.dart';
import 'kos_detail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Kos>> _kos;
  late Future<List<Kontrakan>> _kontrakan;
  late Future<List<Object>> _all;
  final FavoriteService _favorites = FavoriteService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _kos = ApiService.getKos();
    _kontrakan = ApiService.getKontrakan();
    _all = Future.wait<Object>([_kos, _kontrakan]);
  }

  Future<void> _refresh() async {
    setState(_loadData);
    try {
      await _all;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: FutureBuilder<List<Object>>(
        // Ambil semua kos & kontrakan, lalu saring yang ada di favorit
        future: _all,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat favorit.\n${snapshot.error}',
              onRetry: _refresh,
            );
          }

          final allKos = snapshot.data![0] as List<Kos>;
          final allKontrakan = snapshot.data![1] as List<Kontrakan>;

          // ListenableBuilder: halaman langsung berubah saat tombol hati ditekan
          return ListenableBuilder(
            listenable: _favorites,
            builder: (context, _) {
              final favKos = allKos
                  .where((k) => _favorites.isFavorite('kos', k.id))
                  .toList();
              final favKontrakan = allKontrakan
                  .where((k) => _favorites.isFavorite('kontrakan', k.id))
                  .toList();

              if (favKos.isEmpty && favKontrakan.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: const [
                      SizedBox(height: 120),
                      EmptyView(
                        icon: Icons.favorite_border,
                        message:
                            'Belum ada favorit.\nTekan ikon hati pada kos atau kontrakan untuk menyimpannya.',
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    if (favKos.isNotEmpty) const _Header('Kos'),
                    ...favKos.map(
                      (kos) => _FavoriteTile(
                        type: 'kos',
                        id: kos.id,
                        imageUrl: kos.imageUrl,
                        title: kos.name,
                        subtitle:
                            '${kos.areaName ?? '-'} · ${formatRupiah(kos.pricePerMonth)}/bulan',
                        page: KosDetailPage(kosId: kos.id),
                        onReturn: _refresh,
                      ),
                    ),
                    if (favKontrakan.isNotEmpty) const _Header('Kontrakan'),
                    ...favKontrakan.map(
                      (item) => _FavoriteTile(
                        type: 'kontrakan',
                        id: item.id,
                        imageUrl: item.imageUrl,
                        title: item.name,
                        subtitle:
                            '${item.areaName ?? '-'} · ${formatRupiah(item.pricePerYear)}/tahun',
                        page: KontrakanDetailPage(kontrakanId: item.id),
                        onReturn: _refresh,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final String type;
  final String id;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final Widget page;
  final VoidCallback onReturn; // muat ulang setelah kembali dari detail

  const _FavoriteTile({
    required this.type,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.page,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: NetworkImageBox(
          url: imageUrl,
          height: 56,
          width: 72,
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FavoriteButton(type: type, id: id),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
          onReturn();
        },
      ),
    );
  }
}
