import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../providers/item_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  State<ReportLostItemScreen> createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _featuresController = TextEditingController();

  String _category = AppConstants.itemCategories.first;
  String _campus = AppConstants.campuses.first;
  DateTime _dateLost = DateTime.now();
  File? _imageFile;
  bool _isLoading = false;
  bool _gettingLocation = false;

  late ItemProvider _itemProvider;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _itemProvider = Get.find<ItemProvider>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  // ─── Image Picker ─────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file != null) {
        setState(() => _imageFile = File(file.path));
        _toast('Image selected', isSuccess: true);
      }
    } catch (e) {
      _toast('Could not pick image: $e', isError: true);
    }
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Add Photo',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _imageTile(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _imageTile(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: AppTheme.infoColor,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imageTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ─── Location ─────────────────────────────────────────────────────────────
  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _locationController.text =
              '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        });
        _toast('Location captured', isSuccess: true);
      } else if (status.isPermanentlyDenied) {
        _toast('Location permission denied. Enable in Settings.', isError: true);
        openAppSettings();
      } else {
        _toast('Location permission denied', isWarning: true);
      }
    } catch (e) {
      _toast('Could not get location: $e', isError: true);
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  // ─── Date Picker ──────────────────────────────────────────────────────────
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateLost,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateLost = picked);
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _toast('Please fill in all required fields', isWarning: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await _itemProvider.createLostItem(
      title: _titleController.text.trim(),
      category: _category,
      description: _descController.text.trim(),
      locationLost: _locationController.text.trim(),
      campus: _campus,
      dateLost: _dateLost,
      distinguishingFeatures: _featuresController.text.trim().isEmpty
          ? null
          : _featuresController.text.trim(),
      imagePath: _imageFile?.path,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Get.snackbar(
        '✓ Report Submitted',
        'Your lost item has been reported. We\'ll notify you if a match is found!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
      // Go back to home (main screen) after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Get.offAllNamed('/main');
    } else {
      _toast(
        _itemProvider.error.value ?? 'Failed to submit. Please try again.',
        isError: true,
      );
    }
  }

  void _toast(String msg, {bool isError = false, bool isSuccess = false, bool isWarning = false}) {
    Color bg = AppTheme.infoColor;
    if (isError) bg = AppTheme.errorColor;
    if (isSuccess) bg = AppTheme.successColor;
    if (isWarning) bg = AppTheme.warningColor;
    Get.snackbar(
      isError ? 'Error' : isSuccess ? 'Success' : isWarning ? 'Warning' : 'Info',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Report Lost Item'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_off_outlined,
                        color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fill in the details of what you lost. We\'ll help match it with found items.',
                        style: TextStyle(
                            color: AppTheme.errorColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Item Title ──────────────────────────────────────────────────
              _sectionLabel('Item Details'),
              const SizedBox(height: 10),
              _buildField(
                controller: _titleController,
                label: 'Item Title *',
                hint: 'e.g., Black Leather Wallet',
                icon: Icons.label_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 3) return 'Min. 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Category ────────────────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _fieldDecoration(
                    label: 'Category *', icon: Icons.category_outlined),
                items: AppConstants.itemCategories
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0].toUpperCase() + c.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 14),

              // ── Description ─────────────────────────────────────────────────
              _buildField(
                controller: _descController,
                label: 'Description *',
                hint: 'Describe the item in detail',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Distinguishing Features ─────────────────────────────────────
              _buildField(
                controller: _featuresController,
                label: 'Distinguishing Features (optional)',
                hint: 'e.g., scratched back, red strap, initials JK',
                icon: Icons.info_outline,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // ── Location ────────────────────────────────────────────────────
              _sectionLabel('Where & When'),
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: _fieldDecoration(
                        label: 'Location Lost *',
                        hint: 'Building, floor, or area',
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Location is required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: _gettingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.my_location,
                              color: AppTheme.primaryColor),
                      tooltip: 'Use GPS location',
                      onPressed: _gettingLocation ? null : _getLocation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Campus ──────────────────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _campus,
                decoration: _fieldDecoration(
                    label: 'Campus *', icon: Icons.school_outlined),
                items: AppConstants.campuses
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _campus = v!),
                validator: (v) => v == null ? 'Select a campus' : null,
              ),
              const SizedBox(height: 14),

              // ── Date Lost ───────────────────────────────────────────────────
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Lost',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor)),
                            const SizedBox(height: 2),
                            Text(
                              '${_dateLost.day}/${_dateLost.month}/${_dateLost.year}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_calendar_outlined,
                          color: AppTheme.textSecondaryColor, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Photo ────────────────────────────────────────────────────────
              _sectionLabel('Photo (optional)'),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _showImageSheet,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.borderColor,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(14),
                    color: AppTheme.backgroundColor,
                  ),
                  child: _imageFile != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _imageFile = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 38,
                                color: AppTheme.textSecondaryColor),
                            const SizedBox(height: 8),
                            Text('Tap to add photo',
                                style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 13)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isLoading ? 'Submitting...' : 'Submit Lost Item Report',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _fieldDecoration(label: label, hint: hint, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
