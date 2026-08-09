import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../models/inquiry_model.dart';
import '../../../models/call_log_model.dart';
import '../../../providers/call_log_provider.dart';
import '../../../widgets/loading_widget.dart';

/**
 * Calls Today Screen (Super Admin Only)
 * DHOLERA REAL ESTATE — Daily rotating 10-contact follow-up list
 *
 * Batch logic (computed in CallLogProvider):
 *   cycleLength = ceil(total / 10)
 *   dayIndex    = daysSince(2026-01-01) % cycleLength
 *   batch[i]    = allInquiries[(dayIndex*10 + i) % total]  ← circular
 */
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
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallLogProvider>().loadData();
    });
  }

  @override
  void dispose() {
    for (final ctrl in _remarksCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Initialise draft state from provider (after load) ──────────────────────
  void _initDraftsFromProvider(CallLogProvider provider) {
    for (final inquiry in provider.todaysBatch) {
      final id  = inquiry.id;
      final log = provider.getLogFor(id);
      if (!_draftStatus.containsKey(id)) {
        _draftStatus[id] = log?.status ?? 'pending';
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
  Future<void> _saveLog(int inquiryId, CallLogProvider provider) async {
    final status  = _draftStatus[inquiryId] ?? 'pending';
    final remarks = _remarksCtrls[inquiryId]?.text.trim() ?? '';
    final success = await provider.saveLog(
      inquiryId: inquiryId,
      status:    status,
      remarks:   remarks,
    );
    if (!mounted) return;

    final String message;
    if (success) {
      message = '✅ Saved successfully';
    } else if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty) {
      message = '❌ Error: ${provider.errorMessage}';
    } else {
      message = '❌ Failed to save. Please make sure the latest server code is deployed via git pull.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<CallLogProvider>(
      builder: (context, provider, _) {
        // Sync draft state when data loads
        if (!provider.isLoading && provider.todaysBatch.isNotEmpty) {
          _initDraftsFromProvider(provider);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: Text('📞 Calls Today', style: AppStyles.heading3.copyWith(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh',
                onPressed: () => provider.loadData(),
              ),
            ],
          ),

          body: provider.isLoading
              ? const LoadingWidget()
              : provider.errorMessage != null
                  ? _buildError(provider)
                  : provider.todaysBatch.isEmpty
                      ? _buildEmpty()
                      : _buildContent(provider),
        );
      },
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent(CallLogProvider provider) {
    return Column(
      children: [
        _buildHeader(provider),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadData(silent: true),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: provider.todaysBatch.length,
              itemBuilder: (context, index) {
                final inquiry = provider.todaysBatch[index];
                return _buildContactCard(inquiry, provider, index + 1);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Header: progress bar + day label ──────────────────────────────────────
  Widget _buildHeader(CallLogProvider provider) {
    final called       = provider.calledTodayCount;
    final totalInBatch = provider.todaysBatch.length;
    final isDone       = totalInBatch > 0 && called == totalInBatch;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(provider.dayLabel,
                  style: AppStyles.heading3.copyWith(color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$called / $totalInBatch Called',
                  style: TextStyle(
                    color:      isDone ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize:   13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:            provider.cycleProgress,
              minHeight:        6,
              backgroundColor:  AppColors.border,
              valueColor:       const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.batchRangeLabel,
            style: AppStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // ── Individual contact card ────────────────────────────────────────────────
  Widget _buildContactCard(InquiryModel inquiry, CallLogProvider provider, int position) {
    final id      = inquiry.id;
    final isCalled = provider.isCalled(id);
    final log      = provider.getLogFor(id);

    // Init draft if not already set
    _draftStatus.putIfAbsent(id, () => log?.status ?? 'pending');
    _remarksCtrls.putIfAbsent(id, () => TextEditingController(text: log?.remarks ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isCalled
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCalled ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
          width: isCalled ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: position + name + city + called badge ───────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Position circle
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color:        isCalled ? AppColors.success : AppColors.primary,
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
                      Text(inquiry.customerName, style: AppStyles.heading3),
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${inquiry.customerCity}',
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isCalled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:        AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      log?.statusLabel ?? 'Called',
                      style: const TextStyle(
                          color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Mobile + Call button ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: inquiry.customerMobile));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Number copied'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          inquiry.customerMobile,
                          style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _makeCall(inquiry.customerMobile),
                  icon:  const Icon(Icons.call, size: 16),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:         const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle:       const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),

            // ── Requirement ─────────────────────────────────────────────────
            if ((inquiry.requirement ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_outlined, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      inquiry.requirement!,
                      style: AppStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 24),

            // ── Status dropdown ──────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value:       _draftStatus[id],
              decoration:  InputDecoration(
                labelText:       'Call Status',
                labelStyle:      const TextStyle(fontSize: 13),
                contentPadding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   const BorderSide(color: AppColors.border),
                ),
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

            // ── Remarks ──────────────────────────────────────────────────────
            TextField(
              controller: _remarksCtrls[id],
              maxLines:   2,
              decoration: InputDecoration(
                labelText:      'Remarks (optional)',
                labelStyle:     const TextStyle(fontSize: 13),
                hintText:       'e.g. Very interested, call back after 5pm',
                hintStyle:      const TextStyle(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Save button ──────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: provider.isSavingInquiry(id)
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _saveLog(id, provider),
                      icon:  const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCalled ? AppColors.success : AppColors.primaryAccent,
                        foregroundColor: isCalled ? Colors.white : AppColors.primaryDark,
                        padding:         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle:       const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError(CallLogProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.signal_wifi_off_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(provider.errorMessage ?? 'Unknown error',
                style: AppStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadData(),
              icon:  const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No inquiries found.\nAdd customer inquiries first.',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
