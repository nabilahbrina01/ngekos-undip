import 'package:flutter/material.dart';

import '../services/favorite_service.dart';

/// Tombol hati. type = "kos" atau "kontrakan".
class FavoriteButton extends StatelessWidget {
  final String type;
  final String id;
  final Color? color;

  const FavoriteButton({
    super.key,
    required this.type,
    required this.id,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteService.instance;

    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final isFav = favorites.isFavorite(type, id);
        return IconButton(
          tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : color,
          ),
          onPressed: () => favorites.toggle(type, id),
        );
      },
    );
  }
}