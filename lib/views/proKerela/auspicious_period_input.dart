import 'package:AstrowayCustomer/views/proKerela/auspicious_period_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../apiManager/apiServices.dart';
import 'package:get/get.dart'; // Import GetX for snackbar

class AuspiciousPeriodInputScreen extends StatefulWidget {
  final ApiService apiService;

  const AuspiciousPeriodInputScreen({super.key, required this.apiService});

  @override
  _AuspiciousPeriodInputScreenState createState() => _AuspiciousPeriodInputScreenState();
}

class _AuspiciousPeriodInputScreenState extends State<AuspiciousPeriodInputScreen> {
  final _formKey = GlobalKey<FormState>();
  // Defaulting to Mumbai, India coordinates for a better user experience
  final _latitudeController = TextEditingController(text: '19.0760');
  final _longitudeController = TextEditingController(text: '72.8777');
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  int _ayanamsa = 1; // Default to Lahiri
  String _language = 'en';
  bool _isLoading = false;

  // Define a consistent sophisticated color palette
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability
  static const Color smokyGrey = Color(0xFF4A4A4A); // For input field hints/labels
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = _formatDate(now);
    _timeController.text = _formatTime(now);
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _formatTime(DateTime time) => DateFormat('HH:mm').format(time); // Use HH:mm for 24-hour format

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        int.parse(_dateController.text.split('-')[0]),
        int.parse(_dateController.text.split('-')[1]),
        int.parse(_dateController.text.split('-')[2]),
        int.parse(_timeController.text.split(':')[0]),
        int.parse(_timeController.text.split(':')[1]),
      );

      // Navigate to the result screen
      Get.to(() => AuspiciousPeriodResultScreen(
        apiService: widget.apiService,
        ayanamsa: _ayanamsa,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        datetime: dateTime,
        language: _language,
      ));
    } catch (e) {
      Get.snackbar(
        'Calculation Error',
        'Failed to process request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: stardustWhite,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Icons.error_outline, color: stardustWhite),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Auspicious Period Finder',
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
        // Add these lines to ensure the container fills available space
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
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
                            'Enter Auspicious Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: celestialGold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        Row(
                          children: [
                            Expanded(
                              child: _buildThemedTextFormField(
                                controller: _latitudeController,
                                labelText: 'Latitude',
                                hintText: 'e.g., 19.0760 (Mumbai)',
                                icon: Icons.map,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (double.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildThemedTextFormField(
                                controller: _longitudeController,
                                labelText: 'Longitude',
                                hintText: 'e.g., 72.8777 (Mumbai)',
                                icon: Icons.map,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (double.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildThemedTextFormField(
                                controller: _dateController,
                                labelText: 'Date',
                                icon: Icons.calendar_today,
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
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
                                  if (date != null) {
                                    _dateController.text = _formatDate(date);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildThemedTextFormField(
                                controller: _timeController,
                                labelText: 'Time',
                                icon: Icons.access_time,
                                readOnly: true,
                                onTap: () async {
                                  final time = await showTimePicker(
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
                                  if (time != null) {
                                    _timeController.text = _formatTime(
                                        DateTime(2000, 1, 1, time.hour, time.minute)); // Dummy date for time format
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildThemedDropdownFormField<int>(
                          value: _ayanamsa,
                          labelText: 'Ayanamsa System',
                          icon: Icons.star_border,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Lahiri (1)')),
                            DropdownMenuItem(value: 3, child: Text('Raman (3)')),
                            DropdownMenuItem(value: 5, child: Text('KP (5)')),
                          ],
                          onChanged: (value) => setState(() => _ayanamsa = value!),
                        ),
                        const SizedBox(height: 20),
                        _buildThemedDropdownFormField<String>(
                          value: _language,
                          labelText: 'Language',
                          icon: Icons.language,
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                            DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                            DropdownMenuItem(value: 'te', child: Text('Telugu')),
                            DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                          ],
                          onChanged: (value) => setState(() => _language = value!),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitForm,
                            icon: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: cosmicBlue,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.auto_awesome, color: cosmicBlue),
                            label: _isLoading
                                ? const Text('Calculating...', style: TextStyle(color: cosmicBlue))
                                : const Text(
                              'Find Auspicious Periods',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}