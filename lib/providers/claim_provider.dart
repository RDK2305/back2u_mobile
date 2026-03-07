import 'package:get/get.dart';
import '../models/claim.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ClaimProvider extends GetxController {
  final _apiService = ApiService();
  final _authService = AuthService();

  final claims = <Claim>[].obs;
  final currentClaim = Rx<Claim?>(null);
  final isLoading = false.obs;
  final error = Rx<String?>(null);

  /// Fetch all claims for the current user
  Future<void> fetchMyClaims() async {
    try {
      isLoading.value = true;
      error.value = null;

      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Not authenticated';
        return;
      }

      final data = await _apiService.getMyClaims(token);
      claims.value = data.map((c) => Claim.fromMap(c as Map<String, dynamic>)).toList();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get single claim by ID (includes messages)
  Future<Claim?> getClaimById(int claimId) async {
    try {
      isLoading.value = true;
      error.value = null;

      final token = _authService.getToken();
      if (token == null) return null;

      final data = await _apiService.getClaim(token, claimId);
      final claimData = data['data'] ?? data;
      final claim = Claim.fromMap(claimData as Map<String, dynamic>);
      currentClaim.value = claim;
      return claim;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new claim on a found item
  Future<bool> createClaim({
    required int itemId,
    String? verificationNotes,
    String? verificationAnswer,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;

      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Not authenticated';
        return false;
      }

      final claimData = {
        'item_id': itemId,
        if (verificationNotes != null && verificationNotes.trim().isNotEmpty)
          'verification_notes': verificationNotes.trim(),
        if (verificationAnswer != null && verificationAnswer.trim().isNotEmpty)
          'verification_answer': verificationAnswer.trim(),
      };

      await _apiService.createClaim(token, claimData);
      await fetchMyClaims();
      return true;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel/delete a pending claim
  Future<bool> cancelClaim(int claimId) async {
    try {
      isLoading.value = true;
      error.value = null;

      final token = _authService.getToken();
      if (token == null) return false;

      await _apiService.deleteClaim(token, claimId);
      claims.removeWhere((c) => c.id == claimId);
      if (currentClaim.value?.id == claimId) {
        currentClaim.value = null;
      }
      return true;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a message in a claim conversation (uses separate /messages endpoint)
  Future<bool> sendMessage(int claimId, String message, {int? receiverId}) async {
    try {
      error.value = null;

      final token = _authService.getToken();
      if (token == null) return false;

      // Determine receiver: if sender is claimer → send to owner, else to claimer
      final claim = claims.firstWhereOrNull((c) => c.id == claimId)
          ?? currentClaim.value;
      final rid = receiverId ?? claim?.ownerId ?? 0;

      await _apiService.sendClaimMessage(token, claimId, rid, message.trim());

      // Refresh messages after send
      await _refreshMessages(token, claimId);
      return true;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// Refresh just the messages for the current claim
  Future<void> _refreshMessages(String token, int claimId) async {
    try {
      final msgs = await _apiService.getClaimMessages(token, claimId);
      final claim = currentClaim.value;
      if (claim != null && claim.id == claimId) {
        final parsedMsgs = msgs
            .map((m) => ClaimMessage.fromMap(m as Map<String, dynamic>))
            .toList();
        currentClaim.value = Claim(
          id: claim.id,
          itemId: claim.itemId,
          claimerId: claim.claimerId,
          ownerId: claim.ownerId,
          status: claim.status,
          verificationNotes: claim.verificationNotes,
          messages: parsedMsgs,
          createdAt: claim.createdAt,
          updatedAt: claim.updatedAt,
          claimerName: claim.claimerName,
          claimerEmail: claim.claimerEmail,
          itemTitle: claim.itemTitle,
          itemCategory: claim.itemCategory,
          itemImageUrl: claim.itemImageUrl,
          itemLocation: claim.itemLocation,
          itemType: claim.itemType,
        );
      }
    } catch (_) {}
  }

  /// Load messages for a specific claim ID
  Future<List<ClaimMessage>> getMessages(int claimId) async {
    try {
      final token = _authService.getToken();
      if (token == null) return [];
      final data = await _apiService.getClaimMessages(token, claimId);
      return data.map((m) => ClaimMessage.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get claims for a specific item (to check if user already claimed)
  Future<List<Claim>> getClaimsForItem(int itemId) async {
    try {
      final token = _authService.getToken();
      if (token == null) return [];

      final data = await _apiService.getItemClaims(token, itemId);
      return data.map((c) => Claim.fromMap(c as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  void clearError() => error.value = null;
}
