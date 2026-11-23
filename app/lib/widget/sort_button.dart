import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Pilihan urutan yang dikirim ke API (?sort=...).
const Map<String, String> sortOptions = {
  'termurah': 'Harga termurah',
  'termahal': 'Harga termahal',
  'terdekat': 'Jarak terdekat',
};

/// Tombol "Urutkan" di AppBar halaman list.
class SortButton extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SortButton({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Urutkan',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => sortOptions.entries
          .map(
            (option) => CheckedPopupMenuItem<String>(
              value: option.key,
              checked: option.key == value,
              child: Text(option.value),
            ),
          )
          .toList(),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(
              sortOptions[value]!.split(' ').last, // termurah/termahal/terdekat
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}