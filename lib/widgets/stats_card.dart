import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/embassy_provider.dart';

class StatsCard extends StatelessWidget {
  final Color color;
  const StatsCard({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmbassyProvider>(
      builder: (context, provider, _) {
        if (provider.statsState == LoadState.loading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (provider.statsState == LoadState.error || provider.stats == null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Could not load embassy data'),
              ]),
            ),
          );
        }

        final stats = provider.stats!;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // ── Live indicator ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: stats.available ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stats.available
                          ? 'Live · Updates ${stats.cadence}'
                          : 'Data unavailable',
                      style: TextStyle(
                        color: stats.available ? Colors.green.shade700 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Total count ──────────────────────────────────────────────
                Text(
                  '${stats.recordCount}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Text(
                  'Total decisions published',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // ── Approved / Refused row ───────────────────────────────────
                if (stats.recordCount > 0) ...[
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _StatPill(
                        label: 'Approved',
                        count: stats.approved,
                        percent: stats.approvalRate,
                        color: Colors.green.shade600,
                        icon: Icons.check_circle_outline,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatPill(
                        label: 'Refused',
                        count: stats.refused,
                        percent: stats.recordCount > 0
                            ? (stats.refused / stats.recordCount * 100)
                            : 0,
                        color: Colors.red.shade600,
                        icon: Icons.cancel_outlined,
                      )),
                    ],
                  ),

                  // ── Approval rate bar ────────────────────────────────────
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stats.approvalRate / 100,
                      minHeight: 8,
                      backgroundColor: Colors.red.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade500),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${stats.approvalRate.toStringAsFixed(1)}% approval rate',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],

                // ── Last refreshed ───────────────────────────────────────────
                if (stats.lastRefreshed.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Last updated: ${stats.lastRefreshed}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
          Text(
            '(${percent.toStringAsFixed(1)}%)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
