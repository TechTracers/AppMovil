import 'package:flutter/material.dart';
import 'package:lock_item/screens/home/product_details_screen.dart';
import 'package:lock_item/services/product_service.dart';
import 'package:lock_item/services/store_service.dart';

import '../../models/product.dart';
import '../../services/category_service.dart';
import 'package:logger/logger.dart';

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
  final StoreService storeService = StoreService();
  final Logger _logger = Logger();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  int? selectedCategory; // Variable para la categoría seleccionada
  bool isLoadingProducts = true;
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchStoreProducts();
    fetchCategories();
  }

  Future<void> fetchStoreProducts() async {
  try {
    final products = await storeService.fetchProducts(widget.storeId);
    print('Productos recibidos: $products'); // Debug
    setState(() {
      allProducts = products;
      filteredProducts = products; // Inicialmente muestra todos los productos
      isLoadingProducts = false;
    });
  } catch (e) {
    print('Error al obtener productos: $e'); // Debug
    setState(() {
      isLoadingProducts = false;
    });
  }
}


  Future<void> fetchCategories() async {
  try {
    final categoryData = await categoryService.fetchCategories();
    print('Categorías recibidas: $categoryData'); // Debug
    setState(() {
      categories = categoryData;
      isLoadingCategories = false;
    });
  } catch (e) {
    print('Error al obtener categorías: $e'); // Debug
    setState(() {
      isLoadingCategories = false;
    });
  }
}


  void filterByCategory(int? categoryId) {
  print('Filtrando por categoría: $categoryId'); // Debug
  setState(() {
    selectedCategory = categoryId;
    if (categoryId == null) {
      filteredProducts = allProducts; // Mostrar todos los productos si no hay categoría seleccionada
      print('Mostrando todos los productos: $filteredProducts'); // Debug
    } else {
      filteredProducts = allProducts
          .where((product) => product.categoryId == categoryId)
          .toList();
      print('Productos filtrados: $filteredProducts'); // Debug
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
          isLoadingCategories
              ? const SizedBox(
            height: 50,
            //child: Center(child: CircularProgressIndicator()),
          )
              : categories.isEmpty
              ? const SizedBox(
            height: 50,
            child: Center(child: Text('No categories available')),
          )
              : Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1, // +1 para el botón "All"
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
          ),
          // Lista de productos filtrados
          Expanded(
            child: isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? const Center(child: Text('No products available.'))
                : GridView.builder(
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
                print('Mostrando producto en la lista: ${product.name}'); // Debug
                return GestureDetector(
                  onTap: () {
                    // Navegar a los detalles del producto
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: ProductCard(product: product),
                );
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
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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
    super.key,
    required this.product,
  });

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
