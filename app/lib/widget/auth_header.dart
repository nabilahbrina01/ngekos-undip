import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Header bergradasi untuk halaman Login dan Daftar.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 16,
        24,
        72,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            )
          else
            const SizedBox(height: 8),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: AppColors.navy,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu putih untuk membungkus form, dinaikkan sedikit menutupi header.
class AuthFormCard extends StatelessWidget {
  final Widget child;
  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -44),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: child,
      ),
    );
  }
}