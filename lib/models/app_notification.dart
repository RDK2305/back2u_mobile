import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? relatedItemId;
  final int? relatedClaimId;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.relatedItemId,
    this.relatedClaimId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      type: map['type'] ?? 'general',
      title: map['title'] ?? _getDefaultTitle(map['type'] ?? ''),
      message: map['message'] ?? '',
      isRead: map['read'] == 1 || map['read'] == true || map['is_read'] == 1 || map['is_read'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      relatedItemId: map['item_id'] ?? map['related_item_id'],
      relatedClaimId: map['claim_id'] ?? map['related_claim_id'],
    );
  }

  static String _getDefaultTitle(String type) {
    switch (type) {
      case 'claim_submission':
      case 'claim_submitted':
        return 'New Claim Submitted';
      case 'claim_approved':
        return 'Claim Approved';
      case 'claim_rejected':
        return 'Claim Rejected';
      case 'claim_completed':
        return 'Claim Completed';
      case 'item_match':
        return 'Possible Match Found';
      case 'message':
      case 'new_message':
        return 'New Message';
      default:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (type) {
      case 'claim_submission':
      case 'claim_submitted':
        return Icons.assignment;
      case 'claim_approved':
        return Icons.check_circle;
      case 'claim_rejected':
        return Icons.cancel;
      case 'claim_completed':
        return Icons.done_all;
      case 'item_match':
        return Icons.compare_arrows;
      case 'message':
      case 'new_message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'claim_approved':
      case 'claim_completed':
        return const Color(0xFF10B981);
      case 'claim_rejected':
        return const Color(0xFFEF4444);
      case 'claim_submission':
      case 'claim_submitted':
      case 'message':
      case 'new_message':
        return const Color(0xFF3B82F6);
      case 'item_match':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
