import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka WhatsApp pemilik dengan pesan yang sudah terisi.
Future<void> openWhatsApp(
  BuildContext context, {
  required String phone,
  required String message,
}) {
  // 0812xxxx -> 62812xxxx (format nomor internasional untuk wa.me)
  var number = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (number.startsWith('0')) number = '62${number.substring(1)}';
  if (number.startsWith('8')) number = '62$number';

  final uri = Uri.parse(
    'https://wa.me/$number?text=${Uri.encodeComponent(message)}',
  );
  return _open(context, uri, 'WhatsApp');
}

/// Membuka Google Maps dan mencari alamat kos/kontrakan.
Future<void> openMaps(BuildContext context, String query) {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
  );
  return _open(context, uri, 'Google Maps');
}

Future<void> _open(BuildContext context, Uri uri, String appName) async {
  final messenger = ScaffoldMessenger.of(context);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened) {
    messenger.showSnackBar(
      SnackBar(content: Text('Tidak dapat membuka $appName')),
    );
  }
}

/// Tombol kecil "Lihat di Google Maps" di bawah alamat.
class MapsButton extends StatelessWidget {
  final String query;
  const MapsButton({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => openMaps(context, query),
      icon: const Icon(Icons.map_rounded, size: 18),
      label: const Text('Lihat di Google Maps'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}