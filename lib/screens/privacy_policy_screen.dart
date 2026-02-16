import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6),
                    const Color(0xFF1E3A8A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Learn how we protect your data',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Introduction',
                    'Back2U ("we", "our", or "us") operates the Back2U application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our service and the choices you have associated with that data.',
                  ),
                  _buildSection(
                    context,
                    'Information Collection and Use',
                    'We collect several different types of information for various purposes to provide and improve our service.',
                  ),
                  _buildSubsection(
                    context,
                    'Personal Data:',
                    '• Name, email address, and student ID\n• Campus and program information\n• Location data when reporting lost/found items\n• Device information and usage data',
                  ),
                  _buildSection(
                    context,
                    'Use of Data',
                    'Back2U uses the collected data for various purposes:\n\n• To provide and maintain our service\n• To notify you about changes to our service\n• To allow you to participate in interactive features\n• To provide customer support\n• To gather analysis or valuable information so we can improve our service',
                  ),
                  _buildSection(
                    context,
                    'Security of Data',
                    'The security of your data is important to us but remember that no method of transmission over the Internet is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
                  ),
                  _buildSection(
                    context,
                    'Children\'s Privacy',
                    'Our service does not address anyone under the age of 13 ("Children"). We do not knowingly collect personally identifiable information from anyone under the age of 13.',
                  ),
                  _buildSection(
                    context,
                    'Contact Us',
                    'If you have any questions about this Privacy Policy, please contact us at privacy@back2u.com',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Last updated: February 2026',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 0, bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF3B82F6),
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
