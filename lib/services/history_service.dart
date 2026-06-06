import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _key = 'search_history';
  static const _maxItems = 5;

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> add(String number) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(number);
    list.insert(0, number);
    if (list.length > _maxItems) list.removeRange(_maxItems, list.length);
    await prefs.setStringList(_key, list);
  }
}
