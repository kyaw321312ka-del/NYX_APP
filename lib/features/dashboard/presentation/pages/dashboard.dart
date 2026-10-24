import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_banners.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_categories.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_dashboard_products.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/dashboardWidgets/dashboard_content.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';

class DashBoard extends StatelessWidget {
  final SessionService? sessionService;
  final CartService? cartService;

  const DashBoard({super.key, this.sessionService, this.cartService});

  @override
  Widget build(BuildContext context) {
    final repository = DashboardRepositoryImpl();
    return BlocProvider(
      create: (_) => DashboardCubit(
        getBanners: GetBanners(repository),
        getCategories: GetDashboardCategories(repository),
        getProducts: GetDashboardProducts(repository),
      )..loadAll(),
      child: const DashboardContent(),
    );
  }
}
