import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/CustomerDetailModel.dart';
import '../../theme/appTheme.dart';

class EditCustomerDetailsPage extends StatefulWidget {
  const EditCustomerDetailsPage({super.key});

  @override
  State<EditCustomerDetailsPage> createState() => _EditCustomerDetailsPageState();
}

class _EditCustomerDetailsPageState extends State<EditCustomerDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _birthTimeCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _countryCodeCtrl = TextEditingController();

  String _gender = 'Male';
  File? _pickedImage;
  String? _existingProfileImageUrl;

  bool _loading = true;
  bool _submitting = false;
  late FastAPIServices _svc;

  @override
  void initState() {
    super.initState();
    _svc = FastAPIServices();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _loading = true);
      await _svc.loadFromStorage();

      // Prefill from current user profile
      final CustomerDetail current = await _svc.fetchCurrentUserDetails();

      _nameCtrl.text         = current.name?.trim() ?? '';
      _contactCtrl.text      = current.contactNo?.trim() ?? '';
      _birthDateCtrl.text    = _fromApiDate(current.birthDate);
      _birthTimeCtrl.text    = _fromApiTime(current.birthTime);
      _birthPlaceCtrl.text   = current.birthPlace?.trim() ?? '';
      _addressLine1Ctrl.text = current.addressLine1?.trim() ?? '';
      _addressLine2Ctrl.text = current.addressLine2?.trim() ?? '';
      _locationCtrl.text     = current.location?.trim() ?? '';
      _pincodeCtrl.text      = (current.pincode == null) ? '' : current.pincode.toString();
      _countryCodeCtrl.text  = current.countryCode?.trim() ?? '';

      final g = (current.gender ?? '').toLowerCase();
      if (g == 'female') _gender = 'Female';
      else if (g == 'other' || g == 'others' || g == 'non-binary') _gender = 'Other';
      else _gender = 'Male';

      _existingProfileImageUrl = current.profileImageUrl?.trim();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load your profile: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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

  String _fromApiDate(String? yMd) {
    if (yMd == null || yMd.trim().isEmpty) return '';
    try {
      final d = DateFormat('yyyy-MM-dd').parse(yMd.trim());
      return DateFormat('dd-MM-yyyy').format(d);
    } catch (_) {
      return yMd;
    }
  }

  String _fromApiTime(String? hhmm) {
    if (hhmm == null || hhmm.trim().isEmpty) return '';
    try {
      final t = DateFormat('HH:mm').parse(hhmm.trim());
      return DateFormat.jm().format(t);
    } catch (_) {
      return hhmm;
    }
  }

  String? _toApiDate(String? ddMMyyyy) {
    if (ddMMyyyy == null || ddMMyyyy.trim().isEmpty) return null;
    try {
      final d = DateFormat('dd-MM-yyyy').parse(ddMMyyyy.trim());
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (_) {
      return ddMMyyyy;
    }
  }

  String? _toApiTimeHHmm(String? uiTime) {
    if (uiTime == null || uiTime.trim().isEmpty) return null;
    try {
      final t = DateFormat.jm().parse(uiTime.trim());
      return DateFormat('HH:mm').format(t);
    } catch (_) {
      final maybeHHmm = RegExp(r'^\d{2}:\d{2}\$');
      if (maybeHHmm.hasMatch(uiTime)) return uiTime;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _birthTimeCtrl.text = DateFormat.jm().format(dt);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _pickedImage = File(img.path));
    }
  }

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure we have a user_id for path param
    await _svc.loadFromStorage();
    final uid = _svc.userId;
    if (uid == null || uid.isEmpty) {
      _showSnack('No user id in storage. Please login again.', bg: Colors.red);
      return;
    }

    final name        = _nameCtrl.text.trim();
    final contact     = _contactCtrl.text.trim();
    final birthDate   = _toApiDate(_birthDateCtrl.text.trim());
    final birthTime   = _toApiTimeHHmm(_birthTimeCtrl.text.trim());
    final birthPlace  = _birthPlaceCtrl.text.trim();
    final address1    = _addressLine1Ctrl.text.trim();
    final address2    = _addressLine2Ctrl.text.trim();
    final location    = _locationCtrl.text.trim();
    final pincodeTxt  = _pincodeCtrl.text.trim();
    final countryCode = _countryCodeCtrl.text.trim();
    final int? pincodeInt = pincodeTxt.isEmpty ? null : int.tryParse(pincodeTxt);

    setState(() => _submitting = true);
    try {
      final updated = await _svc.patchCustomerDetailByUserId(
        userId: uid,
        name: name.isEmpty ? null : name,
        contactNo: contact.isEmpty ? null : contact,
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace.isEmpty ? null : birthPlace,
        addressLine1: address1.isEmpty ? null : address1,
        addressLine2: address2.isEmpty ? null : address2,
        location: location.isEmpty ? null : location,
        pincode: pincodeInt,
        gender: _gender.isEmpty ? null : _gender,
        countryCode: countryCode.isEmpty ? null : countryCode,
        profilePicPath: _pickedImage?.path,
      );

      if (!mounted) return;
      _showSnack("Profile updated successfully", bg: Theme.of(context).colorScheme.primary);
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Update failed: $e", bg:  appYellow);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _loading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your profile...',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : AbsorbPointer(
        absorbing: _submitting,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _pickedImage != null
                                      ? Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  )
                                      : (_existingProfileImageUrl != null && _existingProfileImageUrl!.isNotEmpty)
                                      ? Image.network(
                                    _existingProfileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.camera_alt, size: 20),
                                    color: Colors.white,
                                    tooltip: "Change Photo",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Information Section
                    _buildSectionTitle('Personal Information'),

                    _buildTextField(
                      controller: _nameCtrl,
                      label: "Full Name",
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your name" : null,
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                              // margin: 8,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ['Male', 'Female', 'Other'].map((gender) {
                                return Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: gender,
                                        groupValue: _gender,
                                        onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                                        activeColor: Theme.of(context).colorScheme.primary,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Text(
                                        gender,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _countryCodeCtrl,
                            label: "Country Code",
                            hintText: "+91",
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: _buildTextField(
                            controller: _contactCtrl,
                            label: "Contact Number",
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),

                    // Birth Details Section
                    _buildSectionTitle('Birth Details'),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _birthDateCtrl,
                            label: "Birth Date",
                            readOnly: true,
                            onTap: _pickDate,
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Please select birth date" : null,
                            suffixIcon: IconButton(
                              onPressed: _pickDate,
                              icon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _birthTimeCtrl,
                            label: "Birth Time",
                            readOnly: true,
                            onTap: _pickTime,
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Please select birth time" : null,
                            suffixIcon: IconButton(
                              onPressed: _pickTime,
                              icon: Icon(
                                Icons.access_time,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _buildTextField(
                      controller: _birthPlaceCtrl,
                      label: "Place of Birth",
                      textInputAction: TextInputAction.next,
                    ),

                    // Address Section
                    _buildSectionTitle('Address Information'),

                    _buildTextField(
                      controller: _addressLine1Ctrl,
                      label: "Address Line 1",
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your address" : null,
                    ),

                    _buildTextField(
                      controller: _addressLine2Ctrl,
                      label: "Address Line 2 (Optional)",
                      textInputAction: TextInputAction.next,
                    ),

                    _buildTextField(
                      controller: _locationCtrl,
                      label: "City, State, Country",
                      textInputAction: TextInputAction.next,
                    ),

                    _buildTextField(
                      controller: _pincodeCtrl,
                      label: "Pincode",
                      keyboardType: TextInputType.number,
                    ),

                    // Submit Button
                    Container(
                      margin: const EdgeInsets.only(top: 32, bottom: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _submitting
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Saving...",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Save Changes",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            if (_submitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Updating Profile...',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}