import 'package:wishi_app/domain/models/menu_item_option.dart';

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final MenuItemOption? selectedOption;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedOption,
  });
}
