import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/logic/bloc/order/order_bloc.dart';
import 'package:zest_employee/logic/bloc/order/order_event.dart';
import 'package:zest_employee/logic/bloc/order/order_state.dart';

/// ---------------- LOADER HELPERS ----------------

void showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

void hideLoader(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

/// ---------------- SCREEN ----------------

class TaskDetailsScreen extends StatefulWidget {
  final Order order;
  const TaskDetailsScreen({super.key, required this.order});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  /// ---- SINGLE SOURCE OF TRUTH ----
  static const Set<String> _statusSet = {
    'pickup-scheduled',
    'in-process',
    'out-for-delivery',
    // 'completed',
    'delivered',
  };

  late final List<String> _statuses;
  late String selectedStatus;
  bool paymentCollected = false;

  @override
  void initState() {
    super.initState();
    _statuses = _statusSet.toList(growable: false);
    selectedStatus = _sanitizeStatus(widget.order.orderStatus);
    paymentCollected =
        (widget.order.paymentStatus ?? '').toLowerCase() == 'paid';
  }

  /// ---- STATUS SANITIZER ----
  String _sanitizeStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty) return _statuses.first;

    final cleaned = raw
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll(RegExp(r'\s+'), '');

    return _statusSet.contains(cleaned) ? cleaned : _statuses.first;
  }

  String _formatAddress(Address? address) {
    if (address == null) return 'N/A';
    return [
      address.houseNumber,
      address.streetName,
      address.area,
      address.city,
      address.state,
      address.zipCode,
    ].where((e) => e != null && e!.trim().isNotEmpty).join(', ');
  }

  int get _totalItems =>
      widget.order.items.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final user = order.user;
    final imageUrl = order.items.isNotEmpty
        ? order.items.first.category?.profileImage
        : null;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderStatusUpdateInProgress) {
          showLoader(context);
        }

        if (state is OrderLoadSuccess) {
          hideLoader(context);
          Navigator.pop(context); // back to HomeScreen
        }

        if (state is OrderStatusUpdateFailure) {
          hideLoader(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF315C3D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF315C3D),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(
            'Detailed Task',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildUserInfo(order, user)),
                  _buildImage(imageUrl),
                ],
              ),

              const SizedBox(height: 20),

              _buildTotal(order),

              const SizedBox(height: 20),

              _buildPickupInfo(order),

              const SizedBox(height: 24),

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

              const SizedBox(height: 20),

              Text(
                "Status",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white54),
                ),
                child: DropdownButton<String>(
                  value: _statusSet.contains(selectedStatus)
                      ? selectedStatus
                      : _statuses.first,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: const Color(0xFF315C3D),
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: GoogleFonts.poppins(color: Colors.white),
                  items: _statuses
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => selectedStatus = val);
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// -------- PAYMENT --------
              Row(
                children: [
                  Checkbox(
                    value: paymentCollected,
                    activeColor: Colors.lightGreenAccent,
                    checkColor: Colors.black,
                    onChanged: (v) =>
                        setState(() => paymentCollected = v ?? false),
                  ),
                  Text(
                    "Payment Collected (${order.paymentMethod})",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(Icons.qr_code_scanner, color: Colors.white),
                ],
              ),

              const SizedBox(height: 30),

              /// -------- DONE BUTTON --------
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  final bool isLoading =
                      state is OrderStatusUpdateInProgress;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final auth =
                                  context.read<AuthBloc>().state;
                              if (auth is! AuthAuthenticated) return;

                              context.read<OrderBloc>().add(
                                    OrderStatusUpdated(
                                      orderId: widget.order.id,
                                      status: selectedStatus,
                                      employeeId: auth.employee.id,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCFF7BE),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= WIDGETS =================

  Widget _buildUserInfo(Order order, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.fullName ?? 'Unknown User',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.phoneNumber ?? 'N/A',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        Text(
          "Address",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        Text(
          _formatAddress(order.deliveryAddress ?? order.pickupAddress),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Items",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        Text(
          _totalItems.toString(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String? imageUrl) {
    return SizedBox(
      width: 140,
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
      ),
    );
  }

  Widget _buildTotal(Order order) {
    return Row(
      children: [
        Text(
          "Total : ",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        Text(
          "₹${order.finalAmount ?? order.totalAmount ?? 0}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPickupInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFCFF7BE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pickup & Delivery",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Time: ${order.scheduledPickupTimeSlot ?? 'N/A'}"),
          Text("Address: ${_formatAddress(order.pickupAddress)}"),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = widget.order.items;

    if (items.isEmpty) {
      return const Text(
        "No items found",
        style: TextStyle(color: Colors.white),
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
              Expanded(
                child: Text(
                  item.category?.categoryName ?? 'Unknown Item',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "x${item.quantity}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "₹${item.pricePerPiece ?? 0}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
