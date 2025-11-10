import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/menu_item_option.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_builder/create_order_screen.dart';
import 'package:wishi_app/presentation/widgets/add_to_existing_order_dialog.dart';
import 'package:wishi_app/presentation/viewmodels/home_viewmodel.dart';

class MenuItemOptionCard extends ConsumerWidget {
  const MenuItemOptionCard({
    super.key,
    required this.menuItem,
    required this.option,
  });

  final MenuItem menuItem;
  final MenuItemOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: const Text('What would you like to do?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Create a New Order'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrderScreen(
                          initialOrderItem: OrderItem(
                            id: const Uuid().v4(),
                            menuItemId: menuItem.id,
                            name: menuItem.name,
                            quantity: 1,
                            price: menuItem.price + option.priceModifier,
                            selectedOption: option,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text('Add to an Existing Order'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the first dialog
                    final newItem = OrderItem(
                      id: const Uuid().v4(),
                      menuItemId: menuItem.id,
                      name: menuItem.name,
                      quantity: 1,
                      price: menuItem.price + option.priceModifier,
                      selectedOption: option,
                    );
                    showDialog(
                      context: context,
                      builder: (context) => AddToExistingOrderDialog(newItem: newItem),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          if (menuItem.imageUrl != null)
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: menuItem.imageUrl!,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black54,
                  Colors.black87,
                ],
                stops: const [
                  0.5,
                  0.8,
                  1.0,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  menuItem.name, // Display the parent menu item name
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  option.name, // Display the option name
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${(menuItem.price + option.priceModifier).toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
