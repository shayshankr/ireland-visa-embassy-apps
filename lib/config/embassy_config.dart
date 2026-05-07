import 'package:flutter/material.dart';

// Set at build time: --dart-define=EMBASSY_KEY=newdelhi
const _key = String.fromEnvironment('EMBASSY_KEY', defaultValue: 'newdelhi');

class EmbassyConfig {
  final String key;
  final String name;
  final String subtitle;
  final Color primaryColor;

  const EmbassyConfig({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.primaryColor,
  });

  static const newdelhi = EmbassyConfig(
    key: 'New Delhi',
    name: 'New Delhi',
    subtitle: 'Ireland Embassy — India',
    primaryColor: Color(0xFF169B62),
  );

  static const beijing = EmbassyConfig(
    key: 'Beijing',
    name: 'Beijing',
    subtitle: 'Ireland Embassy — China',
    primaryColor: Color(0xFFB22222),
  );

  static const abuja = EmbassyConfig(
    key: 'Abuja',
    name: 'Abuja',
    subtitle: 'Ireland Embassy — Nigeria',
    primaryColor: Color(0xFF008751),
  );

  static const abudhabi = EmbassyConfig(
    key: 'Abu Dhabi',
    name: 'Abu Dhabi',
    subtitle: 'Ireland Embassy — UAE',
    primaryColor: Color(0xFF007A3D),
  );

  static const ankara = EmbassyConfig(
    key: 'Ankara',
    name: 'Ankara',
    subtitle: 'Ireland Embassy — Türkiye',
    primaryColor: Color(0xFFE30A17),
  );

  static const _all = {
    'newdelhi': newdelhi,
    'beijing': beijing,
    'abuja': abuja,
    'abudhabi': abudhabi,
    'ankara': ankara,
  };

  static EmbassyConfig get current => _all[_key] ?? newdelhi;
}
