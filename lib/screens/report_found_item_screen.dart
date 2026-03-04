import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../providers/item_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class ReportFoundItemScreen extends StatefulWidget {
  const ReportFoundItemScreen({super.key});

  @override
  State<ReportFoundItemScreen> createState() => _ReportFoundItemScreenState();
}

class _ReportFoundItemScreenState extends State<ReportFoundItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _featuresController = TextEditingController();

  String _category = 'wallet';
  String _campus = 'Main';
  DateTime _dateFound = DateTime.now();
  String? _imagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  late ItemProvider _itemProvider;

  @override
  void initState() {
    super.initState();
    _itemProvider = Get.find<ItemProvider>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() => _imagePath = pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Could not pick image: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _locationController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to get location',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFound,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateFound = picked);
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath == null) {
      Get.snackbar('Image Required',
          'Please add a photo of the found item for verification.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warningColor,
          colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    final success = await _itemProvider.createFoundItem(
      title: _titleController.text.trim(),
      category: _category.toLowerCase(),
      description: _descriptionController.text.trim(),
      locationFound: _locationController.text.trim(),
      campus: _campus,
      dateFound: _dateFound,
      distinguishingFeatures: _featuresController.text.trim().isNotEmpty
          ? _featuresController.text.trim()
          : null,
      imagePath: _imagePath,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Get.snackbar(
        '✓ Report Submitted',
        'Found item reported! Thank you for helping the community.',
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
      Get.snackbar('Error', _itemProvider.error.value ?? 'Failed to submit',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Found Item'),
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism_outlined,
                        color: AppTheme.successColor, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Found something? Help reunite it with its owner!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Image (required)
              Text('Photo *',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showImagePickerOptions(),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _imagePath != null
                          ? AppTheme.successColor
                          : AppTheme.borderColor,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_imagePath!),
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _imagePath = null),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
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
                            Icon(Icons.add_a_photo_outlined,
                                size: 48,
                                color: AppTheme.successColor),
                            const SizedBox(height: 8),
                            Text('Add a photo (required)',
                                style: TextStyle(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Title *',
                  hintText: 'e.g., Black Wallet, Blue Backpack...',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().length < 3 ? 'Minimum 3 chars' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the item in detail',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.itemCategories
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c.capitalize!)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              // Campus
              DropdownButtonFormField<String>(
                initialValue: _campus,
                decoration: const InputDecoration(
                  labelText: 'Campus *',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: AppConstants.campuses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _campus = v!),
              ),
              const SizedBox(height: 16),

              // Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location Found *',
                        hintText: 'Building, floor, area...',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _getLocation,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Use GPS',
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date found
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date Found',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor)),
                          Text(
                            '${_dateFound.day}/${_dateFound.month}/${_dateFound.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar_outlined,
                          color: AppTheme.textSecondaryColor, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Distinguishing features
              TextFormField(
                controller: _featuresController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Distinguishing Features (Optional)',
                  hintText: 'Any unique marks, brand, color details...',
                  prefixIcon: Icon(Icons.star_outline),
                ),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitReport,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Photo',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceTile(
                    Icons.camera_alt_outlined, 'Camera', ImageSource.camera),
                _imageSourceTile(
                    Icons.photo_library_outlined, 'Gallery', ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceTile(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickImage(source);
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
