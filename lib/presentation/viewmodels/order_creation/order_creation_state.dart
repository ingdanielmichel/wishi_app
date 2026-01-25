abstract class OrderCreationState {
  const OrderCreationState();
}

class InitialOrderCreationState extends OrderCreationState {
  const InitialOrderCreationState();
}

class LoadingOrderCreationState extends OrderCreationState {
  const LoadingOrderCreationState();
}

class SuccessOrderCreationState extends OrderCreationState {
  const SuccessOrderCreationState();
}

class ErrorOrderCreationState extends OrderCreationState {
  final String message;
  const ErrorOrderCreationState(this.message);
}
