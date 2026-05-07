import 'package:flutter/foundation.dart';
import '../models/visa_result.dart';
import '../services/api_service.dart';

enum LoadState { idle, loading, success, error }

class EmbassyProvider extends ChangeNotifier {
  LoadState _statsState = LoadState.idle;
  LoadState _checkState = LoadState.idle;

  EmbassyStats? _stats;
  VisaCheckResult? _checkResult;
  String _error = '';

  LoadState get statsState => _statsState;
  LoadState get checkState => _checkState;
  EmbassyStats? get stats => _stats;
  VisaCheckResult? get checkResult => _checkResult;
  String get error => _error;

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
}
