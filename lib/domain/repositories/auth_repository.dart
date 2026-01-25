abstract class IAuthRepository {
  Future<void> signInAnonymously();
  Future<void> signInWithGoogle();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}
