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
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Could not load embassy data'),
              ]),
            ),
          );
        }
        final stats = provider.stats!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: stats.available ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stats.available ? 'Live · Updates ${stats.cadence}' : 'Data unavailable',
                      style: TextStyle(
                        color: stats.available ? Colors.green.shade700 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${stats.recordCount}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Total decisions published',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
