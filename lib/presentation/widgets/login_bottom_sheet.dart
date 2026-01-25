import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart';

class LoginBottomSheet extends ConsumerStatefulWidget {
  const LoginBottomSheet({super.key, required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileViewModelProvider, (previous, next) {
      if (next is LoadedProfileState && !next.isAnonymous) {
        if (mounted) {
          // Check if user was building an order before login
          final currentOrder = ref.read(currentOrderViewModelProvider);
          final isCreatingOrder = ref
              .read(orderBuilderControlsViewModelProvider)
              .isCreatingNewOrder;

          Navigator.of(context).pop();

          // If user was building an order, keep them on the Order Builder tab
          if (isCreatingOrder && currentOrder.items.isNotEmpty) {
            ref.read(mainScreenIndexProvider.notifier).setIndex(1);
          }
        }
      } else if (next is ErrorProfileState) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final profileState = ref.watch(profileViewModelProvider);
    final isLoading = profileState is LoadingProfileState;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? 'Create Account' : 'Welcome Back',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        if (_isSignUp) {
                          ref
                              .read(profileViewModelProvider.notifier)
                              .createUserWithEmailAndPassword(
                                _emailController.text,
                                _passwordController.text,
                              );
                        } else {
                          ref
                              .read(profileViewModelProvider.notifier)
                              .signInWithEmailAndPassword(
                                _emailController.text,
                                _passwordController.text,
                              );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(profileViewModelProvider.notifier)
                          .signInWithGoogle();
                    },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
