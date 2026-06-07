import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/embassy_config.dart';
import '../providers/embassy_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/check_card.dart';
import '../widgets/result_card.dart';
import '../widgets/irish_background.dart';
import '../widgets/watch_banner.dart';

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
      final p = context.read<EmbassyProvider>();
      p.loadStats();
      p.loadWatchState();
      p.loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<EmbassyProvider>().checkApplication(_controller.text.trim());
    if (!mounted) return;
    final result = context.read<EmbassyProvider>().checkResult;
    if (result == null) return;
    if (result.found) {
      if (result.isApproved) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(seconds: 3), _maybeRequestReview);
      } else {
        HapticFeedback.vibrate();
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _maybeRequestReview() async {
    if (!mounted) return;
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = EmbassyConfig.current;
    final primaryColor = config.primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(config.iconAsset),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ireland Visa Checker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(config.subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: IrishBackground(
        color: primaryColor,
        child: RefreshIndicator(
          onRefresh: () => context.read<EmbassyProvider>().loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WatchBanner(),
                StatsCard(color: primaryColor),
                const SizedBox(height: 16),
                CheckCard(
                  formKey: _formKey,
                  controller: _controller,
                  onSubmit: _submit,
                ),
                const SizedBox(height: 16),
                const ResultCard(),
                const SizedBox(height: 16),

                // ── How to use ───────────────────────────────────────────────
                _InfoExpansionTile(
                  title: 'How to use this app',
                  icon: Icons.help_outline,
                  color: primaryColor,
                  children: [
                    _AppIconStep(iconAsset: config.iconAsset),
                    const _BulletItem(
                        text: 'Enter your 8-digit application number e.g. 83276171 or with prefix IRL83276171'),
                    const _BulletItem(text: 'Get instant status check.'),
                    const _BulletItem(
                        text: 'See nearest processed numbers if yours is not found.'),
                    const _BulletItem(
                        text: 'Tap "Notify me when found" to get a notification the moment your decision appears.'),
                    const _BulletItem(
                        text: 'Share this app with your family and friends.'),
                    const _BulletItem(
                        text: 'Thousands of visa applicants use this app every week.'),
                    const SizedBox(height: 10),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(
                            'mailto:shayshankr@gmail.com?subject=Ireland Visa App - Feedback'),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Contact Developer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Troubleshoot ─────────────────────────────────────────────
                _InfoExpansionTile(
                  title: 'Having trouble?',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  children: [
                    const _BulletItem(
                        text: 'Visit the original embassy website and download the file directly.'),
                    const _BulletItem(
                        text: 'Usually the error is because the embassy has not yet uploaded the weekly file. Once uploaded, this app will work again.'),
                    const SizedBox(height: 10),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(config.url),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open Embassy Website'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Data sourced from ireland.ie',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable expansion tile ──────────────────────────────────────────────────

class _InfoExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoExpansionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: children,
        ),
      ),
    );
  }
}

class _AppIconStep extends StatelessWidget {
  final String iconAsset;
  const _AppIconStep({required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(iconAsset, width: 56, height: 56),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This is your app icon — you\'ll find it on your home screen. Tap it any time to check your visa decision, no login needed.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

