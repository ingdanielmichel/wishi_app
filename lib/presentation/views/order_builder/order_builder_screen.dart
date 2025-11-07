import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/views/order_details_screen.dart';

class OrderBuilderScreen extends ConsumerWidget {
  const OrderBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderBuilderViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderDetailsScreen(),
                              ),
                            );
                          },
                          child: const Text('Create New Order'),
                        ),
                      ),
                    ),
                    state.orders.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                'No orders yet.',
                              ),
                            ),
                          )
                        : Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: state.orders.length,
                                    itemBuilder: (context, index) {
                                      final order = state.orders[index];
                                      return ListTile(
                                        title: Text(order.name),
                                        subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OrderDetailsScreen(order: order),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Total: \$${state.orders.fold(0.0, (sum, order) => sum + order.total).toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          // TODO: Implement checkout flow
                                        },
                                        child: const Text('Checkout'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
    );
  }
}
