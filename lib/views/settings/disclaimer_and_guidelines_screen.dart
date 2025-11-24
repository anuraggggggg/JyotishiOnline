import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';

class DisclaimerAndGuidelinesScreen extends StatelessWidget {
  const DisclaimerAndGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        // AppBar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Disclaimer & Guidelines",
            style: TextStyle(color: Colors.black),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _heading("Disclaimer"),
              _subText("Last Updated: 24 November 2025"),
              _sectionText(
                  "Jyotishionline provides astrology-related guidance through chat, call, video, and "
                      "live broadcasting. By using our platform, you agree to the following:"
              ),

              _title("1. Not Professional Advice"),
              _bullet("""
• Astrology is interpretive, not scientific.
• Predictions do not guarantee accuracy.
• Not a substitute for medical, legal, financial, or psychological advice.
• Always consult certified professionals for serious matters.
"""),

              _title("2. User Responsibility"),
              _bullet("""
• All decisions based on astrology advice are your responsibility.
• Platform is not liable for financial, emotional, relationship, legal, or business losses.
"""),

              _title("3. Independent Astrologers"),
              _bullet("""
• Astrologers are independent providers, not employees.
• Their views do not represent Jyotishionline.
"""),

              _title("4. No Guaranteed Outcomes"),
              _bullet("""
We do not promise or guarantee:
• Marriage success
• Job results
• Health outcomes
• Court case results
• Lottery numbers
• Any guaranteed predictions
"""),

              _title("5. Platform Usage"),
              _bullet("Use the platform at your own risk. Using the app means you agree to this disclaimer."),

              const SizedBox(height: 25),

              // ---------------- COMMUNITY GUIDELINES ----------------

              _heading("Community Guidelines (Users + Astrologers)"),
              _subText("Last Updated: 24 November 2025"),

              _title("For Users — MUST NOT:"),
              _bullet("""
• Harass, insult, or abuse astrologers
• Ask for astrologer’s personal phone number or social media
• Share vulgar, hateful, or illegal content
• Promote violence, drugs, self-harm, or fraud
• Threaten astrologers or users
• Use the platform for dating or adult content
• Share fake documents
• Record sessions without permission
"""),

              _title("Penalties for Violations"),
              _bullet("""
• Warning
• Temporary suspension
• Permanent ban
• Legal action for severe cases
"""),

              _title("Astrologers — MUST:"),
              _bullet("""
• Maintain professionalism
• Communicate respectfully
• Avoid creating fear or superstition
• Not force remedies on users
• Not request personal contact details
• Not guarantee results
• Not perform black magic/tantrik rituals
"""),

              _title("Penalties for Astrologers"),
              _bullet("""
• Profile removal
• Payment withholding
• Permanent ban
"""),

              const SizedBox(height: 25),

              // ---------------- LIVE BROADCASTING RULES ----------------

              _heading("Live Broadcasting Rules"),

              _title("1. Allowed on Live"),
              _bullet("""
• General astrology talks
• Horoscope readings
• Educational content
• Festival predictions
"""),

              _title("2. NOT Allowed on Live"),
              _bullet("""
❌ Asking users for personal contact  
❌ Abuse, shouting, insults  
❌ Religious or political promotion  
❌ Sexual or vulgar content  
❌ Guaranteeing results  
❌ Negative or harmful language  
❌ Tantrik / black magic  
❌ Showing dangerous objects  
"""),

              _title("3. Recording"),
              _bullet("""
• Live sessions may be monitored and recorded
• Used for safety and quality review
"""),

              _title("4. Monetization Rules"),
              _bullet("""
• Paid questions follow platform pricing
• Platform fee applies
• External payment requests are banned
"""),

              const SizedBox(height: 25),

              // ---------------- CONTENT POLICY ----------------

              _heading("Content & Conduct Policy"),

              _title("Prohibited Content"),
              _bullet("""
• Nudity or explicit content
• Hate speech or discrimination
• Encouraging self-harm
• Fake documents
• Spam or promotions
• Violence or threats
• Sharing private info
• Recording app content without permission
"""),

              _title("Allowed Content"),
              _bullet("""
• Astrology advice
• Horoscope content
• Educational astrology material
• Motivational guidance
"""),

              _title("Actions Taken on Violations"),
              _bullet("""
• Warning
• Temporary block
• Permanent ban
• Payment hold
• Legal escalation
"""),

              const SizedBox(height: 25),

              // ---------------- REPORT POLICY ----------------

              _heading("Report & Complaint Policy"),

              _title("1. How to Report"),
              _bullet("""
You may report:
• Abuse
• Astrologer misconduct
• Technical issues
• Payment problems

Email: jyotishionlinekerala@gmail.com  
Include:  
• Registered mobile number  
• Screenshot/video (if available)  
• Brief description  
"""),

              _title("2. How Complaints Are Handled"),
              _bullet("""
• Response within 24–48 hours  
• Internal investigation  
• Review of chats/calls/live recordings  
• Appropriate action taken  
"""),

              _title("3. Refund Complaints — Valid Only If:"),
              _bullet("""
• Double deduction  
• Payment deducted but session didn’t start  
• Astrologer didn’t join  
Proof may be required.
"""),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _subText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: appYellow,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}
