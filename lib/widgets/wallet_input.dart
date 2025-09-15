import 'package:flutter/material.dart';

class WalletInput extends StatelessWidget {
  const WalletInput({
    super.key,
    required this.controller,
    required this.onFetch,
  });

  final TextEditingController controller;
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Solana Wallet Address',
              hintText: 'e.g. 4Nd1mY... (base58)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onFetch,
            icon: const Icon(Icons.search),
            label: const Text('Fetch'),
          ),
        )
      ],
    );
  }
}
