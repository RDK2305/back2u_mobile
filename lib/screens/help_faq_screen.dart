import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final Set<int> _expanded = {};

  // ─── FAQ Data ────────────────────────────────────────────────────────────────
  static const _faqs = [
    (
      q: 'How do I report a lost item?',
      a: 'Go to the Home tab and tap "Report Lost". Fill in the item title, category, description, and location where you last had it. Adding a photo greatly improves recovery chances. Be as specific as possible.',
    ),
    (
      q: 'How do I report a found item?',
      a: 'Go to the Home tab and tap "Report Found". Describe the item and where you found it on campus. Optionally add a photo. Avoid publicly revealing unique security details — save those for the verification step.',
    ),
    (
      q: 'How does the claim process work?',
      a: 'When you spot your item in the list, open it and tap "This is Mine — Claim It". Describe specific details proving ownership. The finder reviews your claim and can verify or reject it. You\'ll receive a notification of the outcome.',
    ),
    (
      q: 'What is the verification question?',
      a: 'When posting a found item, finders can set a secret verification question (e.g. a unique feature of the item). Only the true owner should know the answer. This prevents false claims.',
    ),
    (
      q: 'Where can I track my claims?',
      a: 'Open the Claims tab to see all your submitted claims with their current status: Pending (awaiting review), Verified (owner confirmed), Completed (item returned), or Rejected.',
    ),
    (
      q: 'How do in-app messages work?',
      a: 'Once your claim is submitted, both parties can exchange messages in a private chat thread. Access your conversations from the Messages inbox in your Profile or directly from a claim detail page.',
    ),
    (
      q: 'What is the rating system?',
      a: 'After a claim is verified or completed, both the claimer and the finder can rate each other 1–5 stars with an optional comment. Ratings build a campus trust score visible on every user\'s profile.',
    ),
    (
      q: 'How do I save items for later?',
      a: 'On any item detail page, tap the bookmark icon (🔖) in the top-right corner. All bookmarked items appear in Saved Items, accessible from your Profile\'s Quick Actions.',
    ),
    (
      q: 'Is my personal information safe?',
      a: 'Your email and password are stored securely and never shared. Only your display name is visible to other users. We never expose your contact details without your explicit consent.',
    ),
    (
      q: 'What if my claim is rejected?',
      a: 'If your claim is rejected, read any feedback left by the finder, then submit a new claim with more accurate or detailed information. Make sure to include specific identifying features of the item.',
    ),
    (
      q: 'Can I delete a claim I submitted?',
      a: 'Yes. Open the claim from the Claims tab, then tap the delete option. Note that once the finder has verified a claim you cannot retract it — contact the finder via messages instead.',
    ),
    (
      q: 'What should I do after the item is returned?',
      a: 'Mark the claim as Completed in the claim detail screen, then rate the other person. This helps the community trust the platform and encourages future good-faith participation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 28),

            _buildSectionHeader('How It Works', Icons.auto_stories_outlined),
            const SizedBox(height: 12),
            _buildHowItWorks(),
            const SizedBox(height: 28),

            _buildSectionHeader(
                'Frequently Asked Questions', Icons.quiz_outlined),
            const SizedBox(height: 12),
            ..._buildFaqTiles(),
            const SizedBox(height: 28),

            _buildSectionHeader(
                'Need More Help?', Icons.support_agent_outlined),
            const SizedBox(height: 12),
            _buildContactCard(),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Back2U Help Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Everything you need to find your lost items and help others on campus',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor),
        ),
      ],
    );
  }

  // ── How It Works ──────────────────────────────────────────────────────────────
  Widget _buildHowItWorks() {
    final steps = [
      (
        icon: Icons.report_problem_outlined,
        color: AppTheme.errorColor,
        title: 'Report',
        desc:
            'Post a lost or found item with photo, category, and exact location on campus.',
      ),
      (
        icon: Icons.search_outlined,
        color: AppTheme.infoColor,
        title: 'Browse',
        desc:
            'Search through found items on campus. Filter by category, location, or date.',
      ),
      (
        icon: Icons.handshake_outlined,
        color: AppTheme.primaryColor,
        title: 'Claim',
        desc:
            'Submit a claim with proof of ownership. Answer the finder\'s verification question.',
      ),
      (
        icon: Icons.message_outlined,
        color: AppTheme.secondaryColor,
        title: 'Connect',
        desc:
            'Chat with the finder to arrange a pickup location and time on campus.',
      ),
      (
        icon: Icons.star_outlined,
        color: AppTheme.warningColor,
        title: 'Rate',
        desc:
            'Rate the experience after the item is returned to build campus trust.',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.icon, color: s.color, size: 22),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: AppTheme.borderColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: i < steps.length - 1 ? 0 : 0, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ${s.title}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: s.color),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.desc,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                          height: 1.4),
                    ),
                    SizedBox(height: i < steps.length - 1 ? 20 : 0),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── FAQ Tiles ─────────────────────────────────────────────────────────────────
  List<Widget> _buildFaqTiles() {
    return List.generate(_faqs.length, (i) {
      final isOpen = _expanded.contains(i);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOpen
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : AppTheme.borderColor,
            width: isOpen ? 1.5 : 1,
          ),
          boxShadow: isOpen ? [AppTheme.shadowSmall] : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() {
              if (isOpen) {
                _expanded.remove(i);
              } else {
                _expanded.add(i);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: (isOpen
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.question_mark_rounded,
                          size: 14,
                          color: isOpen
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _faqs[i].q,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isOpen
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: isOpen
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ],
                  ),
                  if (isOpen) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: AppTheme.borderColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _faqs[i].a,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ── Contact ───────────────────────────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          _buildContactRow(
            Icons.email_outlined,
            'Email Support',
            'support@back2u.app',
            AppTheme.infoColor,
          ),
          const Divider(height: 24),
          _buildContactRow(
            Icons.school_outlined,
            'Campus Office',
            'Student Services Building, Room 101',
            AppTheme.primaryColor,
          ),
          const Divider(height: 24),
          _buildContactRow(
            Icons.access_time_outlined,
            'Office Hours',
            'Mon – Fri, 8:00 AM – 5:00 PM',
            AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
      IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
      ],
    );
  }
}
