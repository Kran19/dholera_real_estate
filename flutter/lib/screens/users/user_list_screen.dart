import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

/// Super Admin User Management Screen
/// DHOLERA REAL ESTATE
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserModal({UserModel? editUser}) {
    final isEdit = editUser != null;
    final usernameController = TextEditingController(text: isEdit ? editUser.username : '');
    final passwordController = TextEditingController();
    String selectedStatus = isEdit ? editUser.status : 'active';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
                top: 20.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Edit User Account' : 'Create User Account', style: AppStyles.heading3),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12.0),
                    CustomTextField(
                      label: 'Username',
                      hint: 'Enter username',
                      controller: usernameController,
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Username is required';
                        if (val.trim().length < 3) return 'Username must be at least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextField(
                      label: isEdit ? 'New Passcode (Leave empty to keep current)' : 'Passcode',
                      hint: isEdit ? 'Enter new passcode' : 'Enter passcode',
                      controller: passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) {
                        if (!isEdit && (val == null || val.isEmpty)) {
                          return 'Passcode is required';
                        }
                        if (val != null && val.isNotEmpty && val.length < 4) {
                          return 'Passcode must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text('Account Status', style: AppStyles.labelStyle),
                    const SizedBox(height: 6.0),
                    RadioGroup<String>(
                      groupValue: selectedStatus,
                      onChanged: (val) => setModalState(() => selectedStatus = val!),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Active', style: TextStyle(fontSize: 14)),
                              value: 'active',
                              activeColor: AppColors.success,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Inactive', style: TextStyle(fontSize: 14)),
                              value: 'inactive',
                              activeColor: AppColors.error,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    CustomButton(
                      text: isEdit ? 'Save Changes' : 'Create User',
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final userProv = Provider.of<UserProvider>(context, listen: false);

                        bool success;
                        if (isEdit) {
                          success = await userProv.updateUser(
                            id: editUser.id,
                            username: usernameController.text.trim(),
                            password: passwordController.text.isNotEmpty ? passwordController.text : null,
                            status: selectedStatus,
                          );
                        } else {
                          success = await userProv.createUser(
                            usernameController.text.trim(),
                            passwordController.text,
                            selectedStatus,
                          );
                        }

                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          if (success) {
                            UiHelpers.showSnackBar(
                              context,
                              isEdit ? 'User updated successfully' : 'User created successfully',
                            );
                          } else {
                            UiHelpers.showSnackBar(
                              context,
                              userProv.errorMessage ?? 'Operation failed',
                              isError: true,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = Provider.of<AuthProvider>(context).currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('User Management', style: AppStyles.heading3.copyWith(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddUserModal(),
      ),
      body: Column(
        children: [
          // Search & Metrics Header Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search username...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                userProvider.fetchUsers(refresh: true);
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (val) {
                      userProvider.fetchUsers(refresh: true, search: val.trim());
                    },
                  ),
                ),
              ],
            ),
          ),

          // User List View
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => userProvider.fetchUsers(refresh: true),
              child: userProvider.isLoading && userProvider.users.isEmpty
                  ? const LoadingWidget(message: 'Loading user accounts...')
                  : userProvider.users.isEmpty
                      ? const EmptyStateWidget(
                          title: 'No Users Found',
                          message: 'No matching user accounts registered in system.',
                          icon: Icons.people_outline,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: userProvider.users.length,
                          itemBuilder: (context, index) {
                            final user = userProvider.users[index];
                            final isSelf = user.id == currentUserId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: user.isSuperAdmin ? AppColors.primary : AppColors.secondary,
                                  child: Icon(
                                    user.isSuperAdmin ? Icons.admin_panel_settings : Icons.person,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(user.username, style: AppStyles.heading3.copyWith(fontSize: 16.0)),
                                    if (isSelf) ...[
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryAccent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: const Text('YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  'Role: ${user.role} | Status: ${user.status.toUpperCase()}',
                                  style: AppStyles.bodySmall,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Status Switch
                                    if (!isSelf && !user.isSuperAdmin)
                                      Switch(
                                        value: user.isActive,
                                        activeThumbColor: AppColors.success,
                                        onChanged: (val) async {
                                          final newStatus = val ? 'active' : 'inactive';
                                          await userProvider.toggleUserStatus(user.id, newStatus);
                                        },
                                      ),

                                    PopupMenuButton<String>(
                                      onSelected: (val) async {
                                        if (val == 'edit') {
                                          _showAddUserModal(editUser: user);
                                        } else if (val == 'delete') {
                                          final confirm = await UiHelpers.showConfirmDialog(
                                            context,
                                            title: 'Delete User Account',
                                            message: 'Are you sure you want to permanently delete account "${user.username}"?',
                                          );
                                          if (confirm && context.mounted) {
                                            final ok = await userProvider.deleteUser(user.id);
                                            if (context.mounted) {
                                              if (ok) {
                                                UiHelpers.showSnackBar(context, 'User deleted');
                                              } else {
                                                UiHelpers.showSnackBar(context, userProvider.errorMessage ?? 'Delete failed', isError: true);
                                              }
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                        if (!isSelf && !user.isSuperAdmin)
                                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppColors.error, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
