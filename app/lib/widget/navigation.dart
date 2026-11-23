import 'package:flutter/material.dart';

import '../screens/favorite.dart';
import '../screens/home.dart';
import '../screens/kontrakan_list.dart';
import '../screens/kos_list.dart';
import '../screens/profile.dart';
import '../utils/app_theme.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onNavigate: _onTabTapped),
      const KosListPage(),
      const KontrakanListPage(),
      const FavoritePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      // IndexedStack menjaga halaman tetap "hidup" (data tidak di-load ulang
      // setiap pindah tab)
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed, // wajib jika item > 3
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.navy,
            unselectedItemColor: const Color(0xFF9AA3B2),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            items: [
              _item(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              _item(Icons.bed_outlined, Icons.bed_rounded, 'Kos'),
              _item(Icons.house_outlined, Icons.house_rounded, 'Kontrakan'),
              _item(Icons.favorite_border, Icons.favorite_rounded, 'Favorit'),
              _item(Icons.person_outline, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  /// Item bottom nav: ikon aktif diberi latar emas lembut.
  BottomNavigationBarItem _item(IconData icon, IconData active, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(active),
      ),
      label: label,
    );
  }
}