import 'package:flutter/material.dart';
import 'package:lock_item/dto/DatabaseService.dart';
import 'package:lock_item/screens/home/product_details_screen.dart';
import 'package:lock_item/services/product_service.dart';
import 'package:lock_item/models/product.dart';
import 'package:lock_item/widgets/product_card.dart';

class SaveScreen extends StatefulWidget {
  @override
  _SaveScreenState createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  late Future<List<Product>> _favoriteProducts;

  @override
  void initState() {
    super.initState();
    _favoriteProducts = _loadFavoriteProducts();
  }

  Future<List<Product>> _loadFavoriteProducts() async {
    List<int> favoriteIds = await DatabaseService().getFavoriteProductIds();
    List<Product> products = [];
    for (int id in favoriteIds) {
      Product product = await ProductService().fetchProductById(id);
      products.add(product);
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Products"),
      ),
      body: FutureBuilder<List<Product>>(
        future: _favoriteProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorite products found."));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Product product = snapshot.data![index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  )),
                  child: ProductCard(product: product),
                );
              },
            );
          }
        },
      ),
    );
  }
}
