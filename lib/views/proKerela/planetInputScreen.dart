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
import '../../utils/global.dart'
    as global; // Add this import if 'global' is defined here

class PlanetInputScreen extends StatefulWidget {
  const PlanetInputScreen({Key? key}) : super(key: key);

  @override
  State<PlanetInputScreen> createState() => _PlanetInputScreenState();
}

class _PlanetInputScreenState extends State<PlanetInputScreen> {
  final PlanetController controller = Get.put(PlanetController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ayanamsaController =
      TextEditingController(text: '1');
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _datetimeController = TextEditingController();

  final FocusNode _placeFocusNode = FocusNode();

  DateTime? selectedDateTime;
  double? _latitude;
  double? _longitude;

  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  CurrentUserWalletModel? _wallet;

  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  @override
  void initState() {
    super.initState();
    _updateDateTimeController(DateTime.now());

    _placeFocusNode.addListener(() {
      if (!_placeFocusNode.hasFocus) {
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
    _ayanamsaController.dispose();
    _placeController.dispose();
    _datetimeController.dispose();
    _placeFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateDateTimeController(DateTime dateTime) {
    setState(() {
      selectedDateTime = dateTime;
      _datetimeController.text = DateFormat("MMM dd, yyyy - hh:mm a")
          .format(dateTime); // Corrected format
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    const int planetPositionPrice = 599;

    if (_formKey.currentState!.validate() && selectedDateTime != null) {
      controller.isLoading(true);

      try {
        // 1️⃣ Fetch wallet balance
        final wallet = await FastAPIServices().fetchCurrentWallet();
        if (wallet == null) {
          _showSnackbar(
            'Wallet Error',
            'Unable to fetch wallet balance. Please try again.',
            warningRed,
          );
          controller.isLoading(false);
          return;
        }

        // 2️⃣ Check balance
        if (wallet.amount < planetPositionPrice) {
          final shortfall = planetPositionPrice - wallet.amount;
          _showSnackbar(
            'Insufficient Balance',
            'You need ₹${shortfall.toStringAsFixed(2)} more to access Planet Positions. Please recharge your wallet.',
            warningRed,
          );
          controller.isLoading(false);
          return;
        }

        // 3️⃣ Geocode if Lat/Lng are missing
        if (_latitude == null || _longitude == null) {
          if (_placeController.text.trim().isEmpty) {
            _showSnackbar('Location Error', 'City/Place name is required.', warningRed);
            controller.isLoading(false);
            return;
          }

          try {
            final locations = await locationFromAddress(_placeController.text.trim());
            if (locations.isNotEmpty) {
              _latitude = locations.first.latitude;
              _longitude = locations.first.longitude;
              _showSnackbar(
                'Location Found',
                'Successfully found coordinates for ${_placeController.text.trim()}',
                celestialGold,
              );
            } else {
              _showSnackbar(
                'Location Error',
                'No precise coordinates found. Enter a valid city/town.',
                warningRed,
              );
              controller.isLoading(false);
              return;
            }
          } catch (e) {
            _showSnackbar(
              'Location Error',
              'Failed to geocode: $e',
              warningRed,
            );
            controller.isLoading(false);
            return;
          }
        }

        // 4️⃣ Deduct using debit API
        final updatedWallet = await FastAPIServices().debitWallet(planetPositionPrice);

        if (updatedWallet == null) {
          _showSnackbar(
            'Payment Failed',
            'Could not deduct from wallet. Try again.',
            warningRed,
          );
          controller.isLoading(false);
          return;
        }

        // 5️⃣ Success
        _showSnackbar(
          'Payment Successful',
          '₹${planetPositionPrice.toStringAsFixed(2)} deducted from your wallet for Planet Position.',
          celestialGold,
        );

        setState(() {
          _wallet = updatedWallet;
        });

        // 6️⃣ Fetch Planet Positions
        await controller.getPlanetPositions(
          ayanamsa: int.parse(_ayanamsaController.text),
          latitude: _latitude!,
          longitude: _longitude!,
          datetime: selectedDateTime!,
        );

        final planetData = controller.planetResponse.value;
        if (planetData != null && planetData.planetPositions.isNotEmpty) {
          Get.to(() => PlanetResultScreen(planetData: planetData));
        } else {
          _showSnackbar(
            'No Data',
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'No planet positions found. Please check your inputs.',
            warningRed,
          );
        }
      } catch (e) {
        _showSnackbar('Unexpected Error', 'Please try again.', warningRed);
      } finally {
        controller.isLoading(false);
      }
    } else {
      if (selectedDateTime == null) {
        _showSnackbar(
          'Required',
          'Please select date & time to proceed.',
          warningRed,
        );
      } else {
        _showSnackbar(
          'Input Error',
          'Please fill all required fields correctly.',
          warningRed,
        );
      }
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
          "Planet Position Calculator",
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
                          "Enter Calculation Details",
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
                        _buildThemedTextFormField(
                          controller: _ayanamsaController,
                          labelText: "Ayanamsa (1-20)",
                          icon: Icons.auto_awesome,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required";
                            if (int.tryParse(val) == null ||
                                int.parse(val) < 1 ||
                                int.parse(val) > 20) {
                              return "Enter a number between 1 and 20";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return Column(
                              children: [
                                _buildThemedTextFormField(
                                  controller: _placeController,
                                  labelText: "City/Place Name",
                                  icon: Icons.location_on,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? "Location is required"
                                          : null,
                                  enableSuggestions: true,
                                  focusNode: _placeFocusNode,
                                  onSuggestionsUpdated: (newSuggestions) {
                                    setStateSB(() {
                                      _suggestions = newSuggestions;
                                    });
                                  },
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
                                            _placeController.text =
                                                item.displayName;
                                            _latitude =
                                                double.tryParse(item.lat);
                                            _longitude =
                                                double.tryParse(item.lon);
                                            setStateSB(
                                                () => _suggestions.clear());
                                            _placeFocusNode.unfocus();
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
                        _buildThemedTextFormField(
                          controller: _datetimeController,
                          labelText: "Date & Time",
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _pickDateTime,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit,
                                color: lunarSilver, size: 24),
                            onPressed: _pickDateTime,
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Select a date & time"
                              : null,
                        ),
                        const SizedBox(height: 30),
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value ? null : _submit,
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
                                          "Calculating...",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18, color: cosmicBlue),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Calculate Planet Positions",
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
                "Note: This calculation uses advanced astrological algorithms to determine planetary positions based on your provided details.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lunarSilver,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
              // NEW ADDITION: NASA Note
              const SizedBox(height: 10), // Some spacing
              Text(
                "Additional Note: The planetary position data utilized in this calculation is sourced from NASA's highly accurate astronomical algorithms.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color:
                      lunarSilver.withOpacity(0.8), // Slightly less prominent
                  fontStyle: FontStyle.italic,
                  fontSize: 13, // Slightly smaller font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
