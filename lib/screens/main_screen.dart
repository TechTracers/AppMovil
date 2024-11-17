import 'package:flutter/material.dart';
import 'package:lock_item/screens/Saved/save_screen.dart';
import 'package:lock_item/screens/search/search_screen.dart';

import '../widgets/bottom_nav_bar.dart';
import 'Account/account_screen.dart';
import 'home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Índice del BottomNavBar

  // Lista de pantallas para cada índice del BottomNavBar
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const SaveScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Actualiza el índice seleccionado
          });
        },
      ),
    );
  }
}
