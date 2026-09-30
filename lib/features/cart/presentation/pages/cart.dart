// lib/pages/cart.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/cart/presentation/widgets/cartWidgets/cart_header.dart';
import 'package:nyxproject/features/cart/presentation/widgets/cartWidgets/cart_item_card.dart';
import 'package:nyxproject/features/cart/presentation/widgets/cartWidgets/cart_summary.dart';
import 'package:nyxproject/features/cart/presentation/widgets/cartWidgets/empty_cart.dart';
import 'package:nyxproject/features/cart/presentation/widgets/cartWidgets/login_dialog.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/contactInfo.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final session = Provider.of<SessionService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CartHeader(),
            Expanded(
              child: cart.items.isEmpty
                  ? const EmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return CartItemCard(
                          item: item,
                          onDelete: () => cart.removeFromCart(item.product),
                          onIncrease: () => cart.updateQuantity(item.product, item.quantity + 1),
                          onDecrease: () {
                            if (item.quantity > 1) {
                              cart.updateQuantity(item.product, item.quantity - 1);
                            }
                          },
                        );
                      },
                    ),
            ),
            if (cart.items.isNotEmpty)
              CartSummary(
                subtotal: cart.totalPrice,
                deliveryFee: 0,
                isCartEmpty: cart.items.isEmpty,
                onAddMoreItems: () => Navigator.pop(context),
                onOrderConfirm: () => _checkLoginAndNavigate(context, session),
              ),
          ],
        ),
      ),
    );
  }

  void _checkLoginAndNavigate(BuildContext context, SessionService session) {
    // Check if user is logged in and token is valid
    if (session.isLoggedIn() && !session.isTokenExpired() && session.getToken() != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const contactInfo(),
        ),
      );
    } else {
      LoginDialog.show(context: context, session: session);
    }
  }
}