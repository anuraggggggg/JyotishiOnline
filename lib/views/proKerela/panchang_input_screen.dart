// screens/panchang_input_screen.dart

import 'dart:async'; // Import for Timer

import 'package:AstrowayCustomer/apiManager/apiServices.dart'; // Keep this if needed elsewhere
import 'package:AstrowayCustomer/utils/services/location_service.dart';
import 'package:AstrowayCustomer/views/proKerela/panchang_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Make sure this is imported for DateFormat

import 'package:AstrowayCustomer/utils/global.dart'
    as global; // <--- IMPORTANT: Ensure this is imported for wallet access!
import '../../controllers/proKerela/panchang_controller.dart';
import '../../fastApi/fastApiServices.dart'; // Assuming PanchangFormController is here

class PanchangInputScreen extends StatefulWidget {
  @override
  State<PanchangInputScreen> createState() => _PanchangInputScreenState();
}

class _PanchangInputScreenState extends State<PanchangInputScreen> {
  final PanchangFormController controller = Get.put(PanchangFormController());
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();

  // Timer for debouncing search input
  Timer? _debounce;
  List<LocationSuggestion> _suggestions =
      []; // Moved here to be accessible by dispose

  int _ayanamsa = 1; // Already an int, not a TextEditingController
  double? _latitude;
  double? _longitude;
  DateTime _selectedDateTime = DateTime.now(); // Already a DateTime object
  String _language = 'ml';

  // Define a consistent sophisticated color palette
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite =
      Color(0xFFF0F0F0); // Off-white for readability
  static const Color smokyGrey =
      Color(0xFF4A4A4A); // For input field hints/labels
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver

  @override
  void initState() {
    super.initState();
    // Initialize _placeController text if a default place is desired, otherwise it will be empty
    // _placeController.text = "Mumbai, India"; // Example
    // Initialize date/time picker display
    // Note: If _selectedDateTime needs to be initially set to a specific value other than now, do it here.
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(1900), // Extended date range
      lastDate: DateTime(2150), // Extended date range
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: celestialGold, // Header background color
              onPrimary: cosmicBlue, // Header text color
              onSurface: cosmicBlue, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: cosmicBlue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: celestialGold, // Header background color
                onPrimary: cosmicBlue, // Header text color
                onSurface: cosmicBlue, // Body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: cosmicBlue, // Button text color
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    // Hide keyboard if open
    FocusScope.of(context).unfocus();

    // Panchang service price
    const int panchangServicePrice = 100;

    if (_formKey.currentState!.validate()) {
      controller.isLoading(true);

      // 1️⃣ Fetch wallet balance from API
      final wallet = await FastAPIServices().fetchCurrentWallet();
      if (wallet == null) {
        controller.isLoading(false);
        Get.snackbar(
          'Wallet Error',
          'Unable to fetch wallet balance. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: stardustWhite,
          icon: const Icon(Icons.error_outline, color: stardustWhite),
        );
        return;
      }

      if (wallet.amount < panchangServicePrice) {
        // 2️⃣ Insufficient balance → Show error
        final int missingAmount = panchangServicePrice - wallet.amount;
        controller.isLoading(false);
        Get.snackbar(
          'Insufficient Balance',
          'You need ₹${missingAmount.toStringAsFixed(2)} more to access Daily Panchang. Please recharge your wallet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: stardustWhite,
          icon: const Icon(Icons.account_balance_wallet_outlined, color: stardustWhite),
        );
        return;
      }

      // 3️⃣ Deduct money using debit API
      final updatedWallet = await FastAPIServices().debitWallet(panchangServicePrice);
      if (updatedWallet == null) {
        controller.isLoading(false);
        Get.snackbar(
          'Payment Failed',
          'Could not deduct wallet balance. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: stardustWhite,
          icon: const Icon(Icons.error, color: stardustWhite),
        );
        return;
      }

      // 4️⃣ Success → show snackbar
      Get.snackbar(
        'Payment Successful',
        '₹$panchangServicePrice deducted from your wallet for Daily Panchang.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: celestialGold.withOpacity(0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
      );

      // 🕓 Small delay so user sees success
      await Future.delayed(const Duration(milliseconds: 500));

      // 5️⃣ Proceed with Panchang API
      await controller.loadPanchang(
        ayanamsa: _ayanamsa,
        latitude: _latitude!,
        longitude: _longitude!,
        datetime: _selectedDateTime,
        language: _language,
      );

      controller.isLoading(false);

      if (controller.panchangData.value != null) {
        Get.to(() => PanchangResultScreen(data: controller.panchangData.value!));
      } else if (controller.errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Panchang Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: stardustWhite,
          icon: const Icon(Icons.warning_amber, color: stardustWhite),
        );
      } else {
        Get.snackbar(
          'Panchang Error',
          'Failed to get Panchang data for unknown reasons. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: stardustWhite,
          icon: const Icon(Icons.warning_amber, color: stardustWhite),
        );
      }
    } else {
      Get.snackbar(
        'Input Error',
        'Please ensure all fields are filled correctly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: stardustWhite,
        icon: const Icon(Icons.error, color: stardustWhite),
      );
    }
  }


  @override
  void dispose() {
    _placeController.dispose();
    _debounce?.cancel(); // Cancel the debounce timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panchang Calculator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: cosmicBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: celestialGold.withOpacity(0.7), width: 1.5),
                  ),
                  color: cosmicBlue.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.center, 
                          child: Text(
                            'Enter Cosmic Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: celestialGold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Dropdown for Ayanamsa
                        _buildThemedDropdownFormField<int>(
                          value: _ayanamsa,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Lahiri')),
                            DropdownMenuItem(value: 3, child: Text('Raman')),
                            DropdownMenuItem(value: 5, child: Text('KP')),
                          ],
                          onChanged: (val) => setState(() => _ayanamsa = val!),
                          labelText: 'Select Ayanamsa',
                          icon: Icons.star_border,
                        ),
                        const SizedBox(height: 20),

                        // Suggestion Text Field for Place with Debouncing
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _placeController,
                                  onChanged: (value) {
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }

                                    _debounce =
                                        Timer(const Duration(milliseconds: 500),
                                            () async {
                                      if (value.isEmpty) {
                                        setStateSB(() => _suggestions = []);
                                        _latitude =
                                            null; // Clear lat/lon if text is cleared
                                        _longitude = null;
                                        return;
                                      }

                                      try {
                                        final result = await LocationService
                                            .fetchCitySuggestions(value);
                                        setStateSB(() => _suggestions = result);
                                      } catch (e) {
                                        print('Error fetching suggestions: $e');
                                        setStateSB(() => _suggestions = []);
                                        // Optionally show a temporary message to the user here
                                      }
                                    });
                                  },
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? 'Location is required'
                                          : null,
                                  style: const TextStyle(
                                      color: stardustWhite, fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Birth Place / Current Location',
                                    hintText: 'e.g., Mumbai, India',
                                    labelStyle: const TextStyle(
                                        color: lunarSilver,
                                        fontWeight: FontWeight.w500),
                                    hintStyle: TextStyle(
                                        color: smokyGrey.withOpacity(0.7)),
                                    prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                        color: celestialGold),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: celestialGold.withOpacity(0.5),
                                          width: 1),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                          color: celestialGold, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      // Added error borders for consistency
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.redAccent, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      // Added focused error borders
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: cosmicBlue.withOpacity(0.6),
                                  ),
                                ),
                                // Display suggestions only if there are any
                                if (_suggestions.isNotEmpty)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cosmicBlue.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              celestialGold.withOpacity(0.4)),
                                    ),
                                    margin: const EdgeInsets.only(top: 8),
                                    // Constrain height for the suggestion list
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.3),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, index) {
                                        final item = _suggestions[index];
                                        return ListTile(
                                          title: Text(
                                            item.displayName,
                                            style: const TextStyle(
                                                color: stardustWhite,
                                                fontSize: 14),
                                          ),
                                          onTap: () {
                                            _placeController.text =
                                                item.displayName;
                                            _latitude =
                                                double.tryParse(item.lat);
                                            _longitude =
                                                double.tryParse(item.lon);
                                            setStateSB(() => _suggestions
                                                .clear()); // Clear suggestions
                                            FocusScope.of(context)
                                                .unfocus(); // Unfocus text field
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

                        // Date & Time Picker
                        _buildThemedListTile(
                          title:
                              'Date & Time: ${DateFormat('EEE, MMM d,yyyy – hh:mm a').format(_selectedDateTime)}',
                          icon: Icons.access_time,
                          onTap: _pickDateTime,
                        ),
                        const SizedBox(height: 20),

                        // Dropdown for Language
                        _buildThemedDropdownFormField<String>(
                          value: _language,
                          items: const [
                            DropdownMenuItem(
                                value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                            DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                            DropdownMenuItem(
                                value: 'te', child: Text('Telugu')),
                            DropdownMenuItem(
                                value: 'ml', child: Text('Malayalam')),
                          ],
                          onChanged: (val) => setState(() => _language = val!),
                          labelText: 'Select Language',
                          icon: Icons.language,
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.auto_awesome, color: cosmicBlue, size: 24),
                            label: Flexible( // Added Flexible to prevent overflow
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible( // Added Flexible for text
                                    child: Text(
                                      'Calculate Panchang',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: cosmicBlue,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Handle long text
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Reduced spacing
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                                    decoration: BoxDecoration(
                                      color: cosmicBlue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '₹100 +GST',
                                      style: TextStyle(
                                        fontSize: 12, // Smaller font for price
                                        fontWeight: FontWeight.w600,
                                        color: cosmicBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: celestialGold,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Reduced horizontal padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() {
                  return controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: celestialGold,
                          strokeWidth: 4,
                        )
                      : const SizedBox();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Themed Widgets ---

  Widget _buildThemedDropdownFormField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        if (item.child is Text) {
          final textWidget = item.child as Text;
          return DropdownMenuItem<T>(
            value: item.value,
            child: Text(
              textWidget.data!,
              style: const TextStyle(
                color: stardustWhite,
              ),
            ),
          );
        }
        return DropdownMenuItem<T>(
          value: item.value,
          child: item.child!,
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: cosmicBlue.withOpacity(0.9),
      style: const TextStyle(color: stardustWhite, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            const TextStyle(color: lunarSilver, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: celestialGold.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: celestialGold.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: celestialGold, width: 2),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.6),
      ),
    );
  }

  Widget _buildThemedListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: cosmicBlue.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: celestialGold.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: celestialGold.withOpacity(0.8)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: stardustWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: celestialGold),
          ],
        ),
      ),
    );
  }
}
