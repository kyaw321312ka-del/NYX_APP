import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  
  void addToCart(Product product, {int quantity = 1}) {
    final stock = int.tryParse(product.totalStock.trim());
    if (quantity <= 0 || (stock != null && stock <= 0)) {
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    final currentQuantity = existingIndex == -1 ? 0 : _items[existingIndex].quantity;
    final allowedQuantity = stock == null
        ? quantity
        : (stock - currentQuantity).clamp(0, quantity);
    if (allowedQuantity == 0) {
      return;
    }

    if (existingIndex != -1) {
      _items[existingIndex].quantity += allowedQuantity;
    } else {
      _items.add(CartItem(product: product, quantity: allowedQuantity));
    }
    
    notifyListeners();
  }
  
  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }
  
  void updateQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final stock = int.tryParse(_items[index].product.totalStock.trim());
        _items[index].quantity = stock == null ? quantity : quantity.clamp(1, stock);
      }
      notifyListeners();
    }
  }
  
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, required this.quantity});
}