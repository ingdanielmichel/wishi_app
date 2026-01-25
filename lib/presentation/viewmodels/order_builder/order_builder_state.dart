class OrderBuilderState {
  final bool isLoading;
  final String? error;

  OrderBuilderState({
    this.isLoading = false,
    this.error,
  });

  OrderBuilderState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return OrderBuilderState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
