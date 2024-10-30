import 'package:flutter/material.dart';
import 'package:lock_item/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const Center(child: Text('Search')),
    const Center(child: Text('Saved')),
    const Center(child: Text('Account')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStoreCard('Ripley', 'assets/branch/ripley.png'),
          _buildStoreCard('Saga Falabella', 'assets/branch/falabella.png'),
          _buildStoreCard('Topitop', 'assets/branch/topitop.png'),
          _buildStoreCard('Oeschle', 'assets/branch/oeschle.png'),
          _buildStoreCard('H&M', 'assets/branch/h&m.png'),
          _buildStoreCard('Estilos', 'assets/branch/estilos.png'),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStoreCard(String storeName, String assetPath) {
    return Column(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(assetPath),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
