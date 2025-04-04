import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product tempProduct;

  ProductFormProvider(this.tempProduct);

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  updateAvaliability(bool value) {
    print(value);
    this.tempProduct.available = value;
    notifyListeners();
  }
}
