import 'package:flutter/material.dart';
import 'package:lock_item/services/product_service.dart';

import '../models/product.dart';
import 'category_service.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.storeId, required this.storeName});

  final int storeId;
  final String storeName;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService productService = ProductService();
  final CategoryService categoryService = CategoryService();
  late Future<List<Product>> products;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  int? selectedCategory; // Variable para la categoría seleccionada

  @override
  void initState() {
    super.initState();
    products = productService.fetchStoreProducts(widget.storeId);
    products.then((data) {
      setState(() {
        allProducts = data;
        filteredProducts = data; // Inicialmente muestra todos los productos
      });
    });
  }

  // Método para obtener categorías desde la API
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await categoryService.fetchCategories();
  }

  void filterByCategory(int? categoryId) {
    setState(() {
      selectedCategory = categoryId;
      if (categoryId == null) {
        filteredProducts = allProducts; // Mostrar todos los productos si no hay categoría seleccionada
      } else {
        filteredProducts = allProducts
            .where((product) => product.categoryId == categoryId)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
      ),
      body: Column(
        children: [
          // Botones de filtrado de categorías
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: Text('Error al cargar categorías')),
                );
              } else {
                final categories = snapshot.data!;
                return Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1, // +1 para el botón "Todos"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryButton(
                          label: 'All',
                          isSelected: selectedCategory == null,
                          onTap: () => filterByCategory(null),
                        );
                      } else {
                        final category = categories[index - 1];
                        return CategoryButton(
                          label: category['name'],
                          isSelected: selectedCategory == category['id'],
                          onTap: () => filterByCategory(category['id']),
                        );
                      }
                    },
                  ),
                );
              }
            },
          ),
          // Lista de productos filtrados
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products available.'));
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        elevation: 3,
                        child: Column(
                          children: [
                            Image.network(
                              product.imageUrl,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para botones de categoría
class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}