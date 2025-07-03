import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/widget/commonAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Assuming you have this

class TermAndConditionScreen extends StatelessWidget {
  // Page name changed here
  const TermAndConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Terms & Conditions', // Title displayed in the app bar
          ),
        ),
        body: Column(
          // Use Column to hold scrollable content and fixed button
          children: [
            Expanded(
              // The main content will scroll
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                    16.0), // Padding around the entire content
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the start
                  children: [
                    // --- Introduction ---
                    Text(
                      'Effective Date: June-01-2025', //
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Jyotishionline.com, a digital platform owned and operated by Completely Different, a registered partnership firm based in Mumbai, India. This platform connects members with astrologers for astrology-related consultations. Please read these Terms & Conditions carefully before accessing or using our services via web or mobile app.', //
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // --- Section 1: Acceptance of Terms ---
                    _TermsSection(
                      number: '1.',
                      title: 'Acceptance of Terms',
                      content:
                          'By registering, logging in, or using the services of Jyotishionline.com, you agree to comply with and be bound by these Terms & Conditions and our Privacy Policy. If you do not agree, you should not use the platform.', //
                    ),

                    // --- Section 2: Nature of Services ---
                    _TermsSection(
                      number: '2.',
                      title: 'Nature of Services',
                      content:
                          'Jyotishionline.com serves as a digital platform for members to interact with astrologers for consultations through chat, video, audio, and live broadcasts. All fees for services are set individually by astrologers. Payments must be made through our platform before any session begins.', //
                    ),

                    // --- Section 3: Disclaimer & Limitation of Liability ---
                    _TermsSection(
                      number: '3.',
                      title: 'Disclaimer & Limitation of Liability',
                      content:
                          'All content and predictions made by astrologers are their personal interpretations of astrology and related sciences. Jyotishionline.com and Completely Different do not validate, verify, or take responsibility for the accuracy, truth, or results of these predictions. Users agree that they use the platform and any advice given entirely at their own discretion and risk. The platform is not responsible for any decisions, actions, or losses incurred based on astrologer guidance.', //
                    ),

                    // --- Section 4: Member Conduct ---
                    _TermsSection(
                      number: '4.',
                      title: 'Member Conduct',
                      content: 'All members must:\n' //
                          '• Provide accurate, up-to-date information at registration.\n' //
                          '• Use respectful language and behavior with astrologers and other users.\n' //
                          '• Not record, distribute, or publish any session without explicit permission.\n' //
                          '• Not misuse the platform for harassment, fraud, or offensive behavior.\n' //
                          'Violation may result in suspension or permanent banning.', //
                    ),

                    // --- Section 5: Payments and Refund Policy ---
                    _TermsSection(
                      number: '5.',
                      title: 'Payments and Refund Policy',
                      content:
                          'Payments for astrologer services are processed exclusively through Jyotishionline.com. All fees are visible prior to consultation and must be paid in advance. Refunds will not be provided for completed consultations under any circumstances. Refunds for failed transactions or technical errors may be processed at the sole discretion of the platform after internal review.', //
                    ),

                    // --- Section 6: No Guarantee of Outcome ---
                    _TermsSection(
                      number: '6.',
                      title: 'No Guarantee of Outcome',
                      content:
                          'Astrology is a spiritual and interpretive discipline. Results or predictions cannot be guaranteed. Jyotishionline.com is not a replacement for professional medical, legal, or financial advice. Members must exercise their own judgment before acting on any advice received.', //
                    ),

                    // --- Section 7: Eligibility to Use ---
                    _TermsSection(
                      number: '7.',
                      title: 'Eligibility to Use',
                      content: 'To register and use Jyotishionline.com:\n' //
                          '• You must be 18 years or older.\n' //
                          '• You must be legally competent to enter into binding agreements.\n' //
                          '• You must comply with all applicable local laws.', //
                    ),

                    // --- Section 8: Data Privacy and Protection ---
                    _TermsSection(
                      number: '8.',
                      title: 'Data Privacy and Protection',
                      content:
                          'We collect and store personal data in accordance with our Privacy Policy. Data is never sold to third parties. It may be disclosed only to fulfill services or legal obligations. All payments and sessions are secured with end-to-end protection.', //
                    ),

                    // --- Section 9: Intellectual Property ---
                    _TermsSection(
                      number: '9.',
                      title: 'Intellectual Property',
                      content:
                          'All content, design, trademarks, and branding on the platform belong to Completely Different or its licensors. Unauthorized use or duplication is strictly prohibited.', //
                    ),

                    // --- Section 10: Modification of Terms ---
                    _TermsSection(
                      number: '10.',
                      title: 'Modification of Terms',
                      content:
                          'These Terms & Conditions may be updated at any time. Continued use of the platform after updates constitutes your acceptance of the revised terms.', //
                    ),

                    // --- Section 11: Termination ---
                    _TermsSection(
                      number: '11.',
                      title: 'Termination',
                      content:
                          'We reserve the right to suspend or delete any account that violates these terms or misuses the service. Users may request account deletion by contacting our support team.', //
                    ),

                    // --- Section 12: Governing Law & Jurisdiction ---
                    _TermsSection(
                      number: '12.',
                      title: 'Governing Law & Jurisdiction',
                      content:
                          'These terms are governed by the laws of India, and any disputes shall be subject to the exclusive jurisdiction of the courts in Mumbai, Maharashtra.', //
                    ),

                    // --- Section 13: Contact Information ---
                    _TermsSection(
                      number: '13.',
                      title: 'Contact Information',
                      content: '📍 Completely Different\n' //
                          '📍 Registered Partnership Firm – Mumbai, India\n' //
                          '📧 Email: jyotishionlinekerala@gmail.com\n' //
                          '📞 Customer Support: +91 9819089819', //
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // --- Bottom Acceptance Section ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .cardColor, // Use card color for bottom section
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2), // Shadow at the top
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Member Declaration',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By clicking "Accept & Continue", I confirm that:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• I am 18 years or older.', //
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '• I have read, understood, and agree to the Terms & Conditions above.', //
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '• I understand that astrology is subjective and interpretive, and I use the platform at my own discretion.', //
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(
                            'termsAccepted', true); // Save acceptance flag

                        // Navigate to LoginScreen
                        Get.offAll(() => LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appYellow,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Accept & Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Widget for each Terms & Conditions Section
class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _TermsSection({
    Key? key,
    required this.number,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number $title',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: appYellow, // Use primary color for headings
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.5, // Improve line spacing for readability
                fontSize: 15,
              ),
        ),
        const SizedBox(height: 24), // Spacing between sections
      ],
    );
  }
}
