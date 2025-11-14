import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishi_app/data/repositories/menu_repository_impl.dart';
import 'package:wishi_app/domain/models/category.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  late MenuRepositoryImpl repository;
  late FirebaseDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockFirebaseDatabase.instance;
    repository = MenuRepositoryImpl(mockDatabase);
  });

  group('getMenuStream', () {
    test('should return a stream of categories when the call to firebase is successful', () async {
      // arrange
      final menuJson = json.decode(fixture('menu.json'));
      MockFirebaseDatabase.instance.ref('menus').set(menuJson['menus']);

      // act
      final result = repository.getMenuStream();

      // assert
      result.listen(
        expectAsync1((categories) {
          expect(categories, isA<List<Category>>());
          expect(categories.length, 5);
        }),
      );
    });
  });
}
