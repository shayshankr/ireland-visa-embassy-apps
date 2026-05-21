import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/embassy_config.dart';
import 'providers/embassy_provider.dart';
import 'screens/embassy_screen.dart';

void main() {
  EmbassyConfig.setConfig(EmbassyConfig.ankara);
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

