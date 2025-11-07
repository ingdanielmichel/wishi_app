import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishi_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  late final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> signInAnonymously() async {
    var userCredential = await _firebaseAuth.signInAnonymously();
  }
}
