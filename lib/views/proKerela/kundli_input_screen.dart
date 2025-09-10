// screens/kundliInputScreen.dart

import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:AstrowayCustomer/views/proKerela/kundlioOutputpage.dart';
import '../../controllers/proKerela/detailed_kundli_controller.dart';
import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/currentUserWalletModel.dart';
import '../../utils/services/location_service.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
// import 'package:AstrowayCustomer/utils/global.dart' as global; // Removed: Not needed if no wallet access
// import '../../utils/services/payment_service.dart'; // Removed: Not needed if no payment

class KundliInputScreen extends StatefulWidget {
  const KundliInputScreen({super.key});

  @override
  State<KundliInputScreen> createState() => _KundliInputScreenState();
}

class _KundliInputScreenState extends State<KundliInputScreen> {
  final DetailedKundliController controller =
      Get.put(DetailedKundliController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final FocusNode _cityFocusNode = FocusNode();

  final RxInt _selectedAyanamsa = 1.obs; // Default: Lahiri (1)
  final RxString _selectedLanguage = 'ml'.obs; // Default: Malayalam

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  CurrentUserWalletModel? _wallet;
// or int, or String, depending on your API response

  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];

  // --- Define a consistent sophisticated color palette ---
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  // Price details for Kundli (Removed as per your request)
  // static const double kundliBasePrice = 599.0;
  // static const double gstRate = 0.18; // 18% GST

  // Ayanamsa options
  final List<Map<String, dynamic>> ayanamsaOptions = const [
    {'value': 1, 'label': 'Lahiri'},
    {'value': 3, 'label': 'Raman'},
    {'value': 5, 'label': 'KP'},
  ];

  // Language options
  final List<Map<String, String>> languageOptions = const [
    {'value': 'en', 'label': 'English'},
    {'value': 'hi', 'label': 'Hindi'},
    {'value': 'ml', 'label': 'Malayalam'},
    {'value': 'ta', 'label': 'Tamil'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial date/time to current time
    _updateDateTimeControllers(DateTime.now());

    _cityFocusNode.addListener(() {
      if (!_cityFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _suggestions.clear();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _cityFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateDateTimeControllers(DateTime dateTime) {
    setState(() {
      selectedDate = dateTime;
      selectedTime = TimeOfDay.fromDateTime(dateTime);
      _dateController.text = DateFormat('yyyy-MM-dd').format(dateTime);
      _timeController.text = DateFormat('HH:mm').format(dateTime);
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: celestialGold,
              onPrimary: cosmicBlue,
              surface: stardustWhite,
              onSurface: cosmicBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: cosmicBlue),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: celestialGold, width: 1.5),
              ),
              backgroundColor: stardustWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: celestialGold,
                onPrimary: cosmicBlue,
                surface: stardustWhite,
                onSurface: cosmicBlue,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: cosmicBlue),
              ),
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: celestialGold, width: 1.5),
                ),
                backgroundColor: stardustWhite,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final fullDateTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _updateDateTimeControllers(fullDateTime);
      }
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withOpacity(0.9),
      colorText: stardustWhite,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      icon: Icon(
          backgroundColor == warningRed
              ? Icons.error_outline
              : Icons.check_circle_outline,
          color: stardustWhite,
          size: 28),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
      barBlur: 5,
    );
  }

  Widget _buildThemedTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    bool enableSuggestions = false,
    FocusNode? focusNode,
    Function(List<LocationSuggestion>)? onSuggestionsUpdated,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      focusNode: focusNode,
      onChanged: enableSuggestions
          ? (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();

              _debounce = Timer(const Duration(milliseconds: 500), () async {
                if (value.isEmpty) {
                  onSuggestionsUpdated?.call([]);
                  return;
                }
                try {
                  final result =
                      await LocationService.fetchCitySuggestions(value);
                  onSuggestionsUpdated?.call(result);
                } catch (e) {
                  print('Error fetching suggestions: $e');
                  onSuggestionsUpdated?.call([]);
                }
              });
            }
          : null,
      style: GoogleFonts.poppins(color: stardustWhite, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(
            color: lunarSilver, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: celestialGold.withOpacity(0.9), size: 24),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: celestialGold, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningRed, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      validator: validator,
    );
  }

  Widget _buildThemedDropdownFormField<T>({
    required Rx<T> value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    required IconData icon,
    String? Function(T?)? validator,
  }) {
    return Obx(() => DropdownButtonFormField<T>(
          value: value.value,
          style: GoogleFonts.poppins(
            color: stardustWhite,
            fontSize: 16,
          ),
          icon:
              const Icon(Icons.arrow_drop_down, color: celestialGold, size: 28),
          dropdownColor: cosmicBlue.withOpacity(0.95),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.poppins(
                color: lunarSilver, fontWeight: FontWeight.w500),
            prefixIcon:
                Icon(icon, color: celestialGold.withOpacity(0.9), size: 24),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 18, horizontal: 15), // Updated this line
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: celestialGold, width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: warningRed, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: warningRed, width: 2.5),
            ),
            filled: true,
            fillColor: cosmicBlue.withOpacity(0.7),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ));
  }

  Future<void> _submit() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    const int kundliServicePrice = 599;

    if (_formKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        _showSnackbar('Required', 'Please select date & time', warningRed);
        return;
      }

      if (_cityController.text.trim().isEmpty) {
        _showSnackbar(
            'Location Error', 'City/Place name is required.', warningRed);
        return;
      }

      controller.isLoading.value = true;

      try {
        // 1️⃣ Fetch wallet balance from backend
        final wallet = await FastAPIServices().fetchCurrentWallet();
        if (wallet == null) {
          _showSnackbar('Wallet Error',
              'Unable to fetch wallet balance. Please try again.', warningRed);
          controller.isLoading.value = false;
          return;
        }

        // 2️⃣ Check balance
        if (wallet.amount < kundliServicePrice) {
          final shortfall = kundliServicePrice - wallet.amount;
          _showSnackbar(
            'Insufficient Balance',
            'You need ₹${shortfall.toStringAsFixed(2)} more to access Kundli service. Please recharge your wallet.',
            warningRed,
          );
          controller.isLoading.value = false;
          return;
        }

        // 3️⃣ Deduct using debit API
        final updatedWallet =
        await FastAPIServices().debitWallet(kundliServicePrice);

        if (updatedWallet == null) {
          _showSnackbar(
              'Payment Failed', 'Could not deduct wallet. Try again.', warningRed);
          controller.isLoading.value = false;
          return;
        }

        // 4️⃣ Success → show snackbar
        _showSnackbar(
          'Payment Successful',
          '₹${kundliServicePrice.toStringAsFixed(2)} deducted from your wallet for Kundli service.',
          celestialGold,
        );

        // 5️⃣ Update local wallet state for UI
        setState(() {
          _wallet = updatedWallet;
        });

        await Future.delayed(const Duration(milliseconds: 400));

        // 6️⃣ Fetch Kundli data
        await controller.fetchFromInputFields(
          cityName: _cityController.text.trim(),
          date: _dateController.text.trim(),
          time: _timeController.text.trim(),
          ayanamsa: _selectedAyanamsa.value,
          language: _selectedLanguage.value,
        );

        if (controller.kundliData.value != null &&
            controller.errorMessage.isEmpty) {
          Get.to(() => DetailedKundliResultScreen());
          _showSnackbar(
              'Success', 'Kundli data fetched successfully!', celestialGold);
        } else {
          _showSnackbar(
            'Kundli Generation Error',
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Failed to fetch Kundli data. Please try again.',
            warningRed,
          );
        }
      } catch (e) {
        print('Kundli generation error: $e');
        _showSnackbar('Unexpected Error', 'Please try again.', warningRed);
      } finally {
        controller.isLoading.value = false;
      }
    } else {
      _showSnackbar(
          'Input Error', 'Please fill all required fields correctly.', warningRed);
    }
  }



  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Generate Your Kundli',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              darkAccent,
              mediumAccent,
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(left: 25, right: 25, bottom: 25, top: topPadding),
          child: Column(
            children: [
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: celestialGold.withOpacity(0.8), width: 2),
                ),
                color: cosmicBlue.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Kundli Calculation Details",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: celestialGold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // City/Place Name with Autocomplete
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return Column(
                              children: [
                                _buildThemedTextFormField(
                                  controller: _cityController,
                                  labelText: "City/Place Name",
                                  icon: Icons.location_on,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? "Location is required"
                                          : null,
                                  enableSuggestions: true,
                                  focusNode: _cityFocusNode,
                                  onSuggestionsUpdated: (newSuggestions) {
                                    setStateSB(() {
                                      _suggestions = newSuggestions;
                                    });
                                  },
                                ),
                                // Display suggestions only if there are any and the text field is focused
                                if (_suggestions.isNotEmpty &&
                                    _cityFocusNode.hasFocus)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cosmicBlue.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              celestialGold.withOpacity(0.4)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.35),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, index) {
                                        final item = _suggestions[index];
                                        return ListTile(
                                          title: Text(
                                            item.displayName,
                                            style: GoogleFonts.poppins(
                                                color: stardustWhite,
                                                fontSize: 15),
                                          ),
                                          trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color:
                                                  lunarSilver.withOpacity(0.7)),
                                          onTap: () {
                                            _cityController.text =
                                                item.displayName;
                                            setStateSB(
                                                () => _suggestions.clear());
                                            _cityFocusNode.unfocus();
                                            _showSnackbar(
                                                'Location Selected',
                                                'Selected: ${item.displayName}',
                                                celestialGold);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Date Picker
                        _buildThemedTextFormField(
                          controller: _dateController,
                          labelText: "Date",
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _pickDateTime,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit,
                                color: lunarSilver, size: 24),
                            onPressed: _pickDateTime,
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Select a date"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Time Picker
                        _buildThemedTextFormField(
                          controller: _timeController,
                          labelText: "Time",
                          icon: Icons.access_time,
                          readOnly: true,
                          onTap: _pickDateTime,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit,
                                color: lunarSilver, size: 24),
                            onPressed: _pickDateTime,
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Select a time"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Ayanamsa Dropdown
                        _buildThemedDropdownFormField<int>(
                          value: _selectedAyanamsa,
                          labelText: 'Ayanamsa',
                          icon: Icons.bar_chart,
                          items: ayanamsaOptions.map((option) {
                            return DropdownMenuItem<int>(
                              value: option['value'],
                              child: Text(
                                option['label']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: stardustWhite),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _selectedAyanamsa.value = value;
                            }
                          },
                          validator: (val) => val == null ? "Required" : null,
                        ),
                        const SizedBox(height: 20),

                        // Language Dropdown
                        _buildThemedDropdownFormField<String>(
                          value: _selectedLanguage,
                          labelText: 'Language',
                          icon: Icons.language,
                          items: languageOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(
                                option['label']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: stardustWhite),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _selectedLanguage.value = value;
                            }
                          },
                          validator: (val) =>
                              val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => _submit(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: celestialGold,
                                foregroundColor: cosmicBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: celestialGold.withOpacity(0.5),
                              ),
                              child: controller.isLoading.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: cosmicBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          "Generating Kundli...",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18, color: cosmicBlue),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Get Kundli",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: cosmicBlue),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Note: Accurate birth details are crucial for precise Kundli calculations.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lunarSilver,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
