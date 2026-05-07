import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/embassy_config.dart';
import '../models/visa_result.dart';

class ApiService {
  static const String baseUrl =
      'https://shayshankrathore-ireland-visa-api.hf.space';

  static Future<EmbassyStats> getStats() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/embassies'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final embassy = data.firstWhere(
        (e) => (e['name'] as String) == EmbassyConfig.current.key,
        orElse: () => null,
      );
      if (embassy != null) {
        return EmbassyStats(
          recordCount: embassy['record_count'] as int,
          available: embassy['available'] as bool,
          cadence: embassy['cadence'] as String,
        );
      }
    }
    throw Exception('Failed to load embassy data');
  }

  static Future<VisaCheckResult> checkApplication(
      String applicationNumber) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/check'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'application_number': applicationNumber}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 400) {
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(error['detail'] ?? 'Invalid application number');
    }
    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final embassyName = EmbassyConfig.current.key;

    // Filter results to only this embassy
    final results = (json['results'] as List<dynamic>)
        .where((r) => (r['embassy'] as String) == embassyName)
        .toList();

    if (results.isNotEmpty) {
      final row = results.first as Map<String, dynamic>;
      return VisaCheckResult(
        applicationNumber: json['application_number'] as String,
        found: true,
        decision: row['decision'] as String,
        source: row['source'] as String,
      );
    }

    // Not found — extract nearest
    final nearest = json['nearest'] as Map<String, dynamic>?;
    return VisaCheckResult(
      applicationNumber: json['application_number'] as String,
      found: false,
      before: nearest?['before'] != null
          ? NearestResult.fromJson(nearest!['before'])
          : null,
      after: nearest?['after'] != null
          ? NearestResult.fromJson(nearest!['after'])
          : null,
    );
  }
}
