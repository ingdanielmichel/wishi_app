import 'package:flutter/material.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/presentation/widgets/menu_item_card.dart';

class CategoryTabView extends StatefulWidget {
  const CategoryTabView({super.key, required this.category});

  final Category category;

  @override
  State<CategoryTabView> createState() => _CategoryTabViewState();
}

class _CategoryTabViewState extends State<CategoryTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      key: PageStorageKey(widget.category.name),
      itemCount: widget.category.items.length,
      itemBuilder: (context, index) {
        final item = widget.category.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: MenuItemCard(item: item, categoryName: widget.category.name),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
