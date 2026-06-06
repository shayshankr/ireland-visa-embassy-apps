import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/embassy_provider.dart';

class WatchBanner extends StatelessWidget {
  const WatchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmbassyProvider>(
      builder: (context, provider, _) {
        if (!provider.isWatching) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.teal),
            title: Text(
              'Watching ${provider.watchedNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.teal,
              ),
            ),
            subtitle: const Text(
              'Checking every 12 hours — you\'ll be notified when your decision appears.',
              style: TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.teal),
              tooltip: 'Stop watching',
              onPressed: () => provider.stopWatching(),
            ),
          ),
        );
      },
    );
  }
}
