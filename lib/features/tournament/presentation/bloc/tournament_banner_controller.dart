import 'package:flutter/foundation.dart';
import 'package:nyxproject/features/tournament/domain/entities/tournament_banner.dart';
import 'package:nyxproject/features/tournament/domain/usecases/get_tournament_banners.dart';

class TournamentBannerController extends ChangeNotifier {
  TournamentBannerController(this._getTournamentBanners);

  final GetTournamentBanners _getTournamentBanners;

  List<TournamentBanner> banners = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      banners = await _getTournamentBanners();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
