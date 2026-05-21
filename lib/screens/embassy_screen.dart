import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/embassy_config.dart';
import '../providers/embassy_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/check_card.dart';
import '../widgets/result_card.dart';
import '../widgets/irish_background.dart';

class EmbassyScreen extends StatefulWidget {
  const EmbassyScreen({super.key});

  @override
  State<EmbassyScreen> createState() => _EmbassyScreenState();
}

class _EmbassyScreenState extends State<EmbassyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmbassyProvider>().loadStats();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<EmbassyProvider>().checkApplication(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final config = EmbassyConfig.current;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ireland Visa Checker',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(config.subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: IrishBackground(
        color: config.primaryColor,
        child: RefreshIndicator(
          onRefresh: () => context.read<EmbassyProvider>().loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatsCard(color: config.primaryColor),
                const SizedBox(height: 16),
                CheckCard(
                  formKey: _formKey,
                  controller: _controller,
                  onSubmit: _submit,
                ),
                const SizedBox(height: 16),
                const ResultCard(),
                const SizedBox(height: 24),
                Text(
                  'Data sourced from ireland.ie',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
