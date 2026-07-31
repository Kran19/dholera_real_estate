import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../models/app_picked_image.dart';
import '../services/property_service.dart';

/**
 * Property Management & Listing Provider State (Cross-Platform Web & Mobile)
 * DHOLERA REAL ESTATE
 */
class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  List<PropertyModel> _properties = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalProperties = 0;

  // Search & Filter State
  String _searchQuery = '';
  String _villageFilter = '';
  String _zoneFilter = '';
  String _areaUnitFilter = '';

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalProperties => _totalProperties;
  String get searchQuery => _searchQuery;
  String get villageFilter => _villageFilter;
  String get zoneFilter => _zoneFilter;
  String get areaUnitFilter => _areaUnitFilter;

  // Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProperties(refresh: true);
  }

  // Set Filters
  void setFilters({String? village, String? zone, String? areaUnit}) {
    if (village != null) _villageFilter = village;
    if (zone != null) _zoneFilter = zone;
    if (areaUnit != null) _areaUnitFilter = areaUnit;
    fetchProperties(refresh: true);
  }

  void clearFilters() {
    _searchQuery = '';
    _villageFilter = '';
    _zoneFilter = '';
    _areaUnitFilter = '';
    fetchProperties(refresh: true);
  }

  Future<void> fetchProperties({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLoading = true;
    } else {
      if (_currentPage >= _totalPages || _isFetchingMore) return;
      _isFetchingMore = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _propertyService.fetchProperties(
        page: _currentPage,
        limit: 20,
        search: _searchQuery,
        villageName: _villageFilter,
        zone: _zoneFilter,
        areaUnit: _areaUnitFilter,
      );

      final List<PropertyModel> fetched = res['properties'];
      final Map<String, dynamic>? pagination = res['pagination'];

      if (refresh || _currentPage == 1) {
        _properties = fetched;
      } else {
        _properties.addAll(fetched);
      }

      if (pagination != null) {
        _totalPages = pagination['total_pages'] ?? 1;
        _totalProperties = pagination['total'] ?? _properties.length;
      }

      if (!refresh) {
        _currentPage++;
      }

      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty({
    required String villageName,
    required String surveyNo,
    required String zone,
    String? tp,
    String? fp,
    required String road,
    required double area,
    required String areaUnit,
    String? reference,
    List<AppPickedImage>? images,
  }) async {
    try {
      final newProp = await _propertyService.createProperty(
        villageName: villageName,
        surveyNo: surveyNo,
        zone: zone,
        tp: tp,
        fp: fp,
        road: road,
        area: area,
        areaUnit: areaUnit,
        reference: reference,
        images: images,
      );
      _properties.insert(0, newProp);
      _totalProperties++;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProperty({
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
    List<int>? deleteImageIds,
    List<AppPickedImage>? newImages,
  }) async {
    try {
      await _propertyService.updateProperty(
        id: id,
        villageName: villageName,
        surveyNo: surveyNo,
        zone: zone,
        tp: tp,
        fp: fp,
        road: road,
        area: area,
        areaUnit: areaUnit,
        reference: reference,
        deleteImageIds: deleteImageIds,
        newImages: newImages,
      );
      await fetchProperties(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(int id) async {
    try {
      await _propertyService.deleteProperty(id);
      _properties.removeWhere((p) => p.id == id);
      _totalProperties = _totalProperties > 0 ? _totalProperties - 1 : 0;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
