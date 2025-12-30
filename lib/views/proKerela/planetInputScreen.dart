import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/proKerela/planet_controller.dart';
import 'package:AstrowayCustomer/views/proKerela/planet_result_screen.dart';
import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/currentUserWalletModel.dart';
import '../../utils/services/location_service.dart';

class PlanetInputScreen extends StatefulWidget {
  final serviceName ;
  final servicePrice;

  const PlanetInputScreen({super.key ,  required this.servicePrice ,  required this.serviceName});

  @override
  State<PlanetInputScreen> createState() => _PlanetInputScreenState();
}

class _PlanetInputScreenState extends State<PlanetInputScreen> {
  final PlanetController controller = Get.put(PlanetController());
  final _formKey = GlobalKey<FormState>();

  // Replaced the free-text ayanamsa with a dropdown.
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _datetimeController = TextEditingController();

  final FocusNode _placeFocusNode = FocusNode();

  DateTime? selectedDateTime;
  double? _latitude;
  double? _longitude;

  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  CurrentUserWalletModel? _wallet;

  // Theme
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  // Supported languages for `la` param (Prokerala)
  static const List<Map<String, String>> languages = [
    {'value': 'en', 'label': 'English'},
    {'value': 'hi', 'label': 'Hindi'},
    {'value': 'ta', 'label': 'Tamil'},
    {'value': 'te', 'label': 'Telugu'},
    {'value': 'ml', 'label': 'Malayalam'},
  ];

  // Ayanamsa options (exact values)
  static const List<Map<String, dynamic>> ayanamsaOptions = [
    {'value': 1, 'label': 'Lahiri (1)'},
    {'value': 3, 'label': 'Raman (3)'},
    {'value': 5, 'label': 'KP (5)'},
  ];
  int _selectedAyanamsa = 1; // default Lahiri

  @override
  void initState() {
    super.initState();
    _updateDateTimeController(DateTime.now());

    _placeFocusNode.addListener(() {
      if (!_placeFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _suggestions.clear());
        });
      }
    });
  }

  @override
  void dispose() {
    _placeController.dispose();
    _datetimeController.dispose();
    _placeFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateDateTimeController(DateTime dateTime) {
    setState(() {
      selectedDateTime = dateTime;
      _datetimeController.text =
          DateFormat("MMM dd, yyyy - hh:mm a").format(dateTime);
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: celestialGold,
            onPrimary: cosmicBlue,
            surface: stardustWhite,
            onSurface: cosmicBlue,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
        TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: celestialGold,
              onPrimary: cosmicBlue,
              surface: stardustWhite,
              onSurface: cosmicBlue,
            ),
          ),
          child: child!,
        ),
      );

      if (time != null) {
        final fullDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _updateDateTimeController(fullDateTime);
      }
    }
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
            _latitude = null;
            _longitude = null;
            return;
          }
          try {
            final result = await LocationService.fetchCitySuggestions(value);
            onSuggestionsUpdated?.call(result);
          } catch (_) {
            onSuggestionsUpdated?.call([]);
          }
        });
      }
          : null,
      style: GoogleFonts.poppins(color: stardustWhite, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
        GoogleFonts.poppins(color: lunarSilver, fontWeight: FontWeight.w500),
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: celestialGold, width: 2.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: warningRed, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: warningRed, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      validator: validator,
    );
  }

  Widget _buildLangDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedLanguage.value,
      items: languages
          .map((e) => DropdownMenuItem<String>(
        value: e['value'],
        child: Text(e['label']!,
            style: GoogleFonts.poppins(color: stardustWhite)),
      ))
          .toList(),
      onChanged: (val) => controller.selectedLanguage.value = val ?? 'en',
      decoration: InputDecoration(
        labelText: 'Language',
        labelStyle: GoogleFonts.poppins(
            color: lunarSilver, fontWeight: FontWeight.w500),
        prefixIcon: const Icon(Icons.language, color: celestialGold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: celestialGold, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
      ),
      dropdownColor: cosmicBlue.withOpacity(0.95),
    ));
  }

  Widget _buildAyanamsaDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedAyanamsa,
      items: ayanamsaOptions
          .map((opt) => DropdownMenuItem<int>(
        value: opt['value'] as int,
        child: Text(
          opt['label'] as String,
          style: GoogleFonts.poppins(color: stardustWhite),
        ),
      ))
          .toList(),
      onChanged: (val) => setState(() => _selectedAyanamsa = val ?? 1),
      validator: (val) => val == null ? 'Required' : null,
      decoration: InputDecoration(
        labelText: 'Ayanamsa',
        helperText: 'Lahiri = 1, Raman = 3, KP = 5',
        helperStyle: GoogleFonts.poppins(color: lunarSilver, fontSize: 12),
        labelStyle:
        GoogleFonts.poppins(color: lunarSilver, fontWeight: FontWeight.w500),
        prefixIcon: const Icon(Icons.auto_awesome, color: celestialGold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: celestialGold, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
      ),
      dropdownColor: cosmicBlue.withOpacity(0.95),
    );
  }

  void _snack(String title, String message, Color backgroundColor) {
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
        size: 28,
      ),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
      barBlur: 5,
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    print('========== PLANET SUBMIT START ==========');

    // 🔥 FIX: use widget.servicePrice safely
    final int planetPositionPrice = widget.servicePrice.toInt();
    print('Service Price (int): ₹$planetPositionPrice');

    if (!(_formKey.currentState?.validate() ?? false) ||
        selectedDateTime == null) {
      _snack(
        'Required',
        'Please select date & time and fill all required fields.',
        warningRed,
      );
      return;
    }

    controller.isLoading(true);

    try {
      // 1️⃣ Wallet
      print('Fetching wallet...');
      final wallet = await FastAPIServices().fetchCurrentWallet();

      if (wallet == null) {
        print('ERROR: Wallet fetch failed');
        _snack(
          'Wallet Error',
          'Unable to fetch wallet balance. Please try again.',
          warningRed,
        );
        return;
      }

      print('Wallet balance: ₹${wallet.amount}');

      if (wallet.amount < planetPositionPrice) {
        final shortfall = planetPositionPrice - wallet.amount;
        print('ERROR: Insufficient balance. Missing ₹$shortfall');

        _snack(
          'Insufficient Balance',
          'You need ₹$shortfall more to access Planet Positions.',
          warningRed,
        );
        return;
      }

      // 2️⃣ Ensure coordinates
      if (_latitude == null || _longitude == null) {
        print('Coordinates missing, geocoding...');
        if (_placeController.text.trim().isEmpty) {
          _snack('Location Error', 'City/Place name is required.', warningRed);
          return;
        }

        try {
          final locations =
          await locationFromAddress(_placeController.text.trim());
          if (locations.isEmpty) {
            print('ERROR: Geocoding returned empty');
            _snack(
              'Location Error',
              'No precise coordinates found.',
              warningRed,
            );
            return;
          }

          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;

          print('Latitude: $_latitude');
          print('Longitude: $_longitude');
        } catch (e) {
          print('ERROR: Geocoding failed → $e');
          _snack('Location Error', 'Failed to geocode location.', warningRed);
          return;
        }
      }

      // 3️⃣ Debit wallet
      print('Debiting wallet: ₹$planetPositionPrice');
      final updatedWallet =
      await FastAPIServices().debitWallet(planetPositionPrice);

      if (updatedWallet == null) {
        print('ERROR: Wallet debit failed');
        _snack(
          'Payment Failed',
          'Could not deduct from wallet. Try again.',
          warningRed,
        );
        return;
      }

      print('Wallet debited successfully');
      _snack(
        'Payment Successful',
        '₹$planetPositionPrice deducted for Planet Position.',
        celestialGold,
      );

      setState(() => _wallet = updatedWallet);

      // 4️⃣ Fetch planet positions
      print('Calling Planet Position API...');
      await controller.getPlanetPositions(
        ayanamsa: _selectedAyanamsa,
        latitude: _latitude!,
        longitude: _longitude!,
        datetime: selectedDateTime!,
        language: controller.selectedLanguage.value,
      );

      final planetData = controller.planetResponse.value;

      if (planetData != null && planetData.planetPositions.isNotEmpty) {
        print('Planet data received successfully');
        Get.to(() => PlanetResultScreen(planetData: planetData));
      } else {
        print('ERROR: Planet API returned no data');
        _snack(
          'No Data',
          controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : 'No planet positions found.',
          warningRed,
        );
      }
    } catch (e, stackTrace) {
      print('========== PLANET SUBMIT EXCEPTION ==========');
      print(e);
      print(stackTrace);
      _snack('Unexpected Error', 'Please try again.', warningRed);
    } finally {
      controller.isLoading(false);
      print('========== PLANET SUBMIT END ==========');
    }
  }


  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Planet Position Calculator',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: stardustWhite,
                fontSize: 22,
                letterSpacing: 1.2)),
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
            colors: [cosmicBlue, darkAccent, mediumAccent],
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
                        Text('Enter Calculation Details',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: celestialGold,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 30),

                        // Ayanamsa dropdown (required)
                        _buildAyanamsaDropdown(),
                        const SizedBox(height: 20),

                        // Language dropdown
                        _buildLangDropdown(),
                        const SizedBox(height: 20),

                        // City with suggestions
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return Column(
                              children: [
                                _buildThemedTextFormField(
                                  controller: _placeController,
                                  labelText: 'City/Place Name',
                                  icon: Icons.location_on,
                                  validator: (val) => val == null ||
                                      val.trim().isEmpty
                                      ? 'Location is required'
                                      : null,
                                  enableSuggestions: true,
                                  focusNode: _placeFocusNode,
                                  onSuggestionsUpdated: (newSuggestions) =>
                                      setStateSB(
                                              () => _suggestions = newSuggestions),
                                ),
                                if (_suggestions.isNotEmpty &&
                                    _placeFocusNode.hasFocus)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cosmicBlue.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                          celestialGold.withOpacity(0.4)),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4))
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
                                          title: Text(item.displayName,
                                              style: GoogleFonts.poppins(
                                                  color: stardustWhite,
                                                  fontSize: 15)),
                                          trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: lunarSilver
                                                  .withOpacity(0.7)),
                                          onTap: () {
                                            _placeController.text =
                                                item.displayName;
                                            _latitude =
                                                double.tryParse(item.lat);
                                            _longitude =
                                                double.tryParse(item.lon);
                                            setStateSB(
                                                    () => _suggestions.clear());
                                            _placeFocusNode.unfocus();
                                            _snack(
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

                        // Date & Time
                        _buildThemedTextFormField(
                          controller: _datetimeController,
                          labelText: 'Date & Time',
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _pickDateTime,
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: lunarSilver, size: 24),
                              onPressed: _pickDateTime),
                          validator: (val) =>
                          val == null || val.isEmpty
                              ? 'Select a date & time'
                              : null,
                        ),
                        const SizedBox(height: 30),

                        // Submit
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: celestialGold,
                              foregroundColor: cosmicBlue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              elevation: 8,
                              shadowColor:
                              celestialGold.withOpacity(0.5),
                            ),
                            child: controller.isLoading.value
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                    CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: cosmicBlue)),
                                SizedBox(width: 15),
                                Text('Calculating...'),
                              ],
                            )
                                : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Calculate Planet Positions',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: cosmicBlue)),
                                const SizedBox(height: 4),
                                Text("₹ ${widget.servicePrice}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: cosmicBlue)),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                  'Note: This calculation uses advanced astrological algorithms to determine planetary positions based on your provided details.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: lunarSilver,
                      fontStyle: FontStyle.italic,
                      fontSize: 14)),
              const SizedBox(height: 10),
              Text(
                  'Additional Note: The planetary position data utilized in this calculation is sourced from NASA\'s highly accurate astronomical algorithms.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: lunarSilver.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
