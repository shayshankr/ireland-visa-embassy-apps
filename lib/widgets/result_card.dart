import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/visa_result.dart';
import '../providers/embassy_provider.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmbassyProvider>(
      builder: (context, provider, _) {
        if (provider.checkState == LoadState.idle) return const SizedBox.shrink();

        if (provider.checkState == LoadState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.checkState == LoadState.error) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(provider.error,
                      style: const TextStyle(color: Colors.red)),
                ),
              ]),
            ),
          );
        }

        final result = provider.checkResult!;
        if (result.found) {
          return Column(
            children: [
              _FoundCard(result: result),
              if (result.isApproved) ...[
                const SizedBox(height: 12),
                const _WhatsNextCard(),
              ],
            ],
          );
        }
        return _NotFoundCard(result: result);
      },
    );
  }
}

// ── Found ────────────────────────────────────────────────────────────────────

class _FoundCard extends StatelessWidget {
  final VisaCheckResult result;
  const _FoundCard({required this.result});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result.applicationNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application number copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _share() {
    Share.share(
      'Ireland Visa Decision\n'
      'Application: ${result.applicationNumber}\n'
      'Status: ${result.decision}\n\n'
      'Check your status on the Ireland Visa Checker app.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = result.isApproved ? Colors.green : Colors.red;
    final bgColor =
        result.isApproved ? Colors.green.shade50 : Colors.red.shade50;
    final icon = result.isApproved ? Icons.check_circle : Icons.cancel;

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 56),
            const SizedBox(height: 12),
            Text(
              result.decision ?? '',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            // Tap to copy application number
            GestureDetector(
              onTap: () => _copy(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Application ${result.applicationNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.copy, size: 14, color: Colors.grey.shade400),
                ],
              ),
            ),
            if (result.source != null) ...[
              const SizedBox(height: 4),
              Text(
                result.source!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Share result'),
              style: OutlinedButton.styleFrom(foregroundColor: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── What happens next ────────────────────────────────────────────────────────

class _WhatsNextCard extends StatelessWidget {
  const _WhatsNextCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(Icons.checklist_rounded, color: Colors.green.shade600),
          title: Text(
            'What happens next?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: const [
            _NextStep(
              number: '1',
              text:
                  'The embassy will email you to collect your passport. Check your inbox and spam folder.',
            ),
            _NextStep(
              number: '2',
              text:
                  'Collect your passport within the deadline in the email — usually 5–10 working days.',
            ),
            _NextStep(
              number: '3',
              text:
                  'Bring: original passport, VFS receipt, and any documents mentioned in the collection email.',
            ),
            _NextStep(
              number: '4',
              text:
                  'Check the visa stamp carefully: your name, travel dates, visa type, and number of entries.',
            ),
            _NextStep(
              number: '5',
              text:
                  'You are ready to travel to Ireland! Book your flights and arrange accommodation.',
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String text;
  const _NextStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ── Not found ────────────────────────────────────────────────────────────────

class _NotFoundCard extends StatelessWidget {
  final VisaCheckResult result;
  const _NotFoundCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Not yet published',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                  fontSize: 16,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              'Application ${result.applicationNumber} is not in the current published records for this embassy.',
            ),
            if (result.before != null || result.after != null) ...[
              const SizedBox(height: 14),
              const Text(
                'Nearest processed numbers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Your number sits between these. The smaller the gap, the closer you are to being processed.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              if (result.before != null)
                _NearestRow(label: 'Below', entry: result.before!),
              if (result.after != null)
                _NearestRow(label: 'Above', entry: result.after!),
            ],
            const Divider(height: 24),
            _WatchButton(applicationNumber: result.applicationNumber),
          ],
        ),
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  final String applicationNumber;
  const _WatchButton({required this.applicationNumber});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmbassyProvider>(
      builder: (context, provider, _) {
        final isWatchingThis = provider.isWatching &&
            provider.watchedNumber == applicationNumber;

        if (isWatchingThis) {
          return Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: Colors.teal, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Watching — you\'ll be notified when found.',
                  style: TextStyle(color: Colors.teal, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => provider.stopWatching(),
                child: const Text('Stop',
                    style: TextStyle(color: Colors.teal)),
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              final granted =
                  await provider.startWatching(applicationNumber);
              if (!granted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enable notifications in device Settings to use this feature.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('Notify me when found'),
          ),
        );
      },
    );
  }
}

class _NearestRow extends StatelessWidget {
  final String label;
  final NearestResult entry;
  const _NearestRow({required this.label, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$label: ', style: const TextStyle(color: Colors.grey)),
          ),
          Text(entry.number,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: entry.isApproved
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.decision,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: entry.isApproved
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
          ),
          if (entry.difference != null) ...[
            const SizedBox(width: 6),
            Text(
              '${entry.difference} positions',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}
