import 'package:flutter_test/flutter_test.dart';
import 'package:wishi_app/domain/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('supports value equality', () {
      expect(
        const UserProfile(
          id: '1',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
        isNot(
          equals(
            const UserProfile(
              id: '2',
              email: 'test@example.com',
              displayName: 'Test User',
            ),
          ),
        ),
      );
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'phoneNumber': '1234567890',
        'photoUrl': 'http://example.com/photo.jpg',
        'streetAddress': '123 Main St',
        'city': 'New York',
        'state': 'NY',
        'zipCode': '10001',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, '123');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.phoneNumber, '1234567890');
      expect(profile.photoUrl, 'http://example.com/photo.jpg');
      expect(profile.streetAddress, '123 Main St');
      expect(profile.city, 'New York');
      expect(profile.state, 'NY');
      expect(profile.zipCode, '10001');
    });

    test('toJson creates correct map', () {
      const profile = UserProfile(
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        phoneNumber: '1234567890',
        photoUrl: 'http://example.com/photo.jpg',
        streetAddress: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
      );

      final json = profile.toJson();

      expect(json, {
        'id': '123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'phoneNumber': '1234567890',
        'photoUrl': 'http://example.com/photo.jpg',
        'streetAddress': '123 Main St',
        'city': 'New York',
        'state': 'NY',
        'zipCode': '10001',
      });
    });

    test('copyWith updates fields correctly', () {
      const profile = UserProfile(id: '1', email: 'test@example.com');

      final updated = profile.copyWith(
        displayName: 'New Name',
        city: 'New City',
      );

      expect(updated.id, '1');
      expect(updated.email, 'test@example.com');
      expect(updated.displayName, 'New Name');
      expect(updated.city, 'New City');
      expect(updated.state, null);
    });
  });
}
