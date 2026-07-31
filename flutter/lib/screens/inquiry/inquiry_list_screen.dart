import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';
import '../../providers/inquiry_provider.dart';
import '../../models/inquiry_model.dart';
import '../../widgets/loading_widget.dart';

/**
 * Customer Inquiry Management Screen (Super Admin Only)
 * DHOLERA REAL ESTATE — Name, City, Mobile, Requirement + Direct Call & PDF Export
 */
class InquiryListScreen extends StatefulWidget {
  const InquiryListScreen({super.key});

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InquiryProvider>().fetchInquiries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot make call to $phoneNumber')),
        );
      }
    }
  }

  Future<void> _exportPdfReport() async {
    final Uri exportUri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.inquiryExportPdf}');
    if (await canLaunchUrl(exportUri)) {
      await launchUrl(exportUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch PDF export page.')),
        );
      }
    }
  }

  void _showAddInquirySheet() {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final reqCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '➕ Add Customer Inquiry',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter customer name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer City *',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter customer city' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number *',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter mobile number' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reqCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Property Requirement *',
                      hintText: 'e.g. Looking for 500 Sq Yard Commercial plot near 55 Mtr DP Road',
                      prefixIcon: Icon(Icons.architecture),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter customer property requirement' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes / Remarks (Optional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Save Inquiry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          final success = await context.read<InquiryProvider>().createInquiry(
                            name: nameCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            mobile: mobileCtrl.text.trim(),
                            requirement: reqCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Inquiry saved successfully!' : 'Failed to save inquiry.'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Inquiries'),
        actions: [
          IconButton(
            tooltip: 'Export PDF Report',
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _exportPdfReport,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<InquiryProvider>().fetchInquiries(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_ic_call),
        label: const Text('Add Inquiry'),
        onPressed: _showAddInquirySheet,
      ),
      body: Consumer<InquiryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search name, city, mobile, requirement...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.fetchInquiries(search: '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onSubmitted: (val) => provider.fetchInquiries(search: val.trim()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('PDF'),
                      onPressed: _exportPdfReport,
                    ),
                  ],
                ),
              ),

              // Inquiry List Content
              Expanded(
                child: provider.isLoading
                    ? const LoadingWidget(message: 'Loading Inquiries...')
                    : provider.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 10),
                                  Text(
                                    provider.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () => provider.fetchInquiries(),
                                    child: const Text('Retry'),
                                  )
                                ],
                              ),
                            ),
                          )
                        : provider.inquiries.isEmpty
                            ? const Center(
                                child: Text(
                                  'No customer inquiries found.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                itemCount: provider.inquiries.length,
                                itemBuilder: (ctx, index) {
                                  final inq = provider.inquiries[index];
                                  return _buildInquiryCard(inq);
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInquiryCard(InquiryModel inquiry) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    inquiry.customerName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(inquiry),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_city, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  inquiry.customerCity,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                const Spacer(),
                if (inquiry.createdAt != null)
                  Text(
                    inquiry.createdAt!.split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),

            // Requirement Display Badge
            if (inquiry.requirement != null && inquiry.requirement!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.architecture, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Requirement: ${inquiry.requirement!}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone_android, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  inquiry.customerMobile,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Spacer(),
                // Direct Call Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('CALL NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _makePhoneCall(inquiry.customerMobile),
                ),
              ],
            ),
            if (inquiry.notes != null && inquiry.notes!.isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      inquiry.notes!,
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(InquiryModel inquiry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Inquiry?'),
        content: Text('Are you sure you want to delete inquiry for "${inquiry.customerName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<InquiryProvider>().deleteInquiry(inquiry.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Inquiry deleted.' : 'Failed to delete inquiry.'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
