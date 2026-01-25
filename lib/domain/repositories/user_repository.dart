import 'package:wishi_app/domain/models/user_profile.dart';

abstract class IUserRepository {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> saveUserProfile(UserProfile profile);
}
