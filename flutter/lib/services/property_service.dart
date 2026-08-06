import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/property_model.dart';
import '../models/app_picked_image.dart';

/**
 * Property Management & Listing Service (Cross-Platform Web & Mobile)
 * DHOLERA REAL ESTATE
 */
class PropertyService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchProperties({
    int page = 1,
    int limit = 20,
    String search = '',
    String villageName = '',
    String zone = '',
    String areaUnit = '',
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.isNotEmpty) queryParams['search'] = search;
    if (villageName.isNotEmpty) queryParams['village_name'] = villageName;
    if (zone.isNotEmpty) queryParams['zone'] = zone;
    if (areaUnit.isNotEmpty) queryParams['area_unit'] = areaUnit;

    final response = await _apiClient.get(ApiConfig.propertiesList, queryParams: queryParams);
    final rawList = response['data']['properties'] as List? ?? [];
    final List<PropertyModel> properties = rawList
        .map((p) => PropertyModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return {
      'properties': properties,
      'pagination': response['pagination'],
    };
  }

  Future<PropertyModel> fetchPropertyDetails(int id) async {
    final response = await _apiClient.get(ApiConfig.propertyDetails, queryParams: {'id': id.toString()});
    return PropertyModel.fromJson(response['data']['property']);
  }

  Future<PropertyModel> createProperty({
    required String villageName,
    required String surveyNo,
    required String zone,
    String? tp,
    String? fp,
    required String road,
    required double area,
    required String areaUnit,
    String? reference,
    String? landingPrice,
    String? imageSequence,
    List<AppPickedImage>? images,
  }) async {
    final Map<String, String> fields = {
      'village_name': villageName,
      'survey_no': surveyNo,
      'zone': zone,
      'tp': tp ?? '',
      'fp': fp ?? '',
      'road': road,
      'area': area.toString(),
      'area_unit': areaUnit,
      'reference': reference ?? '',
      'landing_price': landingPrice ?? '',
    };
    if (imageSequence != null) fields['image_sequence'] = imageSequence;

    final response = await _apiClient.postMultipart(
      ApiConfig.propertyCreate,
      fields: fields,
      images: images,
      fileFieldName: 'images[]',
    );

    return PropertyModel.fromJson(response['data']['property']);
  }

  Future<void> updateProperty({
    required int id,
    String? villageName,
    String? surveyNo,
    String? zone,
    String? tp,
    String? fp,
    String? road,
    double? area,
    String? areaUnit,
    String? reference,
    String? landingPrice,
    String? imageSequence,
    List<int>? deleteImageIds,
    List<AppPickedImage>? newImages,
  }) async {
    final Map<String, String> fields = {'id': id.toString()};
    if (villageName != null && villageName.isNotEmpty) fields['village_name'] = villageName;
    if (surveyNo != null && surveyNo.isNotEmpty) fields['survey_no'] = surveyNo;
    if (zone != null && zone.isNotEmpty) fields['zone'] = zone;
    if (tp != null) fields['tp'] = tp;
    if (fp != null) fields['fp'] = fp;
    if (road != null && road.isNotEmpty) fields['road'] = road;
    if (area != null && area > 0) fields['area'] = area.toString();
    if (areaUnit != null && areaUnit.isNotEmpty) fields['area_unit'] = areaUnit;
    if (reference != null) fields['reference'] = reference;
    if (landingPrice != null) fields['landing_price'] = landingPrice;
    if (imageSequence != null) fields['image_sequence'] = imageSequence;

    if (deleteImageIds != null && deleteImageIds.isNotEmpty) {
      for (int i = 0; i < deleteImageIds.length; i++) {
        fields['delete_image_ids[$i]'] = deleteImageIds[i].toString();
      }
    }

    await _apiClient.postMultipart(
      ApiConfig.propertyUpdate,
      fields: fields,
      images: newImages,
      fileFieldName: 'images[]',
    );
  }

  Future<void> deleteProperty(int id) async {
    await _apiClient.post(
      ApiConfig.propertyDelete,
      body: {'id': id},
    );
  }
}
