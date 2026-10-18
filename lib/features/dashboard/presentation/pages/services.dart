import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/presentation/bloc/services_controller.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/canteen_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/rentals_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/tab_widget.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/trainings_widget.dart';
import 'package:provider/provider.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ServicesController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesController>(
      builder: (context, controller, _) {
        final size = MediaQuery.sizeOf(context);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFF0D1B2A),
            backgroundColor: Colors.white,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 20),
                    Offstage(
                      offstage: _selectedIndex != 0,
                      child: TrainingsWidget(
                        trainings: controller.trainings.items,
                        isLoading:
                            controller.trainings.isLoading &&
                            !controller.isRefreshing,
                        error: controller.trainings.error,
                        onRetry: controller.loadTrainings,
                      ),
                    ),
                    Offstage(
                      offstage: _selectedIndex != 1,
                      child: RentalsWidget(
                        screenWidth: size.width,
                        screenHeight: size.height,
                        venues: controller.venues.items,
                        isLoadingVenues:
                            controller.venues.isLoading &&
                            !controller.isRefreshing,
                        venuesError: controller.venues.error,
                        onRetryVenues: controller.loadVenues,
                      ),
                    ),
                    Offstage(
                      offstage: _selectedIndex != 2,
                      child: CanteenWidget(
                        items: controller.canteen.items,
                        screenWidth: size.width,
                        screenHeight: size.height,
                        isLoading:
                            controller.canteen.isLoading &&
                            !controller.isRefreshing,
                        error: controller.canteen.error,
                        onRetry: controller.loadCanteenItems,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab('TRAININGS', 0),
          _buildTab('RENTALS', 1),
          _buildTab('CANTEEN', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: TabWidget(
        title: title,
        index: index,
        selectedIndex: _selectedIndex,
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }
}
