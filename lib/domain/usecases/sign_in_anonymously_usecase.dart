import 'package:wishi_app/domain/repositories/auth_repository.dart';

class SignInAnonymouslyUseCase {
  final IAuthRepository _authRepository;

  SignInAnonymouslyUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.signInAnonymously();
  }
}
