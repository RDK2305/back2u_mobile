import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/claim_provider.dart';
import '../config/theme.dart';
import 'claim_detail_screen.dart';
import 'saved_items_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ClaimProvider _claimProvider = Get.find<ClaimProvider>();

  bool _alreadyClaimed = false;
  bool _checkingClaim = true;
  int? _existingClaimId;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkExistingClaim();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final saved = await SavedItemsScreen.isSaved(widget.item.id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    final nowSaved = await SavedItemsScreen.toggleSave(widget.item.id);
    if (mounted) setState(() => _isSaved = nowSaved);
    Get.snackbar(
      nowSaved ? 'Saved!' : 'Removed',
      nowSaved
          ? 'Item added to your saved list'
          : 'Item removed from saved',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor:
          nowSaved ? AppTheme.successColor : AppTheme.textSecondaryColor,
      colorText: Colors.white,
    );
  }

  Future<void> _checkExistingClaim() async {
    if (widget.item.type.toLowerCase() != 'found') {
      setState(() => _checkingClaim = false);
      return;
    }
    final user = _authProvider.currentUser.value;
    if (user == null) {
      setState(() => _checkingClaim = false);
      return;
    }

    final claims = await _claimProvider.getClaimsForItem(widget.item.id);
    final existing = claims.where((c) => c.claimerId == user.id).toList();
    setState(() {
      _alreadyClaimed = existing.isNotEmpty;
      _existingClaimId = existing.isNotEmpty ? existing.first.id : null;
      _checkingClaim = false;
    });
  }

  bool get _isOwnItem =>
      widget.item.userId == _authProvider.currentUser.value?.id;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero app bar with image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                tooltip: _isSaved ? 'Remove from saved' : 'Save item',
                onPressed: _toggleSave,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.displayImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.displayImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        child: const Icon(Icons.image, size: 64,
                            color: Colors.white30),
                      ),
                      errorWidget: (_, _, _) => _buildImageFallback(),
                    )
                  : _buildImageFallback(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & type badge row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeBadge(item.type),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status & category row
                  Row(
                    children: [
                      _buildChip(item.category, Icons.category_outlined,
                          AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      _buildChip(item.status, Icons.circle,
                          _statusColor(item.status)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Info cards
                  _buildInfoSection(item),
                  const SizedBox(height: 24),
                  // Description
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    Text('Description',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(item.description!,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                  ],
                  // Distinguishing features
                  if (item.distinguishingFeatures != null &&
                      item.distinguishingFeatures!.isNotEmpty) ...[
                    Text('Distinguishing Features',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppTheme.warningColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.warningColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.distinguishingFeatures!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: AppTheme.textPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Action button
                  if (item.type.toLowerCase() == 'found' && !_isOwnItem)
                    _buildClaimButton(),
                  if (_isOwnItem)
                    _buildOwnItemBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 72, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isFound = type.toLowerCase() == 'found';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFound
              ? [AppTheme.successColor, const Color(0xFF34D399)]
              : [AppTheme.errorColor, const Color(0xFFF87171)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFound ? 'FOUND' : 'LOST',
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Item item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            item.locationFound,
            AppTheme.infoColor,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.school_outlined,
            'Campus',
            item.campus,
            AppTheme.primaryColor,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            item.type.toLowerCase() == 'found' ? 'Date Found' : 'Date Lost',
            item.date != null
                ? '${item.date!.day}/${item.date!.month}/${item.date!.year}'
                : 'Not specified',
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    )),
          ],
        ),
      ],
    );
  }

  Widget _buildClaimButton() {
    if (_checkingClaim) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_alreadyClaimed && _existingClaimId != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppTheme.successColor, size: 20),
                const SizedBox(width: 8),
                Text('You have already claimed this item',
                    style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final claim =
                    await _claimProvider.getClaimById(_existingClaimId!);
                if (claim != null && mounted) {
                  Get.to(() => ClaimDetailScreen(claim: claim));
                }
              },
              icon: const Icon(Icons.message_outlined),
              label: const Text('View Claim & Messages'),
            ),
          ),
        ],
      );
    }

    if (widget.item.status.toLowerCase() != 'open') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.textSecondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                color: AppTheme.textSecondaryColor, size: 20),
            const SizedBox(width: 8),
            Text('This item is no longer available',
                style: TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showClaimDialog,
        icon: const Icon(Icons.handshake_outlined),
        label: const Text('This is Mine — Claim It'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildOwnItemBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: AppTheme.infoColor, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'This is your reported item',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimDialog() {
    final descController = TextEditingController();
    final answerController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Submit a Claim',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Describe why this item belongs to you. Be specific to help verification.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Your Description *',
                  hintText: 'e.g., This is my blue wallet, it has a Visa card inside...',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (widget.item.distinguishingFeatures != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Verification: ${widget.item.distinguishingFeatures}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Answer *',
                    hintText: 'Answer the verification question',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final success = await _claimProvider.createClaim(
                      itemId: widget.item.id,
                      verificationNotes: descController.text.trim(),
                      verificationAnswer:
                          answerController.text.trim().isNotEmpty
                              ? answerController.text.trim()
                              : null,
                    );
                    if (success && mounted) {
                      setState(() {
                        _alreadyClaimed = true;
                      });
                      Get.snackbar(
                        'Claim Submitted!',
                        'Your claim has been submitted for review.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.successColor,
                        colorText: Colors.white,
                      );
                    } else if (mounted) {
                      Get.snackbar(
                        'Error',
                        _claimProvider.error.value ?? 'Failed to submit claim',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.errorColor,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text('Submit Claim'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppTheme.successColor;
      case 'claimed':
        return AppTheme.warningColor;
      case 'returned':
        return AppTheme.infoColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
