import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'background_task.dart';
import 'config/embassy_config.dart';
import 'providers/embassy_provider.dart';
import 'screens/embassy_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect the correct embassy from this APK's package name so the app
  // always loads the right config regardless of which build tool invoked it.
  final info = await PackageInfo.fromPlatform();
  EmbassyConfig.setConfig(_configFromPackageName(info.packageName));

  await NotificationService.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  runApp(
    ChangeNotifierProvider(
      create: (_) => EmbassyProvider(),
      child: const EmbassyApp(),
    ),
  );
}

EmbassyConfig _configFromPackageName(String packageName) {
  if (packageName.contains('beijing')) return EmbassyConfig.beijing;
  if (packageName.contains('abuja')) return EmbassyConfig.abuja;
  if (packageName.contains('abudhabi')) return EmbassyConfig.abudhabi;
  if (packageName.contains('ankara')) return EmbassyConfig.ankara;
  return EmbassyConfig.newdelhi;
}

class EmbassyApp extends StatelessWidget {
  const EmbassyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EmbassyConfig.current;
    return MaterialApp(
      title: 'Ireland Visa — ${config.name}',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: config.primaryColor),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const EmbassyScreen(),
    );
  }
}
