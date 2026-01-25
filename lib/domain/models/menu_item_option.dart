class MenuItemOption {
  final String name;
  final double priceModifier;
  final List<MenuItemOption> subOptions;

  MenuItemOption({
    required this.name,
    required this.priceModifier,
    this.subOptions = const [],
  });

  MenuItemOption copyWith({
    String? name,
    double? priceModifier,
    List<MenuItemOption>? subOptions,
  }) {
    return MenuItemOption(
      name: name ?? this.name,
      priceModifier: priceModifier ?? this.priceModifier,
      subOptions: subOptions ?? this.subOptions,
    );
  }
}
