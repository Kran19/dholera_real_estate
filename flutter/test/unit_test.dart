import 'package:flutter_test/flutter_test.dart';
import 'package:dholera_real_estate/models/user_model.dart';
import 'package:dholera_real_estate/models/property_model.dart';
import 'package:dholera_real_estate/models/property_image_model.dart';

void main() {
  group('UserModel JSON Serialization Tests', () {
    test('UserModel.fromJson parses super_admin correctly', () {
      final json = {
        'id': 1,
        'username': 'admin',
        'role': 'super_admin',
        'status': 'active',
        'created_at': '2026-07-31 10:00:00',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'admin');
      expect(user.role, 'super_admin');
      expect(user.isSuperAdmin, isTrue);
      expect(user.isActive, isTrue);
    });

    test('UserModel.fromJson parses standard user correctly', () {
      final json = {
        'id': 2,
        'username': 'user1',
        'role': 'user',
        'status': 'inactive',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 2);
      expect(user.username, 'user1');
      expect(user.role, 'user');
      expect(user.isSuperAdmin, isFalse);
      expect(user.isActive, isFalse);
    });
  });

  group('PropertyModel JSON Serialization Tests', () {
    test('PropertyModel.fromJson parses property with images correctly', () {
      final json = {
        'id': 15,
        'village_name': 'Kadipur',
        'survey_no': '102/A',
        'zone': 'Residential',
        'tp': 'TP-1',
        'fp': 'FP-45',
        'road': '24 Mtr',
        'area': 500.0,
        'area_unit': 'Sq Yard',
        'reference': 'Direct Owner',
        'primary_image': 'http://localhost/php/uploads/properties/15/img_1.jpg',
        'images': [
          {
            'id': 101,
            'image_url': 'http://localhost/php/uploads/properties/15/img_1.jpg',
            'sort_order': 1,
          }
        ],
        'creator_name': 'admin',
        'created_at': '2026-07-31 11:00:00',
      };

      final property = PropertyModel.fromJson(json);

      expect(property.id, 15);
      expect(property.villageName, 'Kadipur');
      expect(property.surveyNo, '102/A');
      expect(property.area, 500.0);
      expect(property.areaUnit, 'Sq Yard');
      expect(property.images.length, 1);
      expect(property.images.first.id, 101);
      expect(property.primaryImage, contains('img_1.jpg'));
    });
  });

  group('PropertyImageModel JSON Serialization Tests', () {
    test('PropertyImageModel.fromJson parses image metadata correctly', () {
      final json = {
        'id': 55,
        'image_url': 'http://localhost/php/uploads/properties/1/img.jpg',
        'sort_order': 2,
      };

      final image = PropertyImageModel.fromJson(json);

      expect(image.id, 55);
      expect(image.sortOrder, 2);
      expect(image.imageUrl, contains('img.jpg'));
    });
  });
}
