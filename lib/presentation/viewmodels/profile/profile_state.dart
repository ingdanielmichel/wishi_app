import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/user_profile.dart';

abstract class ProfileState {
  const ProfileState();
}

class InitialProfileState extends ProfileState {
  const InitialProfileState();
}

class UnauthenticatedProfileState extends ProfileState {
  const UnauthenticatedProfileState();
}

class LoadingProfileState extends ProfileState {
  const LoadingProfileState();
}

class LoadedProfileState extends ProfileState {
  final UserProfile userProfile;
  final List<Order> orderHistory;
  final bool isAnonymous;

  const LoadedProfileState({
    required this.userProfile,
    required this.orderHistory,
    this.isAnonymous = false,
  });
}

class ErrorProfileState extends ProfileState {
  final String message;
  const ErrorProfileState(this.message);
}
