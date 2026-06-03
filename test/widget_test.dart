import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ireland_visa_embassy/config/embassy_config.dart';
import 'package:ireland_visa_embassy/providers/embassy_provider.dart';
import 'package:ireland_visa_embassy/screens/embassy_screen.dart';

Widget _buildApp(EmbassyConfig config) {
  EmbassyConfig.setConfig(config);
  return ChangeNotifierProvider(
    create: (_) => EmbassyProvider(),
    child: MaterialApp(
      home: const EmbassyScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final flavors = [
    EmbassyConfig.newdelhi,
    EmbassyConfig.beijing,
    EmbassyConfig.abuja,
    EmbassyConfig.abudhabi,
    EmbassyConfig.ankara,
  ];

  for (final flavor in flavors) {
    testWidgets('${flavor.name}: screen renders key elements', (tester) async {
      await tester.pumpWidget(_buildApp(flavor));
      await tester.pump();

      // AppBar title
      expect(find.text('Ireland Visa Checker'), findsOneWidget);
      // Subtitle shows in AppBar
      expect(find.text(flavor.subtitle), findsOneWidget);
      // Check card heading
      expect(find.text('Check your visa decision'), findsOneWidget);
      // How-to tile
      expect(find.text('How to use this tool'), findsOneWidget);
      // Error fallback tile
      expect(find.text('If any error click on me'), findsOneWidget);
    });
  }

  testWidgets('App icon asset path is unique per flavor', (tester) async {
    final assets = flavors.map((f) => f.iconAsset).toSet();
    expect(assets.length, flavors.length,
        reason: 'Each flavor must have a distinct icon asset');
  });
}
