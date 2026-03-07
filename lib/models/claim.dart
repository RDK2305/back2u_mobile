import 'package:flutter/material.dart';

class ClaimMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String senderName;
  final String content; // maps from DB 'message' field
  final bool isRead;
  final DateTime createdAt;

  ClaimMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ClaimMessage.fromMap(Map<String, dynamic> map) {
    return ClaimMessage(
      id: map['id'] ?? 0,
      senderId: map['sender_id'] ?? 0,
      receiverId: map['receiver_id'] ?? 0,
      senderName: map['sender_name'] ??
          (map['sender'] != null
              ? '${map['sender']['first_name'] ?? ''} ${map['sender']['last_name'] ?? ''}'.trim()
              : 'Unknown'),
      content: map['message'] ?? map['content'] ?? '',
      isRead: map['read'] == 1 || map['read'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class Claim {
  final int id;
  final int itemId;
  final int claimerId;
  final int? ownerId;
  final String status; // pending, verified, rejected, completed
  final String? verificationNotes; // DB field: verification_notes
  final List<ClaimMessage> messages;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined fields from API
  final String? claimerName;
  final String? claimerEmail;
  final String? itemTitle;
  final String? itemCategory;
  final String? itemImageUrl;
  final String? itemLocation;
  final String? itemType;

  Claim({
    required this.id,
    required this.itemId,
    required this.claimerId,
    this.ownerId,
    required this.status,
    this.verificationNotes,
    this.messages = const [],
    required this.createdAt,
    this.updatedAt,
    this.claimerName,
    this.claimerEmail,
    this.itemTitle,
    this.itemCategory,
    this.itemImageUrl,
    this.itemLocation,
    this.itemType,
  });

  factory Claim.fromMap(Map<String, dynamic> map) {
    List<ClaimMessage> msgs = [];
    if (map['messages'] != null && map['messages'] is List) {
      msgs = (map['messages'] as List)
          .map((m) => ClaimMessage.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    return Claim(
      id: map['id'] ?? 0,
      itemId: map['item_id'] ?? 0,
      claimerId: map['claimer_id'] ?? map['user_id'] ?? 0,
      ownerId: map['owner_id'],
      status: map['status'] ?? 'pending',
      verificationNotes: map['verification_notes'] ?? map['description'],
      messages: msgs,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      claimerName: map['claimer_name'] ??
          (map['claimer'] != null
              ? '${map['claimer']['first_name'] ?? ''} ${map['claimer']['last_name'] ?? ''}'.trim()
              : null),
      claimerEmail: map['claimer_email'] ??
          (map['claimer'] != null ? map['claimer']['email'] : null),
      itemTitle: map['item_title'] ??
          (map['item'] != null ? map['item']['title'] : null),
      itemCategory: map['item_category'] ??
          (map['item'] != null ? map['item']['category'] : null),
      itemImageUrl: map['item_image_url'] ??
          (map['item'] != null ? map['item']['image_url'] : null),
      itemLocation: map['item_location'] ??
          (map['item'] != null ? map['item']['location_found'] : null),
      itemType: map['item_type'] ??
          (map['item'] != null ? map['item']['type'] : null),
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'verified':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
