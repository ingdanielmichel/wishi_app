class MenuItemOption {
  final String name;
  final double priceModifier;
  final List<MenuItemOption> subOptions;

  MenuItemOption({
    required this.name,
    required this.priceModifier,
    this.subOptions = const [],
  });
}