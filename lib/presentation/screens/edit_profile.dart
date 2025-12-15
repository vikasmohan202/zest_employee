import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/core/constants/branded_primary_button.dart';
import 'package:zest_employee/core/constants/branded_primary_textfield.dart';
import 'package:country_picker/country_picker.dart';
import 'package:zest_employee/data/models/admin_model.dart';

class EditProfileScreen extends StatefulWidget {
  Admin? employee;
  EditProfileScreen({super.key, this.employee});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: "theKStark",
  );
  final TextEditingController emailController = TextEditingController(
    text: "ikstark@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "(+1) 999 999 999",
  );
  final TextEditingController addressController = TextEditingController(
    text: "907 Valley Drive, Allentown",
  );
  final TextEditingController zipController = TextEditingController(
    text: "18109",
  );

  String selectedState = "Pennsylvania";
  String countryFlag = "🇺🇸";
  @override
  void initState() {
    // TODO: implement initState
    nameController.text = widget.employee?.fullName ?? '';
    emailController.text = widget.employee?.email ?? '';
    phoneController.text = widget.employee?.phoneNumber ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 107, 63, 1),

      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 25),

              /// Profile Picture
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage("assets/images/user.jpg"),
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
              ),
              const SizedBox(height: 35),

              /// Phone Field with Flag Picker
              BrandedTextField(
                controller: phoneController,
                labelText: "Phone Number",
                prefix: GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (country) {
                        setState(() => countryFlag = country.flagEmoji);
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
              const SizedBox(height: 35),

              BrandedTextField(
                controller: addressController,
                labelText: "Current Address",
                minLines: 1,
                maxLines: 2,
              ),

              const SizedBox(height: 35),

              Row(
                children: [
                  Expanded(
                    child: BrandedTextField(
                      controller: zipController,
                      labelText: "Zip Code",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _stateDropdown()),
                ],
              ),

              const SizedBox(height: 40),
              // BrandedPrimaryButton(
              //   name: "Change Password",
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) {
              //           return ChangePasswordScreen();
              //         },
              //       ),
              //     );
              //   },
              //   isTextBlack: true,
              //   isUnfocus: true,
              //   isEnabled: true,
              // ),
              const SizedBox(height: 30),

              BrandedPrimaryButton(
                name: "Save Changes",
                onPressed: () => Navigator.pop(context),
                isTextBlack: true,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedState,
          dropdownColor: const Color(0xFF3E6A4E),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => selectedState = value!),
          items: [
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
