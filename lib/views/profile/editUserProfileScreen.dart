// lib/pages/edit_customer_details_page.dart
// A fresh, dependency-light page to create/update customer details via FastAPI.
// Uses only: material, intl, image_picker (optional).

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../fastApi/fastApiServices.dart';


class EditCustomerDetailsPage extends StatefulWidget {
  const EditCustomerDetailsPage({super.key});

  @override
  State<EditCustomerDetailsPage> createState() => _EditCustomerDetailsPageState();
}

class _EditCustomerDetailsPageState extends State<EditCustomerDetailsPage> {
  // Form & controllers
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();   // dd-MM-yyyy (UI)
  final _birthTimeCtrl = TextEditingController();   // e.g. 6:05 PM (UI)
  final _birthPlaceCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _locationCtrl = TextEditingController();    // City,State,Country
  final _pincodeCtrl = TextEditingController();
  final _countryCodeCtrl = TextEditingController();

  String _gender = 'Male'; // default
  File? _pickedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _birthDateCtrl.dispose();
    _birthTimeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _locationCtrl.dispose();
    _pincodeCtrl.dispose();
    _countryCodeCtrl.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------
  // Convert dd-MM-yyyy -> yyyy-MM-dd for API
  String? _toApiDate(String? ddMMyyyy) {
    if (ddMMyyyy == null || ddMMyyyy.trim().isEmpty) return null;
    try {
      final d = DateFormat('dd-MM-yyyy').parse(ddMMyyyy.trim());
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (e) {
      debugPrint("🧭 [EditCustomer] ⚠️ Invalid birthDate '$ddMMyyyy' – sending as-is");
      return ddMMyyyy;
    }
  }

  // Convert "6:05 PM" -> "HH:mm" for API (keeps HH:mm if already that)
  String? _toApiTimeHHmm(String? uiTime) {
    if (uiTime == null || uiTime.trim().isEmpty) return null;
    try {
      final t = DateFormat.jm().parse(uiTime.trim());
      return DateFormat('HH:mm').format(t);
    } catch (_) {
      final maybeHHmm = RegExp(r'^\d{2}:\d{2}$');
      if (maybeHHmm.hasMatch(uiTime)) return uiTime;
      debugPrint("🧭 [EditCustomer] ⚠️ Invalid birthTime '$uiTime' – sending as-is");
      return uiTime;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1960),
      lastDate: now,
    );
    if (picked != null) {
      _birthDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _birthTimeCtrl.text = DateFormat.jm().format(dt); // e.g. "6:00 PM"
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _pickedImage = File(img.path));
      debugPrint("🧭 [EditCustomer] Picked image: ${img.path}");
    }
  }

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  // ---------- Submit ----------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final birthDateApi = _toApiDate(_birthDateCtrl.text.trim());
    final birthTimeApi = _toApiTimeHHmm(_birthTimeCtrl.text.trim());
    final birthPlace = _birthPlaceCtrl.text.trim();
    final address1 = _addressLine1Ctrl.text.trim();
    final address2 = _addressLine2Ctrl.text.trim();
    final location = _locationCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final countryCode = _countryCodeCtrl.text.trim();

    final int? pincodeInt = pincode.isEmpty ? null : int.tryParse(pincode);

    debugPrint("🧭 [EditCustomer] 🔵 Submitting:");
    debugPrint("  name=$name | gender=$_gender");
    debugPrint("  birthDate(ui)=${_birthDateCtrl.text} -> api=$birthDateApi");
    debugPrint("  birthTime(ui)=${_birthTimeCtrl.text} -> api=$birthTimeApi");
    debugPrint("  birthPlace=$birthPlace");
    debugPrint("  addressLine1=$address1 | addressLine2=$address2");
    debugPrint("  location=$location | pincode=$pincodeInt | contact=$contact | countryCode=$countryCode");
    debugPrint("  profilePic=${_pickedImage?.path ?? '(none)'}");

    setState(() => _submitting = true);

    try {
      final svc = FastAPIServices();

      final result = await svc.createCustomerDetailFromPath(
        name: name.isEmpty ? null : name,
        contactNo: contact.isEmpty ? null : contact,
        birthDate: birthDateApi,
        birthTime: birthTimeApi,
        birthPlace: birthPlace.isEmpty ? null : birthPlace,
        addressLine1: address1.isEmpty ? null : address1,
        addressLine2: address2.isEmpty ? null : address2,
        location: location.isEmpty ? null : location,
        pincode: pincodeInt,
        gender: _gender.isEmpty ? null : _gender,
        countryCode: countryCode.isEmpty ? null : countryCode,
        profilePicPath: _pickedImage?.path,
      );

      debugPrint("✅ [EditCustomer] Success → ${result.toString()}");
      if (mounted) {
        _showSnack("Profile updated successfully", bg: Colors.green);
        Navigator.of(context).pop(true); // return success
      }
    } catch (e, st) {
      debugPrint("💥 [EditCustomer] Failed: $e");
      debugPrint("💥 Stack: $st");
      if (mounted) _showSnack("Update failed: $e", bg: Colors.red);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                            child: _pickedImage == null
                                ? const Icon(Icons.person, size: 54, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IconButton.filledTonal(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              tooltip: "Change Photo",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: "Name"),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter your name" : null,
                    ),

                    // Gender
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Gender:", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'Male',
                                groupValue: _gender,
                                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                              ),
                              const Text('Male'),
                              const SizedBox(width: 16),
                              Radio<String>(
                                value: 'Female',
                                groupValue: _gender,
                                onChanged: (v) => setState(() => _gender = v ?? 'Female'),
                              ),
                              const Text('Female'),
                              const SizedBox(width: 16),
                              Radio<String>(
                                value: 'Other',
                                groupValue: _gender,
                                onChanged: (v) => setState(() => _gender = v ?? 'Other'),
                              ),
                              const Text('Other'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Contact & Country code
                    TextFormField(
                      controller: _contactCtrl,
                      decoration: const InputDecoration(labelText: "Contact Number"),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      controller: _countryCodeCtrl,
                      decoration: const InputDecoration(labelText: "Country Code (e.g. +91)"),
                      textInputAction: TextInputAction.next,
                    ),

                    // Birth date
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Birth Date (dd-MM-yyyy)",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _pickDate,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Select birth date" : null,
                    ),

                    // Birth time
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _birthTimeCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Birth Time (e.g. 6:05 PM)",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: _pickTime,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Select birth time" : null,
                    ),

                    // Birth place
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _birthPlaceCtrl,
                      decoration: const InputDecoration(labelText: "Place of Birth"),
                      textInputAction: TextInputAction.next,
                    ),

                    // Addresses & location
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressLine1Ctrl,
                      decoration: const InputDecoration(labelText: "Address Line 1"),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter address" : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressLine2Ctrl,
                      decoration: const InputDecoration(labelText: "Address Line 2 (optional)"),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(labelText: "City, State, Country"),
                      textInputAction: TextInputAction.next,
                    ),

                    // Pincode
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pincodeCtrl,
                      decoration: const InputDecoration(labelText: "Pincode"),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Save"),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            if (_submitting)
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
