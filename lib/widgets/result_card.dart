import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        if (result.found) return _FoundCard(result: result);
        return _NotFoundCard(result: result);
      },
    );
  }
}

class _FoundCard extends StatelessWidget {
  final VisaCheckResult result;
  const _FoundCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isApproved ? Colors.green : Colors.red;
    final bgColor = result.isApproved ? Colors.green.shade50 : Colors.red.shade50;
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
            const SizedBox(height: 4),
            Text(
              'Application ${result.applicationNumber}',
              style: const TextStyle(fontWeight: FontWeight.w500),
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
          ],
        ),
      ),
    );
  }
}

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
                'Not found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                  fontSize: 16,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              'Application ${result.applicationNumber} is not in current published records for this embassy.',
            ),
            if (result.before != null || result.after != null) ...[
              const SizedBox(height: 14),
              const Text('Nearest published numbers:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (result.before != null)
                _NearestRow(label: 'Before', entry: result.before!),
              if (result.after != null)
                _NearestRow(label: 'After', entry: result.after!),
            ],
          ],
        ),
      ),
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
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(entry.number,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: entry.isApproved ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.decision,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: entry.isApproved ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ),
          if (entry.difference != null) ...[
            const SizedBox(width: 6),
            Text('Δ ${entry.difference}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ],
      ),
    );
  }
}
