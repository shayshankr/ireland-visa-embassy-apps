import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'config/embassy_config.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

const String kWatchTaskName = 'visa_watch_task';
const String kPrefWatchNumber = 'watch_number';
const String kPrefWatchEmbassy = 'watch_embassy';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString(kPrefWatchNumber);
    final embassyKey = prefs.getString(kPrefWatchEmbassy);

    if (number == null || embassyKey == null) return true;

    // Background isolate starts with default config — must set it from storage.
    EmbassyConfig.setConfig(EmbassyConfig.fromKey(embassyKey));
    await NotificationService.init();

    try {
      final result = await ApiService.checkApplication(number);
      if (result.found) {
        await NotificationService.showDecisionNotification(
          number: number,
          decision: result.decision ?? 'Decision received',
          isApproved: result.isApproved,
        );
        // Decision found — clear watch so we stop polling.
        await prefs.remove(kPrefWatchNumber);
        await prefs.remove(kPrefWatchEmbassy);
        await Workmanager().cancelByUniqueName(kWatchTaskName);
      }
    } catch (_) {
      // Network or server error — will retry on next interval.
    }
    return true;
  });
}
