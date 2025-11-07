import 'package:flutter/material.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/menu_item_option.dart';
import 'package:wishi_app/presentation/widgets/menu_item_option_card.dart';

class _OptionDisplayItem {
  final MenuItem menuItem;
  final MenuItemOption option;

  _OptionDisplayItem({required this.menuItem, required this.option});
}

class CategoryTabView extends StatefulWidget {
  const CategoryTabView({super.key, required this.category});

  final Category category;

  @override
  State<CategoryTabView> createState() => _CategoryTabViewState();
}

class _CategoryTabViewState extends State<CategoryTabView>
    with AutomaticKeepAliveClientMixin {
  List<_OptionDisplayItem> _optionDisplayItems = [];

  @override
  void initState() {
    super.initState();
    _prepareOptionDisplayItems();
  }

  @override
  void didUpdateWidget(covariant CategoryTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _prepareOptionDisplayItems();
    }
  }

  void _prepareOptionDisplayItems() {
    _optionDisplayItems = [];
    for (var item in widget.category.items) {
      for (var option in item.options) {
        _optionDisplayItems.add(
          _OptionDisplayItem(menuItem: item, option: option),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      key: PageStorageKey(widget.category.name),
      itemCount: _optionDisplayItems.length,
      itemBuilder: (context, index) {
        final displayItem = _optionDisplayItems[index];
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: MenuItemOptionCard(
            menuItem: displayItem.menuItem,
            option: displayItem.option,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
