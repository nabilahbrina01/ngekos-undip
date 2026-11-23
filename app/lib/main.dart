import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';
import 'utils/app_theme.dart';
import 'widget/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat sesi login dan daftar favorit yang tersimpan di HP
  await AuthService.instance.load();
  await FavoriteService.instance.load();
  runApp(const NgekosUndipApp());
}

class NgekosUndipApp extends StatelessWidget {
  const NgekosUndipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgekosUndip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // tema navy + emas (utils/app_theme.dart)
      // Sudah login -> halaman utama, belum login -> halaman Login.
      // ListenableBuilder otomatis berpindah saat login/logout.
      home: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) => AuthService.instance.isLoggedIn
            ? const NavigationPage()
            : const LoginPage(),
      ),
    );
  }
}