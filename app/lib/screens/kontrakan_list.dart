import 'package:flutter/material.dart';

import '../models/kontrakan.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/formatter.dart';
import '../widget/property_card.dart';
import '../widget/sort_button.dart';
import '../widget/state_views.dart';
import 'kontrakan_detail.dart';
import 'kontrakan_form.dart';

class KontrakanListPage extends StatefulWidget {
  const KontrakanListPage({super.key});

  @override
  State<KontrakanListPage> createState() => _KontrakanListPageState();
}

class _KontrakanListPageState extends State<KontrakanListPage> {
  late Future<List<Kontrakan>> _kontrakan;
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  bool _onlyAvailable = false;
  bool _onlyMine = false; // khusus pemilik: tampilkan iklan sendiri saja
  String _sort = 'termurah'; // dikirim ke API: ?sort=...

  @override
  void initState() {
    super.initState();
    _kontrakan = ApiService.getKontrakan(sort: _sort);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _kontrakan = ApiService.getKontrakan(sort: _sort);
    });
    try {
      await _kontrakan;
    } catch (_) {}
  }

  Future<void> _openAddForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const KontrakanFormPage()),
    );
    if (saved == true) _refresh();
  }

  void _changeSort(String sort) {
    setState(() {
      _sort = sort;
      _kontrakan = ApiService.getKontrakan(sort: _sort);
    });
  }

  List<Kontrakan> _applyFilter(List<Kontrakan> list) {
    final keyword = _keyword.toLowerCase();
    return list.where((item) {
      final matchAvailable = !_onlyAvailable || item.isAvailable;
      final matchKeyword =
          keyword.isEmpty ||
          item.name.toLowerCase().contains(keyword) ||
          (item.areaName ?? '').toLowerCase().contains(keyword);
      final matchMine =
          !_onlyMine || item.ownerId == AuthService.instance.user?.id;
      return matchAvailable && matchKeyword && matchMine;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol tambah data (Create) hanya untuk akun pemilik kos
      floatingActionButton: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) => (AuthService.instance.user?.isPemilik ?? false)
            ? FloatingActionButton.extended(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Kontrakan'),
              )
            : const SizedBox.shrink(),
      ),
      appBar: AppBar(
        title: const Text('Daftar Kontrakan'),
        actions: [SortButton(value: _sort, onChanged: _changeSort)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama kontrakan atau area...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _keyword = value),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Hanya yang masih tersedia'),
                    selected: _onlyAvailable,
                    onSelected: (value) =>
                        setState(() => _onlyAvailable = value),
                  ),
                  if (AuthService.instance.user?.isPemilik ?? false)
                    FilterChip(
                      avatar: const Icon(Icons.storefront_rounded, size: 18),
                      label: const Text('Iklan saya'),
                      selected: _onlyMine,
                      onSelected: (value) => setState(() => _onlyMine = value),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Kontrakan>>(
              future: _kontrakan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal memuat data kontrakan.\n${snapshot.error}',
                    onRetry: _refresh,
                  );
                }

                final list = _applyFilter(snapshot.data ?? []);
                if (list.isEmpty) {
                  return const EmptyView(message: 'Kontrakan tidak ditemukan');
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final item = list[i];
                      return PropertyCard(
                        favoriteType: 'kontrakan',
                        id: item.id,
                        imageUrl: item.imageUrl,
                        title: item.name,
                        subtitle:
                            '${item.areaName ?? '-'} · ${item.bedrooms} kamar tidur',
                        price: formatRupiah(item.pricePerYear),
                        priceSuffix: '/tahun',
                        badge: item.isAvailable ? 'Tersedia' : 'Penuh',
                        badgeColor: item.isAvailable
                            ? Colors.green
                            : Colors.grey,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  KontrakanDetailPage(kontrakanId: item.id),
                            ),
                          );
                          // Muat ulang: data mungkin diubah/dihapus di detail
                          _refresh();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
