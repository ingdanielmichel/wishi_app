import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  late final FirebaseAuth _firebaseAuth;
  late final IOrderRepository _orderRepository;

  @override
  ProfileState build() {
    _firebaseAuth = ref.watch(firebaseAuthProvider);
    _orderRepository = ref.watch(orderRepositoryProvider);
    _loadProfile();
    return const ProfileState.loading();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        state = const ProfileState.error('User not logged in.');
        return;
      }

      final orderHistory = await _orderRepository.getOrders();

      state = ProfileState.loaded(
        userEmail: user.email ?? 'Anonymous',
        orderHistory: orderHistory,
      );
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }
}
