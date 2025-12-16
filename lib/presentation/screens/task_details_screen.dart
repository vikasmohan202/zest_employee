import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/data/models/order_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Order order;
  const TaskDetailsScreen({required this.order, super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late String selectedStatus;
  bool paymentCollected = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.orderStatus.isNotEmpty
        ? widget.order.orderStatus
        : "Picked Up";

    paymentCollected = widget.order.paymentStatus.toLowerCase() == "paid";
  }

  String _formatAddress(Address? address) {
    if (address == null) return "N/A";
    return [
      address.houseNumber,
      address.streetName,
      address.area,
      address.city,
      address.state,
      address.zipCode,
    ].where((e) => e != null && e!.isNotEmpty).join(", ");
  }

  int get _totalItems =>
      widget.order.items.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final user = order.user;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? "Unknown User",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? "N/A",
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
                        _formatAddress(
                          order.deliveryAddress ?? order.pickupAddress,
                        ),
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
                        order.items.firstOrNull?.category?.categoryName ??
                            "Laundry",
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
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _totalItems.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Image (unchanged)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: order.items.first.category?.profileImage ?? '',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// -------- TOTAL + PRIORITY --------
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
                  "₹${order.finalAmount ?? order.totalAmount}",
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

            /// -------- PICKUP BOX --------
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
                    "Time: ${order.scheduledPickupTimeSlot ?? "N/A"}",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  Text(
                    "Address: ${_formatAddress(order.pickupAddress)}",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const SizedBox(height: 20),

            /// -------- ITEMS LIST --------
            Text(
              "Order Items",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _buildItemsList(),

            /// -------- STATUS --------
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
                items:
                    const [
                          "pickup-scheduled",
                          "in-process",
                          "Completed",
                          "Delivered",
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ),
            const SizedBox(height: 16),

            /// -------- PAYMENT --------
            Row(
              children: [
                Checkbox(
                  value: paymentCollected,
                  onChanged: (v) =>
                      setState(() => paymentCollected = v ?? false),
                  activeColor: Colors.lightGreenAccent,
                  checkColor: Colors.black,
                ),
                Text(
                  "Payment Collected (${order.paymentMethod})",
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

            /// -------- DONE --------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    final items = widget.order.items;

    if (items.isEmpty) {
      return Text(
        "No items found",
        style: GoogleFonts.poppins(color: Colors.white),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              /// Item name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category!.categoryName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Category: ${item.category?.categoryName ?? "N/A"}",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "x${item.quantity}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                "₹${item.pricePerPiece}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
