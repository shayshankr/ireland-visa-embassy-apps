import 'package:flutter/material.dart';

class EmbassyConfig {
  final String key;
  final String name;
  final String subtitle;
  final Color primaryColor;
  final String url;

  const EmbassyConfig({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.primaryColor,
    required this.url,
  });

  static const newdelhi = EmbassyConfig(
    key: 'New Delhi',
    name: 'New Delhi',
    subtitle: 'Ireland Embassy - India',
    primaryColor: Color(0xFF169B62),
    url: 'https://www.ireland.ie/en/india/newdelhi/services/visas/visa-decisions/',
  );

  static const beijing = EmbassyConfig(
    key: 'Beijing',
    name: 'Beijing',
    subtitle: 'Ireland Embassy - China',
    primaryColor: Color(0xFFB22222),
    url: 'https://www.ireland.ie/en/china/beijing/services/visas/visa-decisions/',
  );

  static const abuja = EmbassyConfig(
    key: 'Abuja',
    name: 'Abuja',
    subtitle: 'Ireland Embassy - Nigeria',
    primaryColor: Color(0xFF008751),
    url: 'https://www.ireland.ie/en/nigeria/abuja/services/visas/visa-decisions/',
  );

  static const abudhabi = EmbassyConfig(
    key: 'Abu Dhabi',
    name: 'Abu Dhabi',
    subtitle: 'Ireland Embassy - UAE',
    primaryColor: Color(0xFF007A3D),
    url: 'https://www.ireland.ie/en/uae/abudhabi/services/visas/visa-decisions/',
  );

  static const ankara = EmbassyConfig(
    key: 'Ankara',
    name: 'Ankara',
    subtitle: 'Ireland Embassy - Turkiye',
    primaryColor: Color(0xFFE30A17),
    url: 'https://www.ireland.ie/en/turkey/ankara/services/visas/visa-decisions/',
  );

  // Set once at startup by each flavor's main_xxx.dart
  static EmbassyConfig _current = newdelhi;
  static EmbassyConfig get current => _current;
  static void setConfig(EmbassyConfig config) {
    _current = config;
  }
}
