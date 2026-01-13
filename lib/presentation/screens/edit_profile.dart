import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:zest_employee/core/constants/branded_primary_button.dart';
import 'package:zest_employee/core/constants/branded_primary_textfield.dart';
import 'package:zest_employee/data/models/admin_model.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_event.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

class EditProfileScreen extends StatefulWidget {
  final Admin employee;

  const EditProfileScreen({super.key, required this.employee});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController zipController;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  String selectedState = "Pennsylvania";
  String countryFlag = "🇺🇸";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee.fullName);
    emailController = TextEditingController(text: widget.employee.email);
    phoneController = TextEditingController(
      text: widget.employee.phoneNumber ?? '',
    );
    addressController = TextEditingController();
    zipController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    zipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context);
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
        appBar: CustomAppBar(
          backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
          elevation: 0,
          centerTitle: true,
          title: "Edit Profile",
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    /// PROFILE IMAGE (UPDATED)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (widget.employee.profileImage != null &&
                                      widget.employee.profileImage!.isNotEmpty)
                                ? NetworkImage(widget.employee.profileImage!)
                                : const AssetImage("assets/images/user.jpg")
                                      as ImageProvider,
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black38,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    BrandedTextField(
                      controller: nameController,
                      labelText: "Full Name",
                    ),
                    const SizedBox(height: 35),

                    BrandedTextField(
                      controller: emailController,
                      labelText: "Email Address",
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: false,
                    ),
                    const SizedBox(height: 35),

                    BrandedTextField(
                      controller: phoneController,
                      labelText: "Phone Number",
                      isEnabled: false,
                      prefix: GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (country) {
                              setState(() {
                                countryFlag = country.flagEmoji;
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 8),
                          child: Text(
                            countryFlag,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),

                    // const SizedBox(height: 35),

                    // BrandedTextField(
                    //   controller: addressController,
                    //   labelText: "Current Address",
                    //   minLines: 1,
                    //   maxLines: 2,
                    // ),
                    const SizedBox(height: 35),

                    BrandedPrimaryButton(
                      name: "Save Changes",
                      isTextBlack: true,
                      onPressed: _onSavePressed,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    context.read<AuthBloc>().add(
      AuthUpdateProfileRequested(
        employeeId: widget.employee.id,
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        position: widget.employee.position ?? '',
        profileImage: _selectedImage, // 🔥 IMAGE PASSED
      ),
    );
  }

  Widget _stateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedState,
          dropdownColor: const Color(0xFF3E6A4E),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => selectedState = value!),
          items: const [
            "Pennsylvania",
            "Ohio",
            "Texas",
            "California",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }
}
