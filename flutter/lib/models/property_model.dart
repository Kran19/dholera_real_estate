import 'property_image_model.dart';

/**
 * Property Listing Entity Model
 * DHOLERA REAL ESTATE
 */
class PropertyModel {
  final int id;
  final String villageName;
  final String surveyNo;
  final String zone;
  final String? tp;
  final String? fp;
  final String road;
  final double area;
  final String areaUnit;
  final String? reference;
  final String? primaryImage;
  final List<PropertyImageModel> images;
  final String? creatorName;
  final String? createdAt;
  final String? landingPrice;

  PropertyModel({
    required this.id,
    required this.villageName,
    required this.surveyNo,
    required this.zone,
    this.tp,
    this.fp,
    required this.road,
    required this.area,
    required this.areaUnit,
    this.reference,
    this.primaryImage,
    required this.images,
    this.creatorName,
    this.createdAt,
    this.landingPrice,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    var rawImgs = json['images'] as List? ?? [];
    List<PropertyImageModel> parsedImages = rawImgs
        .map((img) => PropertyImageModel.fromJson(Map<String, dynamic>.from(img)))
        .toList();

    return PropertyModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      villageName: json['village_name'] ?? '',
      surveyNo: json['survey_no'] ?? '',
      zone: json['zone'] ?? '',
      tp: json['tp'],
      fp: json['fp'],
      road: json['road'] ?? '',
      area: (json['area'] is num) ? (json['area'] as num).toDouble() : double.tryParse(json['area'].toString()) ?? 0.0,
      areaUnit: json['area_unit'] ?? 'Sq Yard',
      reference: json['reference'],
      primaryImage: json['primary_image'],
      images: parsedImages,
      creatorName: json['creator_name'],
      createdAt: json['created_at'],
      landingPrice: json['landing_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_name': villageName,
      'survey_no': surveyNo,
      'zone': zone,
      'tp': tp,
      'fp': fp,
      'road': road,
      'area': area,
      'area_unit': areaUnit,
      'reference': reference,
      'primary_image': primaryImage,
      'images': images.map((img) => img.toJson()).toList(),
      'creator_name': creatorName,
      'created_at': createdAt,
      'landing_price': landingPrice,
    };
  }
}
