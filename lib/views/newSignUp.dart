// FULL UPDATED CODE — VALIDATIONS FIXED

import 'dart:io';
import 'package:AstrowayCustomer/views/settings/disclaimer_and_guidelines_screen.dart';
import 'package:AstrowayCustomer/views/settings/termsAndConditionScreen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/loginWithEmailScreen.dart';

class SignupWithEmailScreen extends StatefulWidget {
  const SignupWithEmailScreen({super.key});

  @override
  State<SignupWithEmailScreen> createState() => _SignupWithEmailScreenState();
}

class _SignupWithEmailScreenState extends State<SignupWithEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedGender;
  File? _selectedImage;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  final FastAPIServices _apiServices = FastAPIServices();

  // Pick image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // Birth date
  Future<void> _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
    );

    if (picked != null) {
      _birthDateController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // SIGNUP
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      Get.snackbar("Required",
          "Please accept the Terms, Refund Policy & Privacy Policy",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final response = await _apiServices.signupWithDetails(
      name: _nameController.text.trim(),
      contactNo: _contactController.text.trim(),
      countryCode: "+91",
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      pincode: int.tryParse(_pincodeController.text.trim()) ?? 0,
      birthDate: _birthDateController.text.trim(),
      gender: _selectedGender ?? "",
      profilePicPath: _selectedImage?.path,
    );

    setState(() => _isLoading = false);

    if (response != null && response["error"] != true) {
      Get.snackbar("Success", "Account created successfully! Please log in.",
          backgroundColor: Colors.green, colorText: Colors.white);

      await Future.delayed(const Duration(seconds: 1));
      Get.offAll(() => const LoginWithEmailScreen());
    } else {
      Get.snackbar("Error", response?["message"] ?? "Signup failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pincodeController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Image.asset("assets/images/newLogo.png",
                          height: MediaQuery.of(context).size.height * 0.20),
                      const SizedBox(height: 30),

                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Create your account",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                                color: buttonColor1,
                              ))),

                      const SizedBox(height: 20),

                      Form(
                          key: _formKey,
                          child: Column(children: [
                            // Profile pic
                            GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor:
                                    appYellow.withOpacity(0.3),
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : null,
                                    child: _selectedImage == null
                                        ? const Icon(Icons.camera_alt,
                                        color: Colors.black54)
                                        : null)),
                            const SizedBox(height: 20),

                            // ---------------- NAME VALIDATION UPDATED ----------------
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                if (!RegExp(r"^[A-Za-z ]+$")
                                    .hasMatch(value.trim())) {
                                  return "Name should contain only alphabets, numbers and special characters are not allowed";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // ---------------- CONTACT VALIDATION UPDATED ----------------
                            _buildTextField(
                              controller: _contactController,
                              label: 'Contact Number',
                              icon: Icons.phone,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return "Enter a valid contact number";
                                }
                                if (!RegExp(r"^[0-9]{10}$")
                                    .hasMatch(value.trim())) {
                                  return "Enter a valid 10-digit contact number";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // EMAIL
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter your email";
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // PASSWORD
                            _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() => _obscurePassword =
                                      !_obscurePassword);
                                    }),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                }),

                            const SizedBox(height: 16),

                            // CONFIRM PASSWORD
                            _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() => _obscureConfirmPassword =
                                      !_obscureConfirmPassword);
                                    }),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                }),

                            const SizedBox(height: 16),

                            // PINCODE
                            _buildTextField(
                              controller: _pincodeController,
                              label: 'Pincode',
                              icon: Icons.location_on,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length != 6) {
                                  return "Enter a valid 6-digit pincode";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // ---------------- DOB VALIDATION UPDATED ----------------
                            TextFormField(
                                controller: _birthDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Birth Date",
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: buttonColor1),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                ),
                                onTap: _pickBirthDate,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter your date of birth";
                                  }
                                  if (!RegExp(
                                      r"^\d{4}-\d{2}-\d{2}$")
                                      .hasMatch(value)) {
                                    return "Enter a valid date of birth in YYYY-MM-DD format";
                                  }
                                  return null;
                                }),

                            const SizedBox(height: 16),

                            // GENDER
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Gender",
                                prefixIcon: Icon(Icons.person,
                                    color: buttonColor1),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                              ),
                              value: _selectedGender,
                              items: const [
                                DropdownMenuItem(
                                    value: "Male", child: Text("Male")),
                                DropdownMenuItem(
                                    value: "Female", child: Text("Female")),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedGender = value);
                              },
                              validator: (value) =>
                              value == null ? "Select your gender" : null,
                            ),

                            const SizedBox(height: 20),

                            // TERMS CHECKBOX
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isTermsAccepted,
                                  activeColor: buttonColor1,
                                  onChanged: (v) {
                                    setState(() => _isTermsAccepted =
                                        v ?? false);
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                          children: [
                                            const TextSpan(
                                                text:
                                                "By creating an account, you accept our "),
                                            TextSpan(
                                                text:
                                                "Terms & Conditions & Refund Policy",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                                recognizer:
                                                TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Get.to(() =>
                                                        TermAndConditionScreen());
                                                  }),
                                            const TextSpan(text: " and "),
                                            TextSpan(
                                                text: "Privacy Policy",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                                recognizer:
                                                TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Get.to(() =>
                                                        DisclaimerAndGuidelinesScreen());
                                                  })
                                          ])),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // SUBMIT BUTTON
                            _isLoading
                                ? const CircularProgressIndicator(
                              color: appYellow,
                            )
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                const Size(double.infinity, 45),
                                backgroundColor: appYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _signup,
                              child: const Text("Sign Up",
                                  style:
                                  TextStyle(color: Colors.black)),
                            ),

                            const SizedBox(height: 16),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                children: [
                                  const TextSpan(
                                      text: "Already have an account? "),
                                  TextSpan(
                                      text: "Log In",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                      recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () => Get.to(
                                                () => const LoginWithEmailScreen()))
                                ],
                              ),
                            ),
                          ]))
                    ])))));
  }

  // TEXT FIELD BUILDER
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: label == "Contact Number" || label == "Pincode"
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      maxLength: label == "Contact Number"
          ? 10
          : label == "Pincode"
          ? 6
          : null,
      decoration: InputDecoration(
          counterText: "",
          labelText: label,
          prefixIcon: Icon(icon, color: buttonColor1),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
  }
}
