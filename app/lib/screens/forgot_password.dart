import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widget/auth_header.dart';
import '../widget/otp_widgets.dart';

/// Lupa password: (1) isi email -> kode OTP dikirim,
/// (2) isi kode OTP + password baru.
class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false; // false = langkah 1, true = langkah 2
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  // Langkah 1: minta kode OTP
  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await AuthService.instance.forgotPassword(_email);
      setState(() => _codeSent = true);
      messenger.showSnackBar(
        SnackBar(content: Text('Kode OTP telah dikirim ke $_email')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Langkah 2: simpan password baru
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await AuthService.instance.resetPassword(
        _email,
        _codeController.text,
        _passwordController.text,
      );
      navigator.pop(); // kembali ke halaman Login
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah, silakan masuk'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
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
            AuthHeader(
              title: 'Lupa password',
              subtitle: _codeSent
                  ? 'Masukkan kode OTP dan password barumu'
                  : 'Kami akan mengirim kode OTP ke emailmu',
              showBack: true,
            ),
            AuthFormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _codeSent ? _stepTwo() : _stepOne(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _stepOne() {
    return [
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email akun',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Email wajib diisi';
          }
          if (!value.contains('@')) return 'Format email tidak valid';
          return null;
        },
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: _loading ? null : _sendCode,
        child: ButtonLabel(text: 'Kirim kode OTP', loading: _loading),
      ),
    ];
  }

  List<Widget> _stepTwo() {
    return [
      Text.rich(
        TextSpan(
          text: 'Kode dikirim ke ',
          children: [
            TextSpan(
              text: _email,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
      const SizedBox(height: 16),
      OtpField(controller: _codeController),
      const SizedBox(height: 14),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Password baru (minimal 6 karakter)',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
          labelText: 'Ulangi password baru',
          prefixIcon: Icon(Icons.lock_outline),
        ),
        validator: (value) =>
            value != _passwordController.text ? 'Password tidak sama' : null,
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: _loading ? null : _resetPassword,
        child: ButtonLabel(text: 'Simpan password baru', loading: _loading),
      ),
      const SizedBox(height: 12),
      ResendOtpButton(
        onResend: () => AuthService.instance.resendOtp(_email, 'reset'),
      ),
      TextButton(
        onPressed: () => setState(() {
          _codeSent = false;
          _codeController.clear();
        }),
        child: const Text('Ganti email'),
      ),
    ];
  }
}