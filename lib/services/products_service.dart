import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-app-prductes-5f143-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPicture;

  bool isloading = true;
  bool isSAving = false;
  ProductsService() {
    this.loadProducts();
  }
  Future loadProducts() async {
    isloading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    isloading = false;
    notifyListeners();
  }

  Future saveOrCreateProduct(Product product) async {
    isSAving = true;
    notifyListeners();

    if (product.id == null) {
      await createProduct(product);
    } else {
      //actualizamos
      await updateProduct(product);
    }
    isSAving = false;
    notifyListeners();
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);
    product.id = decodedData['name'];
    this.products.add(product);
    return product.id!;
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;
    print(decodedData);
    //Todo actualizar la lista local de productos
    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;
    return product.id!;
  }

  void updateSelectedImage(String path) {
    this.newPicture = File.fromUri(Uri(path: path));
    this.selectedProduct.picture = path;

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPicture == null) return null;
    this.isSAving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dmhywfzou/image/upload?upload_preset=frhlhbbq');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', newPicture!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('hi ha un error!');
      print(resp.body);
      return null;
    }
    this.newPicture = null;

    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];
  }
}
