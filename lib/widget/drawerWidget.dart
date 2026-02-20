// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:AstrowayCustomer/controllers/advancedPanchangController.dart';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/counsellorController.dart';
import 'package:AstrowayCustomer/controllers/follow_astrologer_controller.dart';
import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/homeController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/themeController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/CustomerDetailModel.dart';
import 'package:AstrowayCustomer/services/location_services.dart';
import 'package:AstrowayCustomer/views/freeServicesScreen.dart';
import 'package:AstrowayCustomer/views/getReportScreen.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:AstrowayCustomer/views/loginWithEmail.dart';
import 'package:AstrowayCustomer/views/myFollowingScreen.dart';
import 'package:AstrowayCustomer/views/profile/editUserProfileScreen.dart';
import 'package:AstrowayCustomer/views/settings/colorPicker.dart';
import 'package:AstrowayCustomer/views/settings/settingsScreen.dart';
import 'package:AstrowayCustomer/views/wallet/paymentLogScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/astrologer_assistant_controller.dart';
import '../controllers/customer_support_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/images.dart';
import '../views/callScreen.dart';
import '../views/counsellor/counsellorScreen.dart';
import '../views/customer_support/customerSupportChatScreen.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final SplashController splashController = Get.find<SplashController>();
  final HistoryController historyController = Get.find<HistoryController>();
  final CallController callController = Get.put(CallController());
  final PanchangController panchangController = Get.find<PanchangController>();

  CustomerDetail? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// ✅ Fetches user profile data from FastAPI
  Future<void> _fetchUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final customer = await FastAPIServices().fetchCurrentUserDetails();
      setState(() {
        _customer = customer;
      });
    } catch (e) {
      print("❌ Error fetching user details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      child: SingleChildScrollView(
        child: GetBuilder<SplashController>(builder: (splashController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Drawer Header with API Data
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (_) => const EditCustomerDetailsPage()))
                            .then((_) => _fetchUserProfile()); // Refresh after edit
                      },
                      child: _isLoading
                          ? const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: (_customer?.profileImageUrl !=
                            null &&
                            _customer!.profileImageUrl!.isNotEmpty)
                            ? NetworkImage(_customer!.profileImageUrl!)
                            : const AssetImage(
                            'assets/images/default_user.png')
                        as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _isLoading
                          ? const Text(
                        "Loading...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customer?.name?.isNotEmpty == true
                                ? _customer!.name!
                                : "Guest User",
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_customer?.contactNo != null &&
                              _customer!.contactNo!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "${_customer?.countryCode ?? ''}-${_customer?.contactNo ?? ''}",
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Drawer Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat with Astrologer',
                      onTap: () async {
                        Get.to(() => CallAstrologerScreen());
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.payment,
                      title: 'Payment Logs',
                      onTap: () async {
                        Get.to(() => PaymentLogScreen());
                      },
                    ),
                _buildMenuItem(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Sign Up as Astrologer',
                  onTap: () async {
                    const String packageName = "com.jyotishi.astro";

                    // Try opening app using package name (Android)
                    final Uri appUri = Uri.parse("android-app://$packageName");

                    if (Platform.isAndroid) {
                      final Uri playStoreUri = Uri.parse(
                        "https://play.google.com/store/apps/details?id=$packageName",
                      );

                      try {
                        await launchUrl(
                          Uri.parse("market://details?id=$packageName"),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        await launchUrl(
                          playStoreUri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                ),

                    _buildMenuItem(
                      icon: Icons.support_agent,
                      title: 'Helpline',
                      onTap: () {
                        showModalBottomSheet(
                          context: Get.context!,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  const Text(
                                    "Contact Support",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // 📞 Call Support
                                  ListTile(
                                    leading: const Icon(Icons.call, color: Colors.green),
                                    title: const Text("Customer Care"),
                                    subtitle: const Text("+91 94227 99414"),
                                    onTap: () async {
                                      final Uri callUri =
                                      Uri.parse("tel:+919422799414");

                                      if (await canLaunchUrl(callUri)) {
                                        await launchUrl(
                                          callUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  ),

                                  // 💬 WhatsApp
                                  ListTile(
                                    leading: const Icon(Icons.chat, color: Colors.green),
                                    title: const Text("Chat on WhatsApp"),
                                    subtitle: const Text("+91 98190 9819"),
                                    onTap: () async {
                                      final Uri whatsappUri =
                                      Uri.parse("https://wa.me/9819089819");

                                      if (await canLaunchUrl(whatsappUri)) {
                                        await launchUrl(
                                          whatsappUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  ),

                                  // 📧 Email
                                  ListTile(
                                    leading:
                                    const Icon(Icons.email_outlined, color: Colors.blue),
                                    title: const Text("Email Support"),
                                    subtitle: const Text(
                                        "jyotishionlinekerala@gmail.com"),
                                    onTap: () async {
                                      final Uri emailUri = Uri(
                                        scheme: 'mailto',
                                        path: 'jyotishionlinekerala@gmail.com',
                                        query:
                                        'subject=Support Request&body=Hello Jyotishi Online Support Team,',
                                      );

                                      if (await canLaunchUrl(emailUri)) {
                                        await launchUrl(
                                          emailUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
          _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout my account',
          onTap: () async {
          bool isLogin = await global.isLogin();

          if (isLogin) {
          // 🧹 Clear all history controllers
          historyController.chatHistoryList.clear();
          historyController.astroMallHistoryList.clear();
          historyController.reportHistoryList.clear();
          historyController.callHistoryList.clear();
          historyController.paymentLogsList.clear();
          historyController.walletTransactionList.clear();

          // 🔥 Logout and delete FCM token
          await FastAPIServices().logout();

          // 🚪 Close drawer before redirecting (optional but better UX)
          if (Get.isOverlaysOpen) {
          Get.back(); // close drawer if open
          }

          // ⬅️ Navigate to Login Screen
         LocationService.isIndianUser ?
         Get.offAll(() => LoginScreen()) :
         Get.offAll(() => LoginWithEmailScreen());
          }
          },
          ),




                  ],
                ),
              ),

              Divider(
                color: Colors.grey.withOpacity(0.3),
                thickness: 1,
                height: 20,
              ),

              // ✅ Social Media Section
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Also Available On",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSocialIcon("assets/images/facebook.png"),
                        _buildSocialIcon("assets/images/instagram.png"),
                        _buildSocialIcon("assets/images/twitter.png"),
                        _buildSocialIcon("assets/images/youtube.png"),
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ App Version
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "App Version: 1.0.0",
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          );
        }),
      ),
    );
  }

  /// Menu Tile Widget
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Get.theme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ).tr(),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minLeadingWidth: 10,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Social Icon Widget
  Widget _buildSocialIcon(String imagePath) {
    return InkWell(
      onTap: () {
        // Add social media link functionality here
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Image.asset(
          imagePath,
          height: 20,
          width: 20,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
