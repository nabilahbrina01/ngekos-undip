import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widget/auth_header.dart';
import 'otp_verification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String _role = 'pencari'; // pencari atau pemilik

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      await AuthService.instance.register(
        _nameController.text.trim(),
        email,
        _passwordController.text,
        _role,
      );
      // Berhasil daftar = kode OTP dikirim. Ganti halaman ini dengan
      // halaman verifikasi OTP.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'Buat akun baru',
              subtitle: 'Daftar untuk menyimpan kos & kontrakan favoritmu',
              showBack: true,
            ),
            AuthFormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Daftar sebagai',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'pencari',
                          icon: Icon(Icons.search_rounded),
                          label: Text('Pencari kos'),
                        ),
                        ButtonSegment(
                          value: 'pemilik',
                          icon: Icon(Icons.storefront_rounded),
                          label: Text('Pemilik kos'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (value) =>
                          setState(() => _role = value.first),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _role == 'pemilik'
                          ? 'Bisa memasang, mengubah, dan menghapus iklan kos/kontrakan milik sendiri.'
                          : 'Bisa mencari kos/kontrakan dan menyimpan favorit.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password (minimal 6 karakter)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: const InputDecoration(
                        labelText: 'Ulangi password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Password tidak sama'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Daftar'),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Sudah punya akun? Masuk',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
