import 'package:flutter/material.dart';
import 'package:lock_item/screens/home/product_details_screen.dart';
import 'package:lock_item/services/product_service.dart';

import '../../models/product.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/category_service.dart';

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
  int _currentIndex = 0; // Control del índice del BottomNavBar

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
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                      return GestureDetector(
                        onTap: () {
                          // Navegar a los detalles del producto
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                        child: ProductCard(product: product),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      /**bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Implementar navegación en el BottomNavBar
        },
      ),**/
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

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Nombre del producto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Precio del producto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${product.price}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}