import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../../catalog/data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
 
  List<CartItemModel> get items => _items;
 
  // Tambah ke cart
  void addToCart(ProductModel product) {
    final index = _items.indexWhere((e) => e.id == product.id);
 
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(
        id: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
    }
 
    notifyListeners();
  }
 
  // Tambah quantity item yang sudah ada
  void increaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }
 
  // Kurangi quantity, hapus jika sudah 0
  void decreaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
 
  // Hapus item
  void removeFromCart(int id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
 
  // Total harga
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.total);
  }
 
  // Total jumlah item (qty)
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
 
  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}