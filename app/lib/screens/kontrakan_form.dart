import 'package:flutter/material.dart';

import '../models/kontrakan.dart';
import '../services/api_service.dart';
import '../widget/form_widgets.dart';
import '../widget/otp_widgets.dart';

/// Form tambah kontrakan (kontrakan == null) atau ubah kontrakan.
/// Mengembalikan true ke halaman sebelumnya jika data berhasil disimpan.
class KontrakanFormPage extends StatefulWidget {
  final Kontrakan? kontrakan;

  const KontrakanFormPage({super.key, this.kontrakan});

  @override
  State<KontrakanFormPage> createState() => _KontrakanFormPageState();
}

class _KontrakanFormPageState extends State<KontrakanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _distance;
  late final TextEditingController _bedrooms;
  late final TextEditingController _bathrooms;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late final TextEditingController _facilities;
  late final TextEditingController _imageUrl;
  late final TextEditingController _ownerName;
  late final TextEditingController _ownerPhone;
  String? _areaId;
  bool _isAvailable = true;
  bool _saving = false;

  bool get _isEdit => widget.kontrakan != null;

  @override
  void initState() {
    super.initState();
    final item = widget.kontrakan; // null saat tambah data baru
    _name = TextEditingController(text: item?.name ?? '');
    _price = TextEditingController(text: item?.pricePerYear.toString() ?? '');
    _distance = TextEditingController(text: item?.distanceKm?.toString() ?? '');
    _bedrooms = TextEditingController(text: item?.bedrooms.toString() ?? '');
    _bathrooms = TextEditingController(text: item?.bathrooms.toString() ?? '');
    _address = TextEditingController(text: item?.address ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _facilities = TextEditingController(
      text: item?.facilities.join(', ') ?? '',
    );
    _imageUrl = TextEditingController(text: item?.imageUrl ?? '');
    _ownerName = TextEditingController(text: item?.ownerName ?? '');
    _ownerPhone = TextEditingController(text: item?.ownerPhone ?? '');
    _areaId = item?.areaId;
    _isAvailable = item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _price,
      _distance,
      _bedrooms,
      _bathrooms,
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

    // Nama kolom harus sama dengan kolom tabel "kontrakan" di Supabase
    final data = {
      'name': _name.text.trim(),
      'area_id': _areaId,
      'price_per_year': int.parse(_price.text),
      'bedrooms': int.tryParse(_bedrooms.text) ?? 1,
      'bathrooms': int.tryParse(_bathrooms.text) ?? 1,
      'distance_km': parseDecimal(_distance.text),
      'is_available': _isAvailable,
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
        // PUT /api/kontrakan/:id
        await ApiService.updateKontrakan(widget.kontrakan!.id, data);
      } else {
        await ApiService.createKontrakan(data); // POST /api/kontrakan
      }
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Data kontrakan diperbarui'
                : 'Kontrakan baru berhasil ditambahkan',
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
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Kontrakan' : 'Tambah Kontrakan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const FormSectionTitle('Informasi utama'),
            AppTextField(
              controller: _name,
              label: 'Nama kontrakan',
              icon: Icons.home_work_outlined,
              required: true,
            ),
            AreaDropdown(
              value: _areaId,
              onChanged: (value) => setState(() => _areaId = value),
            ),
            AppTextField(
              controller: _price,
              label: 'Harga per tahun (Rp)',
              icon: Icons.payments_outlined,
              required: true,
              number: true,
              hint: 'Contoh: 20000000',
            ),
            AppTextField(
              controller: _distance,
              label: 'Jarak ke kampus (km)',
              icon: Icons.directions_walk,
              decimal: true,
              hint: 'Contoh: 1.5',
            ),
            AppTextField(
              controller: _bedrooms,
              label: 'Jumlah kamar tidur',
              icon: Icons.bed_outlined,
              number: true,
            ),
            AppTextField(
              controller: _bathrooms,
              label: 'Jumlah kamar mandi',
              icon: Icons.bathtub_outlined,
              number: true,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('Masih tersedia'),
              subtitle: Text(
                _isAvailable
                    ? 'Tampil sebagai "Tersedia"'
                    : 'Tampil sebagai "Sudah penuh"',
              ),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
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
                text: _isEdit ? 'Simpan perubahan' : 'Tambah kontrakan',
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
