import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_creation_state.freezed.dart';

@freezed
abstract class OrderCreationState with _$OrderCreationState {
  const factory OrderCreationState.initial() = _Initial;
  const factory OrderCreationState.loading() = _Loading;
  const factory OrderCreationState.success() = _Success;
  const factory OrderCreationState.error(String message) = _Error;
}
