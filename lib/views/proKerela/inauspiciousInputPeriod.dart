import 'package:AstrowayCustomer/views/proKerela/InauspiciousScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import '../../controllers/proKerela/inauspiciousController.dart';
import 'package:intl/intl.dart'; // Import for date/time formatting

class InauspiciousInputScreen extends StatefulWidget {
  const InauspiciousInputScreen({super.key});

  @override
  State<InauspiciousInputScreen> createState() => _InauspiciousInputScreenState();
}

class _InauspiciousInputScreenState extends State<InauspiciousInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final InauspiciousController controller = Get.put(InauspiciousController());

  int selectedAyanamsa = 1;
  String selectedLanguage = 'en';
  double? latitude;
  double? longitude;
  bool isLoading = false;

  // Define a consistent sophisticated color palette
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability
  static const Color smokyGrey = Color(0xFF4A4A4A); // For input field hints/labels
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver

  @override
  void initState() {
    super.initState();
    // Initialize with current date and time
    final now = DateTime.now();
    dateController.text = DateFormat('yyyy-MM-dd').format(now);
    timeController.text = DateFormat('HH:mm').format(now);

    // Initialize city with Mumbai for consistency and ease of use
    cityController.text = 'Mumbai';
  }

  Future<void> _getCoordinatesFromCity() async {
    final city = cityController.text.trim();
    if (city.isEmpty) {
      _showSnackbar('Error', 'Please enter a city name', Colors.redAccent);
      return;
    }

    try {
      setState(() => isLoading = true); // Show loading when fetching coords
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        _showSnackbar('Success', 'Coordinates found for $city', Colors.green);
      } else {
        latitude = null;
        longitude = null;
        _showSnackbar('Error', 'Could not find coordinates for "$city". Please try another city or a more specific address.', Colors.redAccent);
      }
    } catch (e) {
      latitude = null;
      longitude = null;
      _showSnackbar('Error', 'Failed to get location: $e', Colors.redAccent);
    } finally {
      setState(() => isLoading = false); // Hide loading after fetching coords
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withOpacity(0.8),
      colorText: stardustWhite,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: Icon(backgroundColor == Colors.redAccent ? Icons.error_outline : Icons.check_circle_outline, color: stardustWhite),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Only fetch coordinates if they haven't been successfully retrieved or if city changed
    // For simplicity, we'll re-fetch every time or rely on the button
    // It's better to have a dedicated 'Get Coordinates' button or validate lat/long presence
    await _getCoordinatesFromCity(); // Ensure coordinates are fetched before proceeding

    if (latitude == null || longitude == null) {
      _showSnackbar('Validation Error', 'Latitude and Longitude are required. Please ensure the city is valid.', Colors.redAccent);
      setState(() => isLoading = false);
      return;
    }

    try {
      final date = dateController.text.trim();
      final time = timeController.text.trim();
      // Ensure time is always in HH:MM format for parsing
      final datetimeStr = '$date ${time.padRight(5, '0')}';
      final datetime = DateTime.parse(datetimeStr);

      await controller.loadInauspiciousData(
        ayanamsa: selectedAyanamsa,
        latitude: latitude!,
        longitude: longitude!,
        datetime: datetime,
        language: selectedLanguage,
      );

      if (controller.inauspiciousData.value != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InauspiciousScreen(
              inauspiciousData: controller.inauspiciousData.value!,
            ),
          ),
        );
      } else {
        _showSnackbar('No Data', 'No inauspicious data found for the given criteria.', Colors.orangeAccent);
      }
    } catch (e) {
      _showSnackbar('Data Fetch Error', 'Failed to fetch data: ${e.toString()}', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    dateController.dispose();
    timeController.dispose();
    controller.dispose(); // Dispose GetX controller if not managed globally
    super.dispose();
  }

  // --- Reusable Themed Widgets ---

  // Helper for themed text fields
  Widget _buildThemedTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: stardustWhite, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: lunarSilver, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: smokyGrey.withOpacity(0.7)),
        prefixIcon: icon != null ? Icon(icon, color: celestialGold.withOpacity(0.8)) : null,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: celestialGold.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: celestialGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.6),
      ),
    );
  }

  // Helper for themed dropdown fields
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
        return DropdownMenuItem<T>(
          value: item.value,
          child: Text(
            (item.child as Text).data!,
            style: const TextStyle(
              color: stardustWhite, // Text color inside dropdown
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: cosmicBlue.withOpacity(0.9),
      style: const TextStyle(color: stardustWhite, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: lunarSilver, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: celestialGold.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: celestialGold.withOpacity(0.5), width: 1),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inauspicious Period Finder',
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: celestialGold.withOpacity(0.7), width: 1.5),
                    ),
                    color: cosmicBlue.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Find Inauspicious Timings',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: celestialGold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildThemedTextFormField(
                            controller: cityController,
                            labelText: 'City Name',
                            hintText: 'e.g., Mumbai',
                            icon: Icons.location_city,
                            validator: (val) => val == null || val.isEmpty ? 'Enter city' : null,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search, color: celestialGold),
                              onPressed: isLoading ? null : _getCoordinatesFromCity,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildThemedTextFormField(
                            controller: dateController,
                            readOnly: true,
                            labelText: 'Date (YYYY-MM-DD)',
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
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
                              if (picked != null) {
                                dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                            validator: (val) => val == null || val.isEmpty ? 'Enter date' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildThemedTextFormField(
                            controller: timeController,
                            readOnly: true,
                            labelText: 'Time (HH:MM, 24-hour)',
                            icon: Icons.access_time,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
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
                              if (picked != null) {
                                timeController.text =
                                    picked.hour.toString().padLeft(2, '0') +
                                        ':' +
                                        picked.minute.toString().padLeft(2, '0');
                              }
                            },
                            validator: (val) => val == null || val.isEmpty ? 'Enter time' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: celestialGold.withOpacity(0.7), width: 1.5),
                    ),
                    color: cosmicBlue.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildThemedDropdownFormField<int>(
                            value: selectedAyanamsa,
                            labelText: 'Ayanamsa System',
                            icon: Icons.star_border,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Lahiri (1)')),
                              DropdownMenuItem(value: 3, child: Text('Raman (3)')),
                              DropdownMenuItem(value: 5, child: Text('KP (5)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedAyanamsa = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildThemedDropdownFormField<String>(
                            value: selectedLanguage,
                            labelText: 'Language',
                            icon: Icons.language,
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                              DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                              DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                              DropdownMenuItem(value: 'te', child: Text('Telugu')),
                              DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedLanguage = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: cosmicBlue,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.warning_amber, color: cosmicBlue), // Thematic icon
                      label: isLoading
                          ? const Text('Calculating...', style: TextStyle(color: cosmicBlue))
                          : const Text(
                        'Find Inauspicious Periods',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cosmicBlue,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: celestialGold,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
        ),
      ),
    );
  }
}