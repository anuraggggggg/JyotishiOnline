import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:AstrowayCustomer/controllers/settings_controller.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/block_astrologer_screen.dart';
import 'package:AstrowayCustomer/views/settings/privacyPolicyScreen.dart';
import 'package:AstrowayCustomer/views/settings/termsAndConditionScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/commonAppbar.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

class SettingListScreen extends StatelessWidget {
  const SettingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controllers here to ensure they are available in the widget tree
    final SettingsController settingsController =
        Get.find<SettingsController>();
    final HistoryController historyController =
        Get.find<HistoryController>(); // For logout

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Use theme background color
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CommonAppBar(
              title:
                  'Settings', // Title will be translated by CommonAppBar if it supports it
            )),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              vertical: 10.0), // Add overall vertical padding
          child: Column(
            children: [
              GetBuilder<SettingsController>(builder: (_) {
                // Use underscore as param if not directly used
                return settingsController.blockedAstroloer.isEmpty
                    ? const SizedBox()
                    : _SettingListItem(
                        icon: Icons.block, // Added a relevant icon
                        title: "Block Astrologer",
                        titleColor: Theme.of(context)
                            .primaryColor, // Use primary color for consistency
                        onTap: () async {
                          global.showOnlyLoaderDialog(context);
                          await settingsController.getBlockAstrologerList();
                          global.hideLoader();
                          Get.to(() => BlockAstrologerScreen());
                        },
                      );
              }),
              // _SettingListItem(
              //   icon: Icons.assignment, // Icon for terms
              //   title: "Terms and Condition",
              //   onTap: () {
              //     Get.to(() => TermAndConditionScreen());
              //   },
              // ),
              // _SettingListItem(
              //   icon: Icons.security, // Icon for privacy
              //   title: "Privacy Policy",
              //   onTap: () {
              //     Get.to(() => PrivacyPolicyScreen());
              //   },
              // ),
              // _SettingListItem(
              //   icon: Icons.logout,
              //   title: "Logout my account",
              //   iconColor: Colors.black, // Specific color for logout icon
              //   titleColor: Colors.black, // Specific color for logout text
              //   showTrailingIcon: false, // No trailing arrow for logout
              //   onTap: () {
              //     Get.dialog(
              //       AlertDialog(
              //         backgroundColor: Theme.of(context).dialogBackgroundColor, // Use theme color
              //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
              //         title: Text(
              //           "Are you sure you want to logout?",
              //           style: Get.textTheme.titleMedium,
              //           textAlign: TextAlign.center, // Center the title
              //         ).tr(),
              //         content: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //           children: [
              //             Expanded(
              //               child: OutlinedButton( // Used OutlinedButton for 'No'
              //                 onPressed: () {
              //                   Get.back();
              //                 },
              //                 style: OutlinedButton.styleFrom(
              //                   side: BorderSide(color: Get.theme.primaryColor), // Border color
              //                   foregroundColor: Get.theme.primaryColor, // Text color
              //                 ),
              //                 child: Text('No').tr(),
              //               ),
              //             ),
              //             const SizedBox(width: 10),
              //             Expanded(
              //               child: ElevatedButton( // Kept ElevatedButton for 'YES'
              //                 onPressed: () {
              //                   historyController.chatHistoryList.clear();
              //                   historyController.astroMallHistoryList.clear();
              //                   historyController.reportHistoryList.clear();
              //                   historyController.callHistoryList.clear();
              //                   historyController.paymentLogsList.clear();
              //                   historyController.walletTransactionList.clear();
              //                   global.logoutUser();
              //                 },
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: Get.theme.primaryColor, // Button background color
              //                   foregroundColor: Colors.white, // Text color
              //                 ),
              //                 child: Text('YES').tr(),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),
              GetBuilder<SettingsController>(builder: (_) {
                return _SettingListItem(
                  icon: Icons.delete_forever, // Stronger delete icon
                  title: "Delete my account",
                  iconColor: Colors.red, // Specific color for delete icon
                  titleColor: Colors.red, // Specific color for delete text
                  showTrailingIcon: false, // No trailing arrow for delete
                  onTap: () async {
                    bool isLogin = await global.isLogin();
                    if (isLogin) {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            "Are you sure you want to delete this Account?",
                            style: Get.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ).tr(),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Get.theme.primaryColor),
                                    foregroundColor: Get.theme.primaryColor,
                                  ),
                                  child: Text('No').tr(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    global.showOnlyLoaderDialog(context);
                                    // Ensure user ID is valid before calling deleteAccount
                                    await settingsController.deleteAccount(
                                        global.sp!.getInt("currentUserId") ??
                                            0);
                                    global
                                        .logoutUser(); // Logout after deletion attempt
                                    global.hideLoader();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red, // Red for delete action
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Yes').tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Widget for Settings List Item
class _SettingListItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool showTrailingIcon;

  const _SettingListItem({
    Key? key,
    this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.showTrailingIcon = true, // Default to true for navigability
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5, // Subtle elevation
      margin: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Consistent margin
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0)), // Slightly more rounded corners
      clipBehavior:
          Clip.antiAlias, // Ensures the InkWell ripple is clipped nicely
      child: InkWell(
        // Provides ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Get.theme.primaryColor.withOpacity(0.1),
        highlightColor: Get.theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0), // Generous and balanced padding
          child: Row(
            children: [
              if (icon != null) // Only show icon if provided
                Icon(
                  icon,
                  color: iconColor ??
                      Get.theme
                          .primaryColor, // Use provided color or theme's primary
                  size: 24, // Good size for visibility
                ),
              if (icon != null)
                const SizedBox(width: 18.0), // Spacing between icon and text
              Expanded(
                child: Text(
                  title, // Ensure translation is applied
                  style: Get.textTheme.titleMedium!.copyWith(
                    color: titleColor ??
                        Get.textTheme.titleMedium!
                            .color, // Use provided color or default text color
                    fontWeight:
                        FontWeight.w500, // Maintain consistency with original
                    fontSize: 16, // Consistent font size
                  ),
                ),
              ),
              if (showTrailingIcon) // Show trailing arrow if true
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, // Subtle grey arrow
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
