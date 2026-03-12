import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/claim_provider.dart';
import '../models/claim.dart';
import '../config/theme.dart';
import 'claim_detail_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen>
    with SingleTickerProviderStateMixin {
  final ClaimProvider _claimProvider = Get.find<ClaimProvider>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _claimProvider.fetchMyClaims();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Claim> _filterByStatus(String status) {
    if (status == 'all') return _claimProvider.claims;
    return _claimProvider.claims
        .where((c) => c.status.toLowerCase() == status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Get.back(),
              )
            : null,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Verified'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Obx(() {
        if (_claimProvider.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildClaimsList(_filterByStatus('all')),
            _buildClaimsList(_filterByStatus('pending')),
            _buildClaimsList(_filterByStatus('verified')),
            _buildClaimsList(_filterByStatus('completed')),
          ],
        );
      }),
    );
  }

  Widget _buildClaimsList(List<Claim> claims) {
    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('No claims here',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    )),
            const SizedBox(height: 8),
            Text('Browse found items and submit a claim',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _claimProvider.fetchMyClaims(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: claims.length,
        itemBuilder: (ctx, i) => _buildClaimCard(claims[i]),
      ),
    );
  }

  Widget _buildClaimCard(Claim claim) {
    return GestureDetector(
      onTap: () async {
        final updated = await _claimProvider.getClaimById(claim.id);
        if (updated != null && mounted) {
          Get.to(() => ClaimDetailScreen(claim: updated));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.shadowSmall],
          border: Border.all(
            color: claim.statusColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: claim.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _statusIcon(claim.status),
                    color: claim.statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.itemTitle ?? 'Item #${claim.itemId}',
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (claim.itemCategory != null)
                        Text(claim.itemCategory!.capitalize!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                _buildStatusBadge(claim),
              ],
            ),
            const SizedBox(height: 12),
            if (claim.verificationNotes != null && claim.verificationNotes!.isNotEmpty)
            Text(
              claim.verificationNotes!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 12, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  _formatDate(claim.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 11),
                ),
                const Spacer(),
                if (claim.messages.isNotEmpty) ...[
                  Icon(Icons.chat_outlined,
                      size: 12, color: AppTheme.infoColor),
                  const SizedBox(width: 4),
                  Text(
                    '${claim.messages.length} message${claim.messages.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        color: AppTheme.infoColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Claim claim) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: claim.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        claim.statusLabel,
        style: TextStyle(
            color: claim.statusColor,
            fontWeight: FontWeight.w600,
            fontSize: 11),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'verified':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
