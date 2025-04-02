import 'package:flutter/material.dart';
import 'package:productes_app/models/products.dart';
import 'package:productes_app/screens/loading_screen.dart';
import 'package:productes_app/services/services.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    if (productsService.isloading) return LoadingScreen();
    return Scaffold(
      appBar: AppBar(
        title: Text('Productes'),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          child: ProductCard(
            product: productsService.products[index],
          ),
          onTap: () {
            productsService.newPicture = null;
            productsService.selectedProduct =
                productsService.products[index].copy();
            Navigator.of(context).pushNamed('product');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productsService.newPicture = null;
          productsService.selectedProduct =
              Product(available: true, name: '', price: 0);
          Navigator.of(context).pushNamed('product');
        },
      ),
    );
  }
}
