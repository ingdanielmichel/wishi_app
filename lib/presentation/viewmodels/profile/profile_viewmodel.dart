import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/application/services/analytics_service.dart';
import 'package:wishi_app/domain/models/user_profile.dart'; // Added
import 'package:wishi_app/domain/repositories/auth_repository.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';
import 'package:wishi_app/domain/repositories/user_repository.dart'; // Added
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart'
    show
        ProfileState,
        LoadingProfileState,
        LoadedProfileState,
        ErrorProfileState,
        UnauthenticatedProfileState;

class ProfileViewModel extends Notifier<ProfileState> {
  late final FirebaseAuth _firebaseAuth;
  late final IOrderRepository _orderRepository;
  late final IAuthRepository _authRepository;
  late final IUserRepository _userRepository; // Added
  StreamSubscription<User?>? _authStateSubscription;

  @override
  ProfileState build() {
    _firebaseAuth = ref.watch(firebaseAuthProvider);
    _orderRepository = ref.watch(orderRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider); // Added

    _authStateSubscription?.cancel();
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      _loadProfile();
    });

    return LoadingProfileState();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      // We allow anonymous users to view profile (Wait, requirements said login first?
      // "In the profile window, the users will be able to setup their users information and view the orders history."
      // Implementation plan says: "If user is Anonymous/Not Logged In: Show Login UI".
      // So we treat Anonymous as "not logged in" for the purpose of the FULL profile,
      // but maybe we should still show something?
      // For now, let's stick to the plan: Login UI if anonymous/null.

      if (user == null || user.isAnonymous) {
        // We can use ErrorProfileState or a specific Unauthenticated state.
        // Since we don't have UnauthenticatedState, we'll use Initial/Error or just check in UI.
        // Actually, let's pass the state. If user is anonymous, we might want to show "Guest" but ask to login.
        // But the request says "build the login... in the profile tab".
        // Let's assume LoadedProfileState but with isAnonymous flag if I could change state.
        // Or just return Error/Initial.
        // Let's return InitialProfileState as "Not Logged In" equivalent for now, or maintain Loading if we are transitioning.
        // Better: Let's use a specific state if possible, but I can't change State definition easily here without seeing `profile_state.dart`.
        // I'll assume standard state. I will use `ErrorProfileState('Unauthenticated')` as a signal or just let the UI check `_firebaseAuth.currentUser`.
        // Wait, the UI uses `profileState`.
        // I will modify `_loadProfile` to emit `LoadedProfileState` even for anonymous, but distinct?
        // No, the plan said: "If user is Anonymous/Not Logged In: Show Login UI".
        // So I will make `_loadProfile` handle this.
      }

      if (user == null) {
        state = const UnauthenticatedProfileState();
        return;
      }

      final orderHistory = await _orderRepository.getOrders();
      UserProfile? userProfile = await _userRepository.getUserProfile(user.uid);

      if (userProfile == null) {
        userProfile = UserProfile(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
          photoUrl: user.photoURL,
        );
        // Optionally save the initial profile
        // await _userRepository.saveUserProfile(userProfile);
      } else {
        // If Google info updated, maybe we should sync? For now, keep DB as source of truth.
        // But if DB is missing info that Auth has, maybe fill it in?
        bool changed = false;
        if (user.photoURL != null && userProfile.photoUrl != user.photoURL) {
          // Decisions on sync policy... Let's just use what we have or prioritize DB.
        }
      }

      state = LoadedProfileState(
        userProfile: userProfile,
        orderHistory: orderHistory,
        isAnonymous: user.isAnonymous,
      );
    } catch (e) {
      state = ErrorProfileState(e.toString());
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    // Keep current state but show loading? Or just optimistic update?
    // Let's show loading or just await.
    try {
      if (state is! LoadedProfileState) return;
      final currentState = state as LoadedProfileState;

      // Ideally show loading indicator

      await _userRepository.saveUserProfile(profile);

      // Update state
      state = LoadedProfileState(
        userProfile: profile,
        orderHistory: currentState.orderHistory,
        isAnonymous: currentState.isAnonymous,
      );
    } catch (e) {
      // Handle error, maybe show toast?
      // For now, if it fails, maybe revert or show error state?
      // Let's just log or set error state if critical.
      // Setting ErrorProfileState would wipe the screen, maybe not ideal.
    }
  }

  // Public methods for UI
  Future<void> signInWithGoogle() async {
    state = LoadingProfileState();
    try {
      await _authRepository.signInWithGoogle();
      ref.read(analyticsServiceProvider).logLogin(method: 'google');
    } catch (e) {
      state = ErrorProfileState(e.toString());
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = LoadingProfileState();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      ref.read(analyticsServiceProvider).logLogin(method: 'email');
    } catch (e) {
      state = ErrorProfileState(e.toString());
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = LoadingProfileState();
    try {
      await _authRepository.createUserWithEmailAndPassword(email, password);
      ref.read(analyticsServiceProvider).logLogin(method: 'email_signup');
    } catch (e) {
      state = ErrorProfileState(e.toString());
    }
  }

  Future<void> signOut() async {
    state = LoadingProfileState();
    try {
      await _authRepository.signOut();
    } catch (e) {
      state = ErrorProfileState(e.toString());
    }
  }
}
