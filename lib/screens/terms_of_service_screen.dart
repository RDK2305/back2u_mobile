import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    const Color(0xFF10B981),
                    const Color(0xFF059669),
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
                    Icons.description,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please read these terms carefully',
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
                    '1. Acceptance of Terms',
                    'By accessing and using Back2U, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                  ),
                  _buildSection(
                    context,
                    '2. Use License',
                    'Permission is granted to temporarily download one copy of the materials (information or software) on Back2U for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose or for any public display\n• Attempt to decompile or reverse engineer any software contained on Back2U\n• Remove any copyright or other proprietary notations from the materials\n• Transmit the materials to anyone or "mirror" the materials on any other server',
                  ),
                  _buildSection(
                    context,
                    '3. Disclaimer',
                    'The materials on Back2U are provided on an "as is" basis. Back2U makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                  ),
                  _buildSection(
                    context,
                    '4. Limitations',
                    'In no event shall Back2U or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Back2U, even if Back2U or an authorized representative has been notified orally or in writing of the possibility of such damage.',
                  ),
                  _buildSection(
                    context,
                    '5. Accuracy of Materials',
                    'The materials appearing on Back2U could include technical, typographical, or photographic errors. Back2U does not warrant that any of the materials on this website are accurate, complete, or current. Back2U may make changes to the materials contained on its website at any time without notice.',
                  ),
                  _buildSection(
                    context,
                    '6. User Conduct',
                    'Users agree not to use Back2U to:\n\n• Harass, threaten, defame, or abuse any individual\n• Post false, misleading, or fraudulent information\n• Violate any laws or regulations\n• Infringe upon intellectual property rights\n• Use the service for any illegal or unauthorized purpose',
                  ),
                  _buildSection(
                    context,
                    '7. Modification of Terms',
                    'Back2U may revise these terms of service at any time without notice. By using this website you are agreeing to be bound by the then current version of these terms of service.',
                  ),
                  _buildSection(
                    context,
                    '8. Governing Law',
                    'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction where Back2U is operated, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
                  ),
                  _buildSection(
                    context,
                    '9. Contact Us',
                    'If you have any questions about these Terms of Service, please contact us at legal@back2u.com',
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
                  color: const Color(0xFF10B981),
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
}
