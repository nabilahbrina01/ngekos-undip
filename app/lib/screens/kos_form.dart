import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../services/api_service.dart';
import '../widget/form_widgets.dart';
import '../widget/otp_widgets.dart';

/// Form tambah kos (kos == null) atau ubah kos (kos != null).
/// Mengembalikan true ke halaman sebelumnya jika data berhasil disimpan.
class KosFormPage extends StatefulWidget {
  final Kos? kos;

  const KosFormPage({super.key, this.kos});

  @override
  State<KosFormPage> createState() => _KosFormPageState();
}

class _KosFormPageState extends State<KosFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _distance;
  late final TextEditingController _rooms;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late final TextEditingController _facilities;
  late final TextEditingController _imageUrl;
  late final TextEditingController _ownerName;
  late final TextEditingController _ownerPhone;
  String? _areaId;
  String _type = 'campur';
  bool _saving = false;

  bool get _isEdit => widget.kos != null;

  @override
  void initState() {
    super.initState();
    final kos = widget.kos; // null saat tambah data baru
    _name = TextEditingController(text: kos?.name ?? '');
    _price = TextEditingController(text: kos?.pricePerMonth.toString() ?? '');
    _distance = TextEditingController(text: kos?.distanceKm?.toString() ?? '');
    _rooms = TextEditingController(text: kos?.availableRooms.toString() ?? '');
    _address = TextEditingController(text: kos?.address ?? '');
    _description = TextEditingController(text: kos?.description ?? '');
    _facilities = TextEditingController(text: kos?.facilities.join(', ') ?? '');
    _imageUrl = TextEditingController(text: kos?.imageUrl ?? '');
    _ownerName = TextEditingController(text: kos?.ownerName ?? '');
    _ownerPhone = TextEditingController(text: kos?.ownerPhone ?? '');
    _areaId = kos?.areaId;
    _type = kos?.type ?? 'campur';
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _price,
      _distance,
      _rooms,
      _address,
      _description,
      _facilities,
      _imageUrl,
      _ownerName,
      _ownerPhone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Nama kolom harus sama dengan kolom tabel "kos" di Supabase
    final data = {
      'name': _name.text.trim(),
      'area_id': _areaId,
      'type': _type,
      'price_per_month': int.parse(_price.text),
      'distance_km': parseDecimal(_distance.text),
      'available_rooms': int.tryParse(_rooms.text) ?? 0,
      'address': emptyToNull(_address.text),
      'description': emptyToNull(_description.text),
      'facilities': splitFacilities(_facilities.text),
      'image_url': emptyToNull(_imageUrl.text),
      'owner_name': emptyToNull(_ownerName.text),
      'owner_phone': emptyToNull(_ownerPhone.text),
    };

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await ApiService.updateKos(widget.kos!.id, data); // PUT /api/kos/:id
      } else {
        await ApiService.createKos(data); // POST /api/kos
      }
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Data kos diperbarui' : 'Kos baru berhasil ditambahkan',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Kos' : 'Tambah Kos')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const FormSectionTitle('Informasi utama'),
            AppTextField(
              controller: _name,
              label: 'Nama kos',
              icon: Icons.home_work_outlined,
              required: true,
            ),
            AreaDropdown(
              value: _areaId,
              onChanged: (value) => setState(() => _areaId = value),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipe kos *',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'putra', child: Text('Putra')),
                  DropdownMenuItem(value: 'putri', child: Text('Putri')),
                  DropdownMenuItem(value: 'campur', child: Text('Campur')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
            ),
            AppTextField(
              controller: _price,
              label: 'Harga per bulan (Rp)',
              icon: Icons.payments_outlined,
              required: true,
              number: true,
              hint: 'Contoh: 950000',
            ),
            AppTextField(
              controller: _distance,
              label: 'Jarak ke kampus (km)',
              icon: Icons.directions_walk,
              decimal: true,
              hint: 'Contoh: 1.5',
            ),
            AppTextField(
              controller: _rooms,
              label: 'Jumlah kamar kosong',
              icon: Icons.meeting_room_outlined,
              number: true,
            ),
            const FormSectionTitle('Detail'),
            AppTextField(
              controller: _address,
              label: 'Alamat',
              icon: Icons.map_outlined,
            ),
            AppTextField(
              controller: _description,
              label: 'Deskripsi',
              icon: Icons.notes,
              maxLines: 3,
            ),
            AppTextField(
              controller: _facilities,
              label: 'Fasilitas',
              icon: Icons.checklist,
              hint: 'Pisahkan dengan koma: WiFi, AC, Kasur',
            ),
            AppTextField(
              controller: _imageUrl,
              label: 'URL foto',
              icon: Icons.image_outlined,
              keyboardType: TextInputType.url,
              hint: 'https://...',
            ),
            const FormSectionTitle('Pemilik'),
            AppTextField(
              controller: _ownerName,
              label: 'Nama pemilik',
              icon: Icons.person_outline,
            ),
            AppTextField(
              controller: _ownerPhone,
              label: 'Nomor WhatsApp pemilik',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: 'Contoh: 081234567890',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? null : const Icon(Icons.save_rounded),
              label: ButtonLabel(
                text: _isEdit ? 'Simpan perubahan' : 'Tambah kos',
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
