import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

/// Kolom isian kode OTP 6 digit.
class OtpField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const OtpField({super.key, required this.controller, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 12,
        color: AppColors.navy,
      ),
      decoration: const InputDecoration(hintText: '••••••', counterText: ''),
      validator: (value) =>
          (value == null || value.length != 6) ? 'Masukkan 6 digit kode' : null,
      onChanged: (value) {
        if (value.length == 6) onCompleted?.call(value);
      },
    );
  }
}

/// Tombol "Kirim ulang kode" dengan hitung mundur 60 detik.
class ResendOtpButton extends StatefulWidget {
  final Future<void> Function() onResend;

  const ResendOtpButton({super.key, required this.onResend});

  @override
  State<ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  static const int _cooldown = 60;
  int _secondsLeft = _cooldown;
  bool _sending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick(Timer timer) {
    if (_secondsLeft <= 1) timer.cancel();
    setState(() => _secondsLeft--);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await widget.onResend();
      messenger.showSnackBar(
        const SnackBar(content: Text('Kode OTP baru telah dikirim')),
      );
      _startTimer();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsLeft > 0) {
      return Text(
        'Kirim ulang kode dalam $_secondsLeft detik',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      );
    }
    return TextButton(
      onPressed: _sending ? null : _resend,
      child: Text(
        _sending ? 'Mengirim...' : 'Kirim ulang kode',
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Isi tombol utama: teks biasa atau indikator loading.
class ButtonLabel extends StatelessWidget {
  final String text;
  final bool loading;

  const ButtonLabel({super.key, required this.text, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (!loading) return Text(text);
    return const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}