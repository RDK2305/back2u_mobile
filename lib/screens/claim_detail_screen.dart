import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/claim.dart';
import '../providers/auth_provider.dart';
import '../providers/claim_provider.dart';
import '../config/theme.dart';

class ClaimDetailScreen extends StatefulWidget {
  final Claim claim;
  const ClaimDetailScreen({super.key, required this.claim});

  @override
  State<ClaimDetailScreen> createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ClaimProvider _claimProvider = Get.find<ClaimProvider>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Claim? _claim;
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _claim = widget.claim;
    _loadClaim();
    // Poll for new messages every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadClaim(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadClaim({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    // Fetch claim details + messages separately for reliability
    final updated = await _claimProvider.getClaimById(widget.claim.id);
    final messages = await _claimProvider.getMessages(widget.claim.id);
    if (mounted) {
      final base = updated ?? widget.claim;
      // Merge with freshly-fetched messages
      final merged = Claim(
        id: base.id,
        itemId: base.itemId,
        claimerId: base.claimerId,
        ownerId: base.ownerId,
        status: base.status,
        verificationNotes: base.verificationNotes,
        messages: messages.isNotEmpty ? messages : base.messages,
        createdAt: base.createdAt,
        updatedAt: base.updatedAt,
        claimerName: base.claimerName,
        claimerEmail: base.claimerEmail,
        itemTitle: base.itemTitle,
        itemCategory: base.itemCategory,
        itemImageUrl: base.itemImageUrl,
        itemLocation: base.itemLocation,
        itemType: base.itemType,
      );
      setState(() {
        _claim = merged;
        _isLoading = false;
      });
      if (merged.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final success = await _claimProvider.sendMessage(widget.claim.id, text);
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        setState(() => _claim = _claimProvider.currentClaim.value ?? _claim);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        Get.snackbar('Error', 'Failed to send message',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white);
      }
    }
  }

  Future<void> _cancelClaim() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Claim?'),
        content: const Text(
            'Are you sure you want to cancel this claim? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep Claim')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Claim',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _claimProvider.cancelClaim(widget.claim.id);
      if (success && mounted) {
        Get.back();
        Get.snackbar('Claim Cancelled', 'Your claim has been cancelled.',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final claim = _claim ?? widget.claim;
    final currentUserId = _authProvider.currentUser.value?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Claim Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (claim.status == 'pending' && claim.claimerId == currentUserId)
            PopupMenuButton<String>(
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'cancel',
                    child: Text('Cancel Claim',
                        style: TextStyle(color: Colors.red))),
              ],
              onSelected: (v) {
                if (v == 'cancel') _cancelClaim();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Claim summary card
          _buildClaimSummary(claim),
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : claim.messages.isEmpty
                    ? _buildEmptyMessages()
                    : _buildMessagesList(claim, currentUserId),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildClaimSummary(Claim claim) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.itemTitle ?? 'Item #${claim.itemId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (claim.itemCategory != null)
                      Text(claim.itemCategory!.capitalize!,
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              _buildStatusChip(claim),
            ],
          ),
          const SizedBox(height: 12),
          if (claim.verificationNotes != null && claim.verificationNotes!.isNotEmpty) ...[
            Text('Claim Notes:',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(claim.verificationNotes!,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          Text(
            'Submitted ${_formatDate(claim.createdAt)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 11),
          ),
          // Status message
          const SizedBox(height: 12),
          _buildStatusMessage(claim),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Claim claim) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: claim.statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: claim.statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        claim.statusLabel,
        style: TextStyle(
            color: claim.statusColor,
            fontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }

  Widget _buildStatusMessage(Claim claim) {
    String message;
    IconData icon;
    Color color;

    switch (claim.status.toLowerCase()) {
      case 'pending':
        message =
            'Your claim is being reviewed by security staff. You can message below.';
        icon = Icons.hourglass_empty_outlined;
        color = AppTheme.warningColor;
        break;
      case 'verified':
        message =
            'Your claim has been verified! Please coordinate item pickup via messages.';
        icon = Icons.check_circle_outline;
        color = AppTheme.successColor;
        break;
      case 'rejected':
        message =
            'This claim was not approved. You may submit a new claim with more details.';
        icon = Icons.cancel_outlined;
        color = AppTheme.errorColor;
        break;
      case 'completed':
        message = 'This claim has been completed. Item successfully returned!';
        icon = Icons.done_all_outlined;
        color = AppTheme.infoColor;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 52, color: AppTheme.textSecondaryColor),
          const SizedBox(height: 12),
          Text('No messages yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Send a message to the finder/reporter',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMessagesList(Claim claim, int? currentUserId) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: claim.messages.length,
      itemBuilder: (ctx, i) {
        final msg = claim.messages[i];
        final isMe = msg.senderId == currentUserId;
        return _buildMessageBubble(msg, isMe);
      },
    );
  }

  Widget _buildMessageBubble(ClaimMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(msg.senderName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryLightColor
                        ],
                      )
                    : null,
                color: isMe ? null : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [AppTheme.shadowSmall],
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color,
                    fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                _formatMessageTime(msg.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final canMessage = _claim?.status != 'rejected' &&
        _claim?.status != 'completed';

    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 8,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: canMessage,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: canMessage
                    ? 'Type a message...'
                    : 'Messaging not available',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: canMessage
                  ? LinearGradient(colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLightColor
                    ])
                  : null,
              color: canMessage ? null : AppTheme.borderColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: canMessage && !_isSending ? _sendMessage : null,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatMessageTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
