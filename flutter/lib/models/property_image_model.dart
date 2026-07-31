/**
 * Property Image Entity Model
 * DHOLERA REAL ESTATE
 */
class PropertyImageModel {
  final int id;
  final String imageUrl;
  final int sortOrder;

  PropertyImageModel({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      imageUrl: json['image_url'] ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] : int.parse(json['sort_order'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    };
  }
}
