import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wishi_app/domain/models/user_profile.dart';
import 'package:wishi_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving user profile: $e');
    }
  }
}
