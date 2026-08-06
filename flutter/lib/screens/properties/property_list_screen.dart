import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../core/network/update_checker.dart';
import '../../widgets/property_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../auth/login/login_screen.dart';
import 'property_details_screen.dart';
import 'add_edit_property_screen.dart';
import '../admin/dashboard/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';

/// Property List & Search Screen (User & Super Admin)
/// DHOLERA REAL ESTATE — Responsive Web & Mobile Layout with 1 / 2 / 4 Column Grid Toggles
class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Grid Columns State (1, 2, or 4 columns)
  int _gridCols = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await SecureStorageService.getToken();

      if (!authProvider.isAuthenticated && (token == null || token.isEmpty)) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(refresh: true);
      UpdateChecker.checkForUpdates(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<PropertyProvider>(context, listen: false).loadNextPage();
    }
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isSuperAdmin = authProvider.isSuperAdmin;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Image.asset(AppAssets.logo, height: 24.0),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('DHOLERA REAL ESTATE', style: AppStyles.heading3.copyWith(color: Colors.white, fontSize: 15.0)),
              ),
            ),
          ],
        ),
        actions: [
          if (isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard, color: Colors.white),
              tooltip: 'Admin Dashboard',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: isSuperAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Property', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditPropertyScreen()),
                );
              },
            )
          : null,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400.0),
          child: Column(
            children: [
              // Search Bar, Filter & Grid Layout Controls Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: AppColors.surface,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Village, Survey No, Reference...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  propertyProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onSubmitted: (val) {
                        propertyProvider.setSearchQuery(val.trim());
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // Grid Layout Column Selector Bar (Max 2 Cols on Mobile, 4 Cols on Desktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'View Layout:',
                          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        Row(
                          children: [
                            _buildGridToggleBtn(cols: 1, label: '1 Col', icon: Icons.view_stream),
                            const SizedBox(width: 6.0),
                            _buildGridToggleBtn(cols: 2, label: '2 Cols', icon: Icons.grid_view),
                            if (screenWidth >= 600) ...[
                              const SizedBox(width: 6.0),
                              _buildGridToggleBtn(cols: 4, label: '4 Cols', icon: Icons.view_comfy),
                            ],
                          ],
                        ),
                      ],
                    ),

                    // Active Filter Chips Indicator
                    if (propertyProvider.searchQuery.isNotEmpty ||
                        propertyProvider.zoneFilter.isNotEmpty ||
                        propertyProvider.areaUnitFilter.isNotEmpty) ...[
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (propertyProvider.searchQuery.isNotEmpty)
                              _buildActiveFilterChip('Search: ${propertyProvider.searchQuery}', () {
                                _searchController.clear();
                                propertyProvider.setSearchQuery('');
                              }),
                            if (propertyProvider.zoneFilter.isNotEmpty)
                              _buildActiveFilterChip('Zone: ${propertyProvider.zoneFilter}', () {
                                propertyProvider.setFilters(zone: '');
                              }),
                            if (propertyProvider.areaUnitFilter.isNotEmpty)
                              _buildActiveFilterChip('Unit: ${propertyProvider.areaUnitFilter}', () {
                                propertyProvider.setFilters(areaUnit: '');
                              }),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Property Display Body (Customizable 1, 2, or 4 Grid View)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await propertyProvider.fetchProperties(refresh: true);
                  },
                  child: propertyProvider.isLoading && propertyProvider.properties.isEmpty
                      ? const LoadingWidget(message: 'Fetching real estate property listings...')
                      : propertyProvider.errorMessage != null && propertyProvider.properties.isEmpty
                          ? ErrorStateWidget(
                              errorMessage: (propertyProvider.errorMessage!.contains('Unauthorized') || propertyProvider.errorMessage!.contains('token'))
                                  ? 'Authentication required or session expired. Please log in to access property listings.'
                                  : propertyProvider.errorMessage!,
                              onRetry: () {
                                if (propertyProvider.errorMessage!.contains('Unauthorized') || propertyProvider.errorMessage!.contains('token')) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  propertyProvider.fetchProperties(refresh: true);
                                }
                              },
                            )
                          : propertyProvider.properties.isEmpty
                              ? EmptyStateWidget(
                                  onRefresh: () => propertyProvider.fetchProperties(refresh: true),
                                )
                              : _gridCols == 1
                                  // 1 Column View (List View)
                                  ? ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16.0),
                                      itemCount: propertyProvider.properties.length + (propertyProvider.isFetchingMore ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == propertyProvider.properties.length) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0),
                                            child: Center(
                                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                            ),
                                          );
                                        }
                                        final property = propertyProvider.properties[index];
                                        return PropertyCard(
                                          property: property,
                                          isSuperAdmin: isSuperAdmin,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: property.id)),
                                            );
                                          },
                                          onEdit: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => AddEditPropertyScreen(property: property)),
                                            );
                                          },
                                          onDelete: () => _confirmDelete(propertyProvider, property),
                                        );
                                      },
                                    )
                                  // Multi-Column Grid View (1 or 2 Cols on Mobile, up to 4 Cols on Desktop)
                                  : Builder(
                                      builder: (context) {
                                        final int effectiveCols = (screenWidth < 600 && _gridCols > 2) ? 2 : _gridCols;
                                        return GridView.builder(
                                          controller: _scrollController,
                                          padding: const EdgeInsets.all(16.0),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: effectiveCols,
                                            crossAxisSpacing: screenWidth < 600 ? 10.0 : 16.0,
                                            mainAxisSpacing: screenWidth < 600 ? 10.0 : 16.0,
                                            childAspectRatio: effectiveCols == 4
                                                ? 0.75
                                                : effectiveCols == 2
                                                    ? (screenWidth < 600 ? 0.73 : 0.85)
                                                    : (screenWidth < 600 ? 1.10 : 1.35),
                                          ),
                                          itemCount: propertyProvider.properties.length + (propertyProvider.isFetchingMore ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index == propertyProvider.properties.length) {
                                              return const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                              );
                                            }
                                            final property = propertyProvider.properties[index];
                                            return PropertyCard(
                                              property: property,
                                              isSuperAdmin: isSuperAdmin,
                                              isCompact: effectiveCols > 1,
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: property.id)),
                                                );
                                              },
                                              onEdit: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (_) => AddEditPropertyScreen(property: property)),
                                                );
                                              },
                                              onDelete: () => _confirmDelete(propertyProvider, property),
                                            );
                                          },
                                        );
                                      },
                                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridToggleBtn({required int cols, required String label, required IconData icon}) {
    final bool isSelected = _gridCols == cols;
    return InkWell(
      onTap: () => setState(() => _gridCols = cols),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14.0, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(PropertyProvider propertyProvider, dynamic property) async {
    final confirm = await UiHelpers.showConfirmDialog(
      context,
      title: 'Delete Property Listing',
      message: 'Are you sure you want to delete property in "${property.villageName}" (Survey No: ${property.surveyNo})?',
    );
    if (confirm && mounted) {
      final success = await propertyProvider.deleteProperty(property.id);
      if (mounted) {
        if (success) {
          UiHelpers.showSnackBar(context, 'Property deleted successfully');
        } else {
          UiHelpers.showSnackBar(
            context,
            propertyProvider.errorMessage ?? 'Delete failed',
            isError: true,
          );
        }
      }
    }
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.15),
        deleteIcon: const Icon(Icons.close, size: 14.0),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
