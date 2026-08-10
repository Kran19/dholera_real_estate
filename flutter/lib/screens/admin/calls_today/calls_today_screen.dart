import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/telecalling_contact_model.dart';
import '../../../providers/telecalling_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_widget.dart';

/// Calls Today Screen (Super Admin Only)
/// DHOLERA REAL ESTATE — Dedicated Telecalling Contacts & 10-Day Rotation System
class CallsTodayScreen extends StatefulWidget {
  const CallsTodayScreen({super.key});

  @override
  State<CallsTodayScreen> createState() => _CallsTodayScreenState();
}

class _CallsTodayScreenState extends State<CallsTodayScreen> {
  // Per-card local state (status dropdown + remarks) before saving
  final Map<int, String>                _draftStatus  = {};
  final Map<int, TextEditingController> _remarksCtrls = {};

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'received',       'label': '✅ Received / Connected'},
    {'value': 'pending',        'label': '🕐 Pending'},
    {'value': 'no_answer',      'label': '📵 No Answer'},
    {'value': 'callback',       'label': '🔁 Callback Requested'},
    {'value': 'not_interested', 'label': '❌ Not Interested'},
    {'value': 'confirmed',      'label': '🔥 Confirmed Lead'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelecallingProvider>().fetchTodayBatch();
    });
  }

  @override
  void dispose() {
    for (final ctrl in _remarksCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _initDraftsFromProvider(TelecallingProvider provider) {
    for (final contact in provider.todaysBatch) {
      final id  = contact.id;
      final log = provider.todaysLogs[id];
      if (!_draftStatus.containsKey(id)) {
        _draftStatus[id] = log?.status ?? contact.status;
      }
      if (!_remarksCtrls.containsKey(id)) {
        _remarksCtrls[id] = TextEditingController(text: log?.remarks ?? '');
      }
    }
  }

  // ── Phone call ─────────────────────────────────────────────────────────────
  Future<void> _makeCall(String mobile) async {
    final clean = mobile.replaceAll(RegExp(r'[^\d+]'), '');
    final uri   = Uri(scheme: 'tel', path: clean);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot dial $mobile')),
        );
      }
    }
  }

  // ── Save log ───────────────────────────────────────────────────────────────
  Future<void> _saveLog(int contactId, TelecallingProvider provider) async {
    final status  = _draftStatus[contactId] ?? 'pending';
    final remarks = _remarksCtrls[contactId]?.text.trim() ?? '';
    final success = await provider.saveLog(
      contactId: contactId,
      status:    status,
      remarks:   remarks,
    );
    if (!mounted) return;

    final String message;
    if (success) {
      message = '✅ Saved successfully';
    } else {
      message = '❌ Error: ${provider.errorMessage ?? 'Failed to save log'}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Add Contact Sheet ──────────────────────────────────────────────────────
  void _showAddContactSheet(BuildContext context, TelecallingProvider provider) {
    final nameCtrl   = TextEditingController();
    final mobileCtrl = TextEditingController();
    final cityCtrl   = TextEditingController();
    final notesCtrl  = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                    Text('➕ Add Telecalling Contact', style: AppStyles.heading2),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Contact Name',
                  hint: 'e.g. Rahul Sharma',
                  controller: nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Mobile Number',
                  hint: '10-digit mobile number',
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Mobile is required';
                    final clean = v.replaceAll(RegExp(r'[^\d]'), '');
                    if (clean.length < 10) return 'Valid 10-digit number required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'City (Optional)',
                  hint: 'e.g. Ahmedabad, Rajkot',
                  controller: cityCtrl,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Notes / Remarks (Optional)',
                  hint: 'e.g. Interested in commercial plots',
                  controller: notesCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await provider.createContact(
                        name: nameCtrl.text.trim(),
                        mobile: mobileCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? '✅ Contact added to pool!' : '❌ Error: ${provider.errorMessage}'),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Move to Inquiry Sheet ──────────────────────────────────────────────────
  void _showMoveToInquirySheet(BuildContext context, TelecallingContactModel contact, TelecallingProvider provider) {
    final reqCtrl   = TextEditingController();
    final notesCtrl = TextEditingController(text: contact.notes);
    final formKey   = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                    Text('🚀 Move to Customer Inquiry', style: AppStyles.heading2),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name, style: AppStyles.heading3),
                          Text('📞 ${contact.mobile}  •  📍 ${contact.city.isNotEmpty ? contact.city : "N/A"}',
                              style: AppStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Customer Requirement *',
                  hint: 'e.g. Looking for 500 sq.yd residential plot in Dholera SIR',
                  controller: reqCtrl,
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requirement is required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Additional Notes',
                  hint: 'Special remarks or notes',
                  controller: notesCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm & Transfer to Inquiries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await provider.moveToInquiry(
                        contactId: contact.id,
                        requirement: reqCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? '🎉 Contact moved to Customer Inquiries!' : '❌ Error: ${provider.errorMessage}'),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<TelecallingProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoading && provider.todaysBatch.isNotEmpty) {
          _initDraftsFromProvider(provider);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: Text('📞 Calls Today (10-Day Cycle)', style: AppStyles.heading3.copyWith(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                tooltip: 'Add Contact',
                onPressed: () => _showAddContactSheet(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh',
                onPressed: () => provider.fetchTodayBatch(),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showAddContactSheet(context, provider),
          ),

          body: provider.isLoading
              ? const LoadingWidget()
              : provider.errorMessage != null
                  ? _buildError(provider)
                  : _buildContent(provider),
        );
      },
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent(TelecallingProvider provider) {
    return Column(
      children: [
        _buildSummaryHeader(provider),
        Expanded(
          child: provider.todaysBatch.isEmpty
              ? _buildEmpty(provider)
              : RefreshIndicator(
                  onRefresh: () => provider.fetchTodayBatch(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: provider.todaysBatch.length,
                    itemBuilder: (context, index) {
                      final contact = provider.todaysBatch[index];
                      return _buildContactCard(contact, provider, index + 1);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ── Summary Header Cards ───────────────────────────────────────────────────
  Widget _buildSummaryHeader(TelecallingProvider provider) {
    final called  = provider.calledTodayCount;
    final target  = provider.dailyTarget;
    final total   = provider.totalContacts;
    final isDone  = target > 0 && called >= target;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatChip(
                label: 'Total Pool',
                value: '$total Numbers',
                icon: Icons.contacts_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'Daily Target',
                value: '$target Calls',
                icon: Icons.track_changes,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: '10-Day Rotation',
                value: provider.dayLabel,
                icon: Icons.loop,
                color: isDone ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Progress:', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '$called / $target Completed',
                style: TextStyle(
                  color: isDone ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: target > 0 ? (called / target).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(isDone ? AppColors.success : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ── Contact Card ───────────────────────────────────────────────────────────
  Widget _buildContactCard(TelecallingContactModel contact, TelecallingProvider provider, int position) {
    final id       = contact.id;
    final log      = provider.todaysLogs[id];
    final isCalled = log != null && log.status != 'pending';

    _draftStatus.putIfAbsent(id, () => log?.status ?? contact.status);
    _remarksCtrls.putIfAbsent(id, () => TextEditingController(text: log?.remarks ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isCalled ? AppColors.success.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCalled ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
          width: isCalled ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: isCalled ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      isCalled ? '✓' : '$position',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name, style: AppStyles.heading3),
                      if (contact.city.isNotEmpty)
                        Text('📍 ${contact.city}', style: AppStyles.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  tooltip: 'Delete Contact',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Contact'),
                        content: Text('Are you sure you want to delete ${contact.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await provider.deleteContact(id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Phone + Direct Dial
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: contact.mobile));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mobile copied'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(contact.mobile, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _makeCall(contact.mobile),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

            if (contact.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${contact.notes}', style: AppStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
            ],

            const Divider(height: 24),

            // Status Dropdown
            DropdownButtonFormField<String>(
              initialValue: _draftStatus[id],
              decoration: InputDecoration(
                labelText: 'Call Outcome Status',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _statusOptions
                  .map((opt) => DropdownMenuItem(
                        value: opt['value'],
                        child: Text(opt['label']!, style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _draftStatus[id] = val);
                }
              },
            ),
            const SizedBox(height: 10),

            // Remarks
            TextField(
              controller: _remarksCtrls[id],
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Remarks (optional)',
                hintText: 'e.g. Call back tomorrow at 4 PM',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),

            // Actions Row (Save + Move to Inquiry)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showMoveToInquirySheet(context, contact, provider),
                  icon: const Icon(Icons.trending_up, size: 16),
                  label: const Text('Move to Inquiry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                provider.isSavingContact(id)
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : ElevatedButton.icon(
                        onPressed: () => _saveLog(id, provider),
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Save Log'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCalled ? AppColors.primaryAccent : AppColors.primary,
                          foregroundColor: isCalled ? AppColors.primaryDark : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmpty(TelecallingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contact_phone_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text('No Telecalling Contacts Found', style: AppStyles.heading3),
            const SizedBox(height: 8),
            const Text(
              'Add telecalling numbers to start the 10-day automated rotation cycle.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddContactSheet(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Telecalling Contact'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildError(TelecallingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load telecalling batch', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(provider.errorMessage ?? 'Unknown error', style: AppStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchTodayBatch(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
