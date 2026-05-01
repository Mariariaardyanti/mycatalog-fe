import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../../catalog/data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  final Set<int> _selectedIds = {}; 

  List<CartItemModel> get items => _items;
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);

  List<CartItemModel> get selectedItems =>
      _items.where((e) => _selectedIds.contains(e.id)).toList();

  bool get isAllSelected =>
      _items.isNotEmpty && _selectedIds.length == _items.length;

  bool isSelected(int id) => _selectedIds.contains(id);


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
        category: product.category,
      ));
    }

    notifyListeners();
  }

  void increaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
        _selectedIds.remove(id); 
      }
      notifyListeners();
    }
  }

  void removeFromCart(int id) {
    _items.removeWhere((e) => e.id == id);
    _selectedIds.remove(id); 
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedIds.clear(); 
    notifyListeners();
  }


  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.total);

  double get selectedTotalPrice =>
      selectedItems.fold(0, (sum, item) => sum + item.total);

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);


  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_items.map((e) => e.id));
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  void removeSelectedItems() {
    _items.removeWhere((e) => _selectedIds.contains(e.id));
    _selectedIds.clear();
    notifyListeners();
  }
}