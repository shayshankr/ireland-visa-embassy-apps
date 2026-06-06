import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../background_task.dart';

class WatchService {
  static Future<void> startWatching(String number, String embassyKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefWatchNumber, number);
    await prefs.setString(kPrefWatchEmbassy, embassyKey);

    await Workmanager().registerPeriodicTask(
      kWatchTaskName,
      kWatchTaskName,
      frequency: const Duration(hours: 12),
      initialDelay: const Duration(seconds: 30),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> stopWatching() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPrefWatchNumber);
    await prefs.remove(kPrefWatchEmbassy);
    await Workmanager().cancelByUniqueName(kWatchTaskName);
  }

  static Future<String?> getWatchedNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kPrefWatchNumber);
  }
}
