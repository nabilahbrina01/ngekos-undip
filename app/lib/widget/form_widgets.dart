import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/area.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

/// Judul kecil pemisah kelompok isian di form.
class FormSectionTitle extends StatelessWidget {
  final String text;
  const FormSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

/// Kolom isian teks/angka dengan label dan ikon.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final bool number; // hanya angka bulat
  final bool decimal; // angka desimal, misalnya 1.5
  final int maxLines;
  final String? hint;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.number = false,
    this.decimal = false,
    this.maxLines = 1,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType:
            keyboardType ??
            (number
                ? TextInputType.number
                : decimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text),
        inputFormatters: number
            ? [FilteringTextInputFormatter.digitsOnly]
            : decimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return '$label wajib diisi';
          if (decimal && text.isNotEmpty && parseDecimal(text) == null) {
            return 'Format angka tidak valid';
          }
          return null;
        },
      ),
    );
  }
}

/// Pilihan area (diambil dari GET /api/areas).
class AreaDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const AreaDropdown({super.key, required this.value, required this.onChanged});

  @override
  State<AreaDropdown> createState() => _AreaDropdownState();
}

class _AreaDropdownState extends State<AreaDropdown> {
  late Future<List<Area>> _areas;

  @override
  void initState() {
    super.initState();
    _areas = ApiService.getAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FutureBuilder<List<Area>>(
        future: _areas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError) {
            return TextButton.icon(
              onPressed: () => setState(() => _areas = ApiService.getAreas()),
              icon: const Icon(Icons.refresh),
              label: const Text('Gagal memuat area, coba lagi'),
            );
          }
          final areas = snapshot.data!;
          final value = areas.any((a) => a.id == widget.value)
              ? widget.value
              : null;
          return DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              labelText: 'Area *',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: areas
                .map(
                  (area) =>
                      DropdownMenuItem(value: area.id, child: Text(area.name)),
                )
                .toList(),
            onChanged: widget.onChanged,
            validator: (value) => value == null ? 'Pilih area' : null,
          );
        },
      ),
    );
  }
}

/// "1,5" atau "1.5" -> 1.5 ; kosong -> null
double? parseDecimal(String text) {
  final clean = text.trim().replaceAll(',', '.');
  if (clean.isEmpty) return null;
  return double.tryParse(clean);
}

/// Kosong -> null, selain itu teks yang sudah di-trim.
String? emptyToNull(String text) {
  final clean = text.trim();
  return clean.isEmpty ? null : clean;
}

/// "WiFi, Kasur, AC" -> ["WiFi", "Kasur", "AC"]
List<String> splitFacilities(String text) {
  return text
      .split(',')
      .map((f) => f.trim())
      .where((f) => f.isNotEmpty)
      .toList();
}

/// Dialog konfirmasi hapus. Mengembalikan true jika pengguna memilih Hapus.
Future<bool> confirmDelete(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus data?'),
      content: Text('"$name" akan dihapus permanen dari database.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return result ?? false;
}
