import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kotak info kecil (ikon + label + nilai), dipakai di halaman detail.
class InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul bagian di halaman detail.
class DetailSectionTitle extends StatelessWidget {
  final String text;
  const DetailSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Daftar fasilitas dalam bentuk chip.
class FacilityChips extends StatelessWidget {
  final List<String> facilities;
  const FacilityChips({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) {
      return const Text(
        'Belum ada data fasilitas',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: facilities
          .map(
            (f) => Chip(
              avatar: const Icon(Icons.check_circle, size: 18),
              label: Text(f),
            ),
          )
          .toList(),
    );
  }
}

/// Kartu pemilik + tombol salin nomor HP.
class OwnerCard extends StatelessWidget {
  final String? name;
  final String? phone;

  const OwnerCard({super.key, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name ?? 'Pemilik'),
        subtitle: Text(phone ?? '-'),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Salin nomor',
          onPressed: phone == null
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: phone!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor HP disalin')),
                  );
                },
        ),
      ),
    );
  }
}