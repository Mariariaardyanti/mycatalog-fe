import 'package:flutter/material.dart';
import 'package:shopping_app/core/service/dio_client.dart';
import 'package:shopping_app/features/catalog/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  ProductStatus _status = ProductStatus.initial;
  String? _error;

  List<ProductModel> get products => _products;
  ProductStatus get status => _status;
  String? get error => _error;

  bool get isLoading => _status == ProductStatus.loading;

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      final response = await DioClient.instance.get('/products');

      final List data = response.data['data'];

      _products = data
          .map((json) => ProductModel.fromJson(json))
          .toList();

      _status = ProductStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = ProductStatus.error;
    }

    notifyListeners();
  }
}