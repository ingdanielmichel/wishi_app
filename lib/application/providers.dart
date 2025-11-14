import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/data/repositories/auth_repository_impl.dart';
import 'package:wishi_app/data/repositories/menu_repository_impl.dart';
import 'package:wishi_app/data/repositories/order_repository_impl.dart';
import 'package:wishi_app/domain/repositories/auth_repository.dart';
import 'package:wishi_app/domain/repositories/menu_repository.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';
import 'package:wishi_app/domain/usecases/save_order_usecase.dart';
import 'package:wishi_app/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:wishi_app/presentation/viewmodels/order_builder/order_builder_viewmodel.dart';
import 'package:wishi_app/presentation/viewmodels/order_builder/order_builder_state.dart';
import 'package:wishi_app/presentation/viewmodels/order_creation/order_creation_viewmodel.dart';
import 'package:wishi_app/presentation/viewmodels/order_creation/order_creation_state.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart';

// Data Layer
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final databaseProvider = Provider<FirebaseDatabase>(
  (ref) => FirebaseDatabase.instance,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(firebaseAuthProvider)),
);

final orderRepositoryProvider = Provider<IOrderRepository>(
  (ref) => OrderRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  ),
);

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepositoryImpl(ref.watch(databaseProvider)),
);

final menuFutureProvider = FutureProvider((ref) async {
  final menuRepository = ref.watch(menuRepositoryProvider);
  return menuRepository.getMenu();
});

// Domain Layer

final saveOrderUseCaseProvider = Provider(
  (ref) => SaveOrderUseCase(ref.watch(orderRepositoryProvider)),
);

final signInAnonymouslyUseCaseProvider = Provider(
  (ref) => SignInAnonymouslyUseCase(ref.watch(authRepositoryProvider)),
);

// Presentation Layer
final orderBuilderViewModelProvider =
    NotifierProvider<OrderBuilderViewModel, OrderBuilderState>(
      OrderBuilderViewModel.new,
    );

final orderCreationViewModelProvider =
    NotifierProvider<OrderCreationViewModel, OrderCreationState>(
      OrderCreationViewModel.new,
    );

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
