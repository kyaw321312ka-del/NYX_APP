import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/core/utils/app_theme.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/dashboard/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionService = SessionService();
  await sessionService.init();

  final cartService = CartService();

  runApp(MyApp(sessionService: sessionService, cartService: cartService));
}

class MyApp extends StatelessWidget {
  final SessionService sessionService;
  final CartService cartService;

  const MyApp({
    super.key,
    required this.sessionService,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionService>.value(value: sessionService),
        ChangeNotifierProvider<CartService>.value(value: cartService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nyx Project',
        theme: AppTheme.light,
        home: SplashScreen(
          //  Show splash screen first
          sessionService: sessionService,
          cartService: cartService,
        ),
      ),
    );
  }
}
