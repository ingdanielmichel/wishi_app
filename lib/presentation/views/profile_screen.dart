import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (userEmail, orderHistory) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Email: $userEmail'),
              const SizedBox(height: 32),
              const Text(
                'Order History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: orderHistory.isEmpty
                    ? const Center(child: Text('No orders yet.'))
                    : ListView.builder(
                        itemCount: orderHistory.length,
                        itemBuilder: (context, index) {
                          final order = orderHistory[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text('Order #${order.id}'),
                              subtitle: Text('Total: \${order.total.toStringAsFixed(2)}'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Handle navigation to order details
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        error: (message) => Center(child: Text('Error: $message')),
      ),
    );
  }
}