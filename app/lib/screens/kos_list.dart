import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
import '../utils/formatter.dart';
import '../widget/property_card.dart';
import '../widget/sort_button.dart';
import '../widget/state_views.dart';
import 'kos_detail.dart';
import 'kos_form.dart';

class KosListPage extends StatefulWidget {
  const KosListPage({super.key});

  @override
  State<KosListPage> createState() => _KosListPageState();
}

class _KosListPageState extends State<KosListPage> {
  late Future<List<Kos>> _kos;
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  String _selectedType = 'semua';
  String _sort = 'termurah'; // dikirim ke API: ?sort=...

  static const List<String> _types = ['semua', 'putra', 'putri', 'campur'];

  @override
  void initState() {
    super.initState();
    _kos = ApiService.getKos(sort: _sort);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _kos = ApiService.getKos(sort: _sort);
    });
    try {
      await _kos;
    } catch (_) {}
  }

  Future<void> _openAddForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const KosFormPage()),
    );
    if (saved == true) _refresh();
  }

  void _changeSort(String sort) {
    setState(() {
      _sort = sort;
      _kos = ApiService.getKos(sort: _sort);
    });
  }

  List<Kos> _applyFilter(List<Kos> list) {
    return list.where((kos) {
      final matchType = _selectedType == 'semua' || kos.type == _selectedType;
      final keyword = _keyword.toLowerCase();
      final matchKeyword =
          keyword.isEmpty ||
          kos.name.toLowerCase().contains(keyword) ||
          (kos.areaName ?? '').toLowerCase().contains(keyword);
      return matchType && matchKeyword;
    }).toList();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'putra':
        return Colors.blue;
      case 'putri':
        return Colors.pink;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol tambah data (Create)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kos'),
      ),
      appBar: AppBar(
        title: const Text('Daftar Kos'),
        actions: [SortButton(value: _sort, onChanged: _changeSort)],
      ),
      body: Column(
        children: [
          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama kos atau area...',
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
          // Filter tipe kos
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _types
                  .map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(capitalize(type)),
                        selected: _selectedType == type,
                        onSelected: (_) => setState(() => _selectedType = type),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // List kos dari API
          Expanded(
            child: FutureBuilder<List<Kos>>(
              future: _kos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal memuat data kos.\n${snapshot.error}',
                    onRetry: _refresh,
                  );
                }

                final list = _applyFilter(snapshot.data ?? []);
                if (list.isEmpty) {
                  return const EmptyView(message: 'Kos tidak ditemukan');
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final kos = list[i];
                      return PropertyCard(
                        favoriteType: 'kos',
                        id: kos.id,
                        imageUrl: kos.imageUrl,
                        title: kos.name,
                        subtitle:
                            '${kos.areaName ?? '-'} · ${formatDistance(kos.distanceKm)}',
                        price: formatRupiah(kos.pricePerMonth),
                        priceSuffix: '/bulan',
                        badge: 'Kos ${capitalize(kos.type)}',
                        badgeColor: _typeColor(kos.type),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  KosDetailPage(kosId: kos.id),
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
