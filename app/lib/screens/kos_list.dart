import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
import '../utils/formatter.dart';
import '../widget/property_card.dart';
import '../widget/state_views.dart';
import 'kos_detail.dart';

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

  static const List<String> _types = ['semua', 'putra', 'putri', 'campur'];

  @override
  void initState() {
    super.initState();
    _kos = ApiService.getKos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _kos = ApiService.getKos();
    });
    try {
      await _kos;
    } catch (_) {}
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
      appBar: AppBar(title: const Text('Daftar Kos')),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  KosDetailPage(kosId: kos.id),
                            ),
                          );
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