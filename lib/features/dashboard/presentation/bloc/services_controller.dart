import 'package:flutter/foundation.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/features/dashboard/domain/usecases/get_services_data.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';

@immutable
class ServicesSectionState<T> {
  const ServicesSectionState({
    this.items = const [],
    this.isLoading = true,
    this.error,
  });

  final List<T> items;
  final bool isLoading;
  final String? error;
}

class ServicesController extends ChangeNotifier {
  ServicesController(this._getServicesData);

  final GetServicesData _getServicesData;

  ServicesSectionState<Training> trainings =
      const ServicesSectionState<Training>();
  ServicesSectionState<Venue> venues = const ServicesSectionState<Venue>();
  ServicesSectionState<Canteen> canteen =
      const ServicesSectionState<Canteen>();
  bool isRefreshing = false;

  Future<void> loadAll() async {
    await Future.wait<void>([
      loadTrainings(),
      loadVenues(),
      loadCanteenItems(),
    ]);
  }

  Future<void> refresh() async {
    if (isRefreshing) return;

    isRefreshing = true;
    notifyListeners();
    try {
      await loadAll();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadTrainings() => _load(
    fetch: _getServicesData.getTrainings,
    current: trainings,
    update: (state) => trainings = state,
  );

  Future<void> loadVenues() => _load(
    fetch: _getServicesData.getVenues,
    current: venues,
    update: (state) => venues = state,
  );

  Future<void> loadCanteenItems() => _load(
    fetch: _getServicesData.getCanteenItems,
    current: canteen,
    update: (state) => canteen = state,
  );

  Future<void> _load<T>({
    required Future<List<T>> Function() fetch,
    required ServicesSectionState<T> current,
    required void Function(ServicesSectionState<T>) update,
  }) async {
    update(
      ServicesSectionState<T>(
        items: current.items,
        isLoading: !isRefreshing,
      ),
    );
    notifyListeners();

    try {
      update(ServicesSectionState<T>(items: await fetch(), isLoading: false));
    } catch (error) {
      update(
        ServicesSectionState<T>(
          items: current.items,
          isLoading: false,
          error: AppErrorMessage.from(error),
        ),
      );
    }
    notifyListeners();
  }
}
