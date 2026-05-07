import 'package:flutter/material.dart';

class CheckCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CheckCard({
    super.key,
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter an application number';
    final digits = v
        .trim()
        .replaceAll(RegExp(r'^[Ii][Rr][Ll]'), '')
        .replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return 'Must be 8 digits — e.g. 63690452';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Check your visa decision',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Accepted formats: 63690452  or  IRL63690452',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Application number',
                  hintText: 'e.g. 63690452',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validate,
                onFieldSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.search),
                label: const Text('Check Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
