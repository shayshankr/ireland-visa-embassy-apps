import 'package:flutter/foundation.dart';
import '../config/embassy_config.dart';
import '../models/visa_result.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/notification_service.dart';
import '../services/watch_service.dart';

enum LoadState { idle, loading, success, error }

class EmbassyProvider extends ChangeNotifier {
  LoadState _statsState = LoadState.idle;
  LoadState _checkState = LoadState.idle;

  EmbassyStats? _stats;
  VisaCheckResult? _checkResult;
  String _error = '';

  String? _watchedNumber;
  List<String> _history = [];

  LoadState get statsState => _statsState;
  LoadState get checkState => _checkState;
  EmbassyStats? get stats => _stats;
  VisaCheckResult? get checkResult => _checkResult;
  String get error => _error;

  bool get isWatching => _watchedNumber != null;
  String? get watchedNumber => _watchedNumber;
  List<String> get history => _history;

  Future<void> loadStats() async {
    _statsState = LoadState.loading;
    notifyListeners();
    try {
      _stats = await ApiService.getStats();
      _statsState = LoadState.success;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _statsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> checkApplication(String applicationNumber) async {
    _checkState = LoadState.loading;
    _checkResult = null;
    _error = '';
    notifyListeners();
    try {
      _checkResult = await ApiService.checkApplication(applicationNumber);
      _checkState = LoadState.success;
      await HistoryService.add(applicationNumber);
      _history = await HistoryService.getHistory();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _checkState = LoadState.error;
    }
    notifyListeners();
  }

  void resetCheck() {
    _checkState = LoadState.idle;
    _checkResult = null;
    _error = '';
    notifyListeners();
  }

  Future<void> loadWatchState() async {
    _watchedNumber = await WatchService.getWatchedNumber();
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _history = await HistoryService.getHistory();
    notifyListeners();
  }

  Future<bool> startWatching(String number) async {
    await NotificationService.init();
    final granted = await NotificationService.requestPermission();
    if (!granted) return false;

    await WatchService.startWatching(number, EmbassyConfig.current.key);
    _watchedNumber = number;
    notifyListeners();
    return true;
  }

  Future<void> stopWatching() async {
    await WatchService.stopWatching();
    _watchedNumber = null;
    notifyListeners();
  }
}
