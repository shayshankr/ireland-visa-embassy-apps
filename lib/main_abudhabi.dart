import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'background_task.dart';
import 'config/embassy_config.dart';
import 'providers/embassy_provider.dart';
import 'screens/embassy_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  EmbassyConfig.setConfig(EmbassyConfig.abudhabi);
  runApp(
    ChangeNotifierProvider(
      create: (_) => EmbassyProvider(),
      child: const EmbassyApp(),
    ),
  );
}

class EmbassyApp extends StatelessWidget {
  const EmbassyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EmbassyConfig.current;
    return MaterialApp(
      title: 'Ireland Visa - ${config.name}',
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
