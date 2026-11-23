import 'package:flutter/material.dart';

import 'services/favorite_service.dart';
import 'widget/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat daftar favorit yang tersimpan di HP sebelum aplikasi tampil
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4F8C)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const NavigationPage(),
    );
  }
}