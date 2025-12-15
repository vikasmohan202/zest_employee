import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  String selectedStatus = "Picked Up";
  bool paymentCollected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF315C3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF315C3D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detailed Task",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Text + Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Doe",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "+1234567890",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Pickup or Delivery Address",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "123 Main St., NYC",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Service Type",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Dry Cleaning",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Items",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "01",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    "assets/images/shirt_pic.png",
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total + Priority
            Row(
              children: [
                Text(
                  "Total : ",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "\$20",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF914D),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "High Priority",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Light Green Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFCFF7BE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pickup & Delivery",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time: 12:00 PM",
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Address: 123 Main St., NYC",
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Dropdown
            Text(
              "Status",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white54),
              ),
              child: DropdownButton(
                value: selectedStatus,
                underline: const SizedBox(),
                isExpanded: true,
                dropdownColor: const Color(0xFF315C3D),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: GoogleFonts.poppins(color: Colors.white),
                items: ["Picked Up", "In Progress", "Completed", "Delivered"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Checkbox
            Row(
              children: [
                Checkbox(
                  value: paymentCollected,
                  onChanged: (v) => setState(() => paymentCollected = v!),
                  activeColor: Colors.lightGreenAccent,
                  checkColor: Colors.black,
                ),
                Text(
                  "Payment Collected (Cash)",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // DONE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCFF7BE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
