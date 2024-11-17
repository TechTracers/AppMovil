import 'package:flutter/material.dart';
import 'package:lock_item/widgets/bottom_nav_bar.dart';
import 'package:lock_item/services/store_service.dart';
import 'package:lock_item/models/store.dart';
import 'package:lock_item/screens/catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Store> stores = [];
  bool isLoading = true;
  final StoreService _storeService = StoreService();

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final data = await _storeService.fetchStores();
      setState(() {
        stores = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return GestureDetector(
            onTap: () {
              // Navegar a la pantalla del catálogo al seleccionar una tienda
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CatalogScreen(
                    storeId: store.id, // Pasa el ID de la tienda
                    storeName: store.name, // Pasa el nombre de la tienda
                  ),
                ),
              );
            },
            child: _buildStoreCard(store.name, store.imageUrl),
          );
        },
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

  Widget _buildStoreCard(String storeName, String imageUrl) {
    return Column(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
