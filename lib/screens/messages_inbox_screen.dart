import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'claim_detail_screen.dart';
import '../models/claim.dart';

/// Messages Inbox Screen — shows all claim-based conversations for the student.
/// Tapping a conversation opens the ClaimDetailScreen (which has the full chat UI).
class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen> {
  final ApiService _api = ApiService();
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allConversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInbox();
    _searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInbox() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = AuthService().getToken() ?? '';
      final raw = await _api.getMessageInbox(token);

      // Group by claim_id — keep only the latest message per claim
      final Map<int, Map<String, dynamic>> grouped = {};
      for (final msg in raw) {
        final claimId = msg['claim_id'] as int? ?? 0;
        final existing = grouped[claimId];
        if (existing == null) {
          grouped[claimId] = Map<String, dynamic>.from(msg);
        } else {
          // Keep the more recent one
          final existingDate =
              DateTime.tryParse(existing['created_at']?.toString() ?? '') ??
                  DateTime(2000);
          final newDate =
              DateTime.tryParse(msg['created_at']?.toString() ?? '') ??
                  DateTime(2000);
          if (newDate.isAfter(existingDate)) {
            grouped[claimId] = Map<String, dynamic>.from(msg);
          }
        }
      }

      final conversations = grouped.values.toList()
        ..sort((a, b) {
          final da =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime(2000);
          final db =
              DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                  DateTime(2000);
          return db.compareTo(da);
        });

      if (mounted) {
        setState(() {
          _allConversations = conversations;
          _filteredConversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterConversations() {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredConversations = _allConversations);
      return;
    }
    setState(() {
      _filteredConversations = _allConversations.where((c) {
        final item = (c['item_title'] ?? '').toString().toLowerCase();
        final sender = (c['sender_name'] ?? '').toString().toLowerCase();
        final receiver = (c['receiver_name'] ?? '').toString().toLowerCase();
        final msg = (c['message'] ?? '').toString().toLowerCase();
        return item.contains(q) ||
            sender.contains(q) ||
            receiver.contains(q) ||
            msg.contains(q);
      }).toList();
    });
  }

  Future<void> _openConversation(Map<String, dynamic> convo) async {
    final claimId = convo['claim_id'] as int? ?? 0;
    final token = AuthService().getToken() ?? '';

    // Show loading briefly then navigate
    final claimData = await _api.getClaim(token, claimId);
    final claim = Claim.fromMap(claimData);

    if (mounted) {
      await Get.to(() => ClaimDetailScreen(claim: claim));
      // Refresh inbox on return
      _loadInbox();
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  String _getOtherPersonName(Map<String, dynamic> convo) {
    final currentUserId = _authProvider.currentUser.value?.id;
    final senderId = convo['sender_id'] as int?;
    if (senderId == currentUserId) {
      return convo['receiver_name'] ?? convo['receiver_first_name'] ?? 'User';
    }
    return convo['sender_name'] ?? convo['sender_first_name'] ?? 'User';
  }

  bool _hasUnread(Map<String, dynamic> convo) {
    final currentUserId = _authProvider.currentUser.value?.id;
    final receiverId = convo['receiver_id'] as int?;
    final isRead = convo['is_read'] as bool? ?? true;
    return !isRead && receiverId == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInbox,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _filterConversations();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _filteredConversations.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _loadInbox,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _filteredConversations.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                indent: 72,
                                color: AppTheme.borderColor,
                              ),
                              itemBuilder: (ctx, i) {
                                final convo = _filteredConversations[i];
                                return _buildConversationTile(convo);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> convo) {
    final otherName = _getOtherPersonName(convo);
    final unread = _hasUnread(convo);
    final itemTitle = convo['item_title'] ?? 'Unknown Item';
    final lastMsg = convo['message'] ?? '';
    final timeStr = _timeAgo(convo['created_at']?.toString());
    final currentUserId = _authProvider.currentUser.value?.id;
    final senderId = convo['sender_id'] as int?;
    final isSent = senderId == currentUserId;
    final initials = otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';

    return InkWell(
      onTap: () => _openConversation(convo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: unread
            ? AppTheme.primaryColor.withValues(alpha: 0.04)
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: TextStyle(
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                          fontWeight: unread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📦 $itemTitle',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryLightColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isSent ? 'You: $lastMsg' : lastMsg,
                    style: TextStyle(
                      fontSize: 13,
                      color: unread
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textSecondaryColor,
                      fontWeight:
                          unread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final hasSearch = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.mark_chat_unread_outlined,
              size: 72,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No conversations found' : 'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'Your conversations with claim participants\nwill appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/my-claims'),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('View My Claims'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off,
                size: 64,
                color: AppTheme.errorColor.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('Failed to load messages',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadInbox,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
