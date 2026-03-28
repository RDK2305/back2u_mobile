import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final ApiService _api = ApiService();
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  bool _isLoading = true;
  String? _error;
  double _avgRating = 0;
  int _totalRatings = 0;
  List<dynamic> _ratings = [];
  Map<int, int> _breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = _authProvider.currentUser.value;
      if (user == null) throw Exception('Not logged in');
      final token = StorageService.getToken() ?? '';

      final result = await _api.getUserRatings(token, user.id);
      final List<dynamic> ratings =
          result['data'] ?? result['ratings'] ?? [];

      double sum = 0;
      final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (final r in ratings) {
        final stars = (r['rating'] as num?)?.toInt() ?? 0;
        sum += stars;
        if (breakdown.containsKey(stars)) {
          breakdown[stars] = (breakdown[stars] ?? 0) + 1;
        }
      }

      setState(() {
        _ratings = ratings;
        _totalRatings = ratings.length;
        _avgRating = ratings.isEmpty ? 0 : sum / ratings.length;
        _breakdown = breakdown;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadRatings,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildSummaryCard()),
                      SliverToBoxAdapter(child: _buildBreakdownCard()),
                      if (_ratings.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmpty(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _buildRatingTile(_ratings[i]),
                              childCount: _ratings.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  // ── Summary Card ────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _avgRating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          _buildStarRow(_avgRating, 30, Colors.amber),
          const SizedBox(height: 10),
          Text(
            '$_totalRatings ${_totalRatings == 1 ? 'rating' : 'ratings'} received',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Breakdown Card ───────────────────────────────────────────────────────────
  Widget _buildBreakdownCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Breakdown',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          for (int star = 5; star >= 1; star--) _buildBreakdownRow(star),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(int stars) {
    final count = _breakdown[stars] ?? 0;
    final fraction = _totalRatings > 0 ? count / _totalRatings : 0.0;
    final barColor = stars >= 4
        ? AppTheme.successColor
        : stars == 3
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          SizedBox(
            width: 14,
            child: Text(
              '$stars',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 9,
                backgroundColor: AppTheme.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 22,
            child: Text(
              '$count',
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ── Individual Rating Tile ────────────────────────────────────────────────────
  Widget _buildRatingTile(dynamic r) {
    final int stars = (r['rating'] as num?)?.toInt() ?? 0;
    final String comment = r['comment'] as String? ?? '';
    final String raterName =
        r['rater_name'] as String? ??
        (r['rater'] as Map?)?['name'] as String? ??
        'Anonymous';
    final String? rawDate =
        r['created_at'] as String? ?? r['createdAt'] as String?;
    String dateStr = '';
    if (rawDate != null) {
      try {
        final dt = DateTime.parse(rawDate).toLocal();
        dateStr = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }
    final String initial =
        raterName.isNotEmpty ? raterName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: const TextStyle(
                  color: AppTheme.primaryColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        raterName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildStarRow(stars.toDouble(), 17, Colors.amber),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '"$comment"',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _buildStarRow(double rating, double size, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating && (rating - i) >= 0.5;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: color,
          size: size,
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              'No ratings yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'Complete claims to start receiving ratings\nfrom other students',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            const Text('Failed to load ratings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadRatings,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
