import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                  title: 'How to use this tool',
                  icon: Icons.help_outline,
                  color: primaryColor,
                  children: [
                    _AppIconStep(iconAsset: config.iconAsset),
                    const _BulletItem(text: 'Enter your 8-digit application number e.g. 83276171 or with prefix IRL83276171'),
                    const _BulletItem(text: 'Get instant status check.'),
                    const _BulletItem(text: 'See nearest processed numbers if yours is not found.'),
                    const _BulletItem(text: 'Please share with your family and friends this application.'),
                    const _BulletItem(text: 'More than 4130+ people have used this application as of April 2026. Last week usage 200 people.'),
                    const _BulletItem(text: 'Contact the developer if any issues while using this application.'),
                    const SizedBox(height: 8),
                    const _HashtagRow(),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Error fallback ───────────────────────────────────────────
                _InfoExpansionTile(
                  title: 'If any error click on me',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  children: [
                    const _BulletItem(
                        text: 'Visit the original embassy website and download the file directly.'),
                    const _BulletItem(
                        text: 'Mostly the error is due to the file not being available on the server. Once the embassy website has the file, this application will work.'),
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

// ── App icon step ────────────────────────────────────────────────────────────

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
              'Find this app on your phone using the icon shown here, then tap it to open.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bullet point item ────────────────────────────────────────────────────────

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
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ── Hashtag row ──────────────────────────────────────────────────────────────

class _HashtagRow extends StatelessWidget {
  const _HashtagRow();

  @override
  Widget build(BuildContext context) {
    const tags = [
      '#irelandvisaresult',
      '#ireland',
      '#AIforgood',
      '#studentinireland',
      '#irelandeducation',
      '#NCIcollege',
      '#NCI',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 11)),
        backgroundColor: const Color(0xFF169B62).withValues(alpha: 0.1),
        side: const BorderSide(color: Color(0xFF169B62), width: 0.5),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )).toList(),
    );
  }
}
