import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'item_detail_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  static const String _savedKey = 'saved_item_ids';

  // ── Public static helpers (called from other screens) ─────────────────────

  static Future<List<int>> getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Toggle saved state. Returns true if the item is now saved.
  static Future<bool> toggleSave(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getSavedIds();
    final wasSaved = ids.contains(itemId);
    if (wasSaved) {
      ids.remove(itemId);
    } else {
      ids.add(itemId);
    }
    await prefs.setString(_savedKey, jsonEncode(ids));
    return !wasSaved;
  }

  static Future<bool> isSaved(int itemId) async {
    final ids = await getSavedIds();
    return ids.contains(itemId);
  }

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  List<Item> _savedItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  // ── Data Loading ─────────────────────────────────────────────────────────────

  Future<void> _loadSavedItems() async {
    setState(() => _isLoading = true);
    try {
      final token = StorageService.getToken() ?? '';
      final ids = await SavedItemsScreen.getSavedIds();
      if (ids.isEmpty) {
        setState(() {
          _savedItems = [];
          _isLoading = false;
        });
        return;
      }
      final futures =
          ids.map((id) => _api.getItem(token, id).then<Item?>((v) => v).catchError((_) => null));
      final results = await Future.wait(futures);
      setState(() {
        _savedItems = results.whereType<Item>().toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _savedItems = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await SavedItemsScreen.getSavedIds();
    ids.remove(itemId);
    await prefs.setString(SavedItemsScreen._savedKey, jsonEncode(ids));
    setState(() => _savedItems.removeWhere((item) => item.id == itemId));
    Get.snackbar(
      'Removed',
      'Item removed from saved',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Saved?'),
        content: const Text(
            'This will remove all saved items. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SavedItemsScreen._savedKey);
      setState(() => _savedItems = []);
      Get.snackbar(
        'Cleared',
        'All saved items removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Items${_savedItems.isEmpty ? '' : ' (${_savedItems.length})'}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (!_isLoading && _savedItems.isNotEmpty)
            TextButton(
              onPressed: _confirmClearAll,
              child: const Text('Clear All',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedItems.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadSavedItems,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _savedItems.length,
                    itemBuilder: (context, i) =>
                        _buildItemCard(_savedItems[i]),
                  ),
                ),
    );
  }

  Widget _buildItemCard(Item item) {
    final isFound = item.type.toLowerCase() == 'found';
    final typeColor =
        isFound ? AppTheme.successColor : AppTheme.errorColor;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_remove, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => _removeItem(item.id),
      child: GestureDetector(
        onTap: () async {
          await Get.to(() => ItemDetailScreen(item: item));
          // Refresh in case user un-saved the item from detail page
          _loadSavedItems();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppTheme.shadowSmall],
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(item.category),
                  color: typeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + type badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isFound ? 'Found' : 'Lost',
                            style: TextStyle(
                                color: typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13,
                            color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.locationFound,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Status dot
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _statusColor(item.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.status.capitalize ?? item.status,
                          style: TextStyle(
                              fontSize: 12,
                              color: _statusColor(item.status),
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.borderColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Remove bookmark button
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined,
                    color: AppTheme.errorColor),
                tooltip: 'Remove from saved',
                onPressed: () => _removeItem(item.id),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 88, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              'No saved items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the bookmark icon on any item\nto save it here for later',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondaryColor, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.search),
              label: const Text('Browse Items'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Utility ──────────────────────────────────────────────────────────────────

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices_outlined;
      case 'bags':
        return Icons.backpack_outlined;
      case 'books':
        return Icons.menu_book_outlined;
      case 'clothing':
        return Icons.checkroom_outlined;
      case 'keys':
        return Icons.key_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'id card':
        return Icons.badge_outlined;
      case 'jewelry':
        return Icons.diamond_outlined;
      case 'sports':
        return Icons.sports_basketball_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
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
