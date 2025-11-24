import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermAndConditionScreen extends StatelessWidget {
  const TermAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        // ✅ Correct AppBar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              "Terms & Conditions",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),

        // ✅ Scrollable Body
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Last Updated: 24 November 2025",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),

              _section(
                title: "Welcome to Jyotishionline",
                content:
                "By downloading, accessing, or using our mobile application or services, you (“User”) agree to these Terms & Conditions. "
                    "If you do not agree, please discontinue using the Platform.",
              ),

              _section(
                number: "1",
                title: "Service Overview",
                content:
                "Jyotishionline is a digital astrology platform offering:\n"
                    "• Live astrology consultations\n"
                    "• Chat, call, and video sessions\n"
                    "• Live broadcasting by astrologers\n"
                    "• Personalized reports\n"
                    "• Horoscope-based services\n"
                    "These services are for guidance and personal insight purposes only.",
              ),

              _section(
                number: "2",
                title: "Eligibility",
                content:
                "To use the Platform, you must:\n"
                    "• Be at least 18 years old\n"
                    "• Use the Platform for lawful and personal purposes\n"
                    "• Provide accurate information during registration\n\n"
                    "If you are below 18, parental or guardian consent is required.",
              ),

              _section(
                number: "3",
                title: "User Account & Login",
                content:
                "Login is done using OTP-based authentication. You are responsible for maintaining "
                    "the confidentiality of your account. Any activity done through your account will be considered yours.\n\n"
                    "Misuse, fraudulent activity, or impersonation may lead to suspension or permanent ban.",
              ),

              _section(
                number: "4",
                title: "Consultations & Predictions",
                content:
                "All predictions and advice are based on astrologers' interpretation of astrological principles. "
                    "Jyotishionline does not guarantee accuracy.\n\n"
                    "Astrology is NOT a substitute for:\n"
                    "• Medical advice\n"
                    "• Legal advice\n"
                    "• Financial advice\n"
                    "• Psychological counseling\n\n"
                    "We are not responsible for actions or decisions taken based on astrology guidance.",
              ),

              _section(
                number: "5",
                title: "Payments & Charges",
                content:
                "Payments are processed securely (UPI, wallet, etc.). Prices vary based on astrologer and service.\n\n"
                    "All payments are FINAL and non-refundable except in cases of:\n"
                    "• Technical failure\n"
                    "• Duplicate deduction\n"
                    "• Astrologer not joining the session\n\n"
                    "Refund eligibility will be verified by our support team.",
              ),

              _section(
                number: "6",
                title: "Session Monitoring & Recording",
                content:
                "To ensure safety and transparency:\n"
                    "• Chat sessions may be reviewed\n"
                    "• Calls may be monitored or recorded\n"
                    "• Live sessions may be stored\n\n"
                    "Recordings are used only for fraud detection, quality checks, or legal reasons.",
              ),

              _section(
                number: "7",
                title: "Astrologer Conduct",
                content:
                "Astrologers are independent service providers. They must maintain professionalism and cannot demand personal contact details.\n\n"
                    "If you find an astrologer violating rules, report immediately.",
              ),

              _section(
                number: "8",
                title: "User Responsibilities",
                content:
                "You agree NOT to:\n"
                    "• Harass or threaten astrologers or users\n"
                    "• Share vulgar or offensive content\n"
                    "• Record sessions without permission\n"
                    "• Misuse or copy reports or predictions\n"
                    "• Attempt unauthorized access to the Platform\n\n"
                    "Violation may result in suspension, permanent ban, or legal action.",
              ),

              _section(
                number: "9",
                title: "Intellectual Property",
                content:
                "All content, logos, images, and software belong to Jyotishionline. "
                    "Copying or modifying them without permission is prohibited.",
              ),

              _section(
                number: "10",
                title: "Service Availability",
                content:
                "We strive for uninterrupted service but do not guarantee:\n"
                    "• 24/7 uptime\n"
                    "• Zero technical issues\n"
                    "• Error-free operation\n\n"
                    "We may modify or pause services anytime.",
              ),

              _section(
                number: "11",
                title: "Refund & Cancellation Policy",
                content:
                "All payments for chat, call, video, or live sessions are FINAL and non-refundable.\n\n"
                    "Refunds MAY be given ONLY if:\n"
                    "• Double payment was charged\n"
                    "• Payment deducted but session didn't start due to technical issue\n"
                    "• Astrologer did not join the session\n\n"
                    "Refunds will NOT be given for:\n"
                    "• Dissatisfaction with predictions\n"
                    "• Change of mind\n"
                    "• Network issues on user side\n"
                    "• Leaving the session early\n\n"
                    "Refund requests must be raised within 24 hours with transaction proof.",
              ),

              _section(
                number: "12",
                title: "Limitation of Liability",
                content:
                "Jyotishionline is NOT liable for:\n"
                    "• Decisions based on astrology\n"
                    "• Financial or emotional losses\n"
                    "• Technical issues or downtime\n"
                    "• Third-party payment failures\n"
                    "• Misconduct by astrologers\n\n"
                    "Our maximum liability is limited to the amount you paid for the affected service.",
              ),

              _section(
                number: "13",
                title: "Changes to Terms",
                content:
                "We may update these Terms anytime. Continued use of the Platform means you accept the updated Terms.",
              ),

              _section(
                number: "14",
                title: "Governing Law",
                content:
                "These Terms are governed by Indian law. Any disputes fall under applicable legal jurisdictions in India.",
              ),

              _section(
                number: "15",
                title: "Contact Information",
                content:
                "For support:\n"
                    "📧 jyotishionlinekerala@gmail.com",
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    String? number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number != null ? "$number. $title" : title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: appYellow,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
