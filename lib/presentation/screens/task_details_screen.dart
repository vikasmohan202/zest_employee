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
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

/// ---------------- LOADER ----------------

void showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
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
  String? orderId;
   TaskDetailsScreen({this.orderId, super.key, required this.order});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  /// ---- STATUS CONSTANTS ----
  static const String pickupScheduled = 'pickup-scheduled';
  static const String inProcess = 'in-process';
  static const String outForDelivery = 'out-for-delivery';
  static const String delivered = 'delivered';
  static const String pickedUp = 'picked-up';

  late List<String> _statuses;
  late String selectedStatus;

  bool paymentCollected = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = _sanitizeStatus(widget.order.orderStatus);
    paymentCollected =
        (widget.order.paymentStatus ?? '').toLowerCase() == 'paid';
  }

  /// ---- STATUS SANITIZER ----
  String _sanitizeStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty) return pickupScheduled;

    return raw
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll(RegExp(r'\s+'), '');
  }

  /// ---- ROLE-BASED STATUS LOGIC ----
  List<String> _getAllowedStatuses({
    required Order order,
    required String employeeId,
  }) {
    final current = _sanitizeStatus(order.orderStatus);

    final isPickupEmployee = order.pickupEmployee != null
        ? order.pickupEmployee!.id == employeeId
        : false;

    final isDeliveryEmployee = order.deliveryEmployee != null
        ? order.deliveryEmployee!.id == employeeId
        : false;

    /// DELIVERY EMPLOYEE
    if (isDeliveryEmployee) {
      // if (current == outForDelivery) {
      return [inProcess, delivered];
      // }
      if (current == delivered) {
        return [delivered];
      }
    }

    /// PICKUP EMPLOYEE
    if (isPickupEmployee) {
      if (current == pickupScheduled) {
        return [pickupScheduled, pickedUp];
      }
      if (current == inProcess) {
        return [inProcess, pickedUp];
      }
    }

    /// DEFAULT → LOCKED
    return [current];
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
          Navigator.pop(context);
        }

        if (state is OrderStatusUpdateFailure) {
          hideLoader(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF315C3D),
        appBar: const CustomAppBar(
          title: 'Detailed Task',
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF315C3D),
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

              /// ---------- ITEMS ----------
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

              const SizedBox(height: 24),

              /// ---------- STATUS ----------
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated) {
                    return const SizedBox();
                  }

                  final employeeId = authState.employee.id;

                  _statuses = _getAllowedStatuses(
                    order: order,
                    employeeId: employeeId,
                  );

                  selectedStatus = _statuses.contains(selectedStatus)
                      ? selectedStatus
                      : _statuses.first;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          value: selectedStatus,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color(0xFF315C3D),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          style: GoogleFonts.poppins(color: Colors.white),
                          items: _statuses
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s.replaceAll('-', ' ').toUpperCase(),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _statuses.length == 1
                              ? null
                              : (val) => setState(() => selectedStatus = val!),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              /// ---------- PAYMENT ----------
              // Row(
              //   children: [
              //     Checkbox(
              //       value: paymentCollected,
              //       activeColor: Colors.lightGreenAccent,
              //       checkColor: Colors.black,
              //       onChanged: selectedStatus == delivered
              //           ? (v) => setState(() => paymentCollected = v ?? false)
              //           : null,
              //     ),
              //     Text(
              //       "Payment Collected (${order.paymentMethod})",
              //       style: GoogleFonts.poppins(color: Colors.white),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 30),

              /// ---------- DONE ----------
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  final isLoading = state is OrderStatusUpdateInProgress;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ||
                              selectedStatus ==
                                  _sanitizeStatus(order.orderStatus)
                          ? null
                          : () {
                              final auth = context.read<AuthBloc>().state;
                              if (auth is! AuthAuthenticated) return;

                              context.read<OrderBloc>().add(
                                OrderStatusUpdated(
                                  orderId: order.id,
                                  status: selectedStatus,
                                  employeeId: auth.employee.id,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCFF7BE),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

  /// ---------------- UI HELPERS ----------------

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
        Text("Address", style: GoogleFonts.poppins(color: Colors.white70)),
        Text(
          _formatAddress(order.deliveryAddress ?? order.pickupAddress),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Text("Quantity", style: GoogleFonts.poppins(color: Colors.white70)),
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
        child: imageUrl == null || imageUrl.isEmpty
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
          "\$${((order.finalAmount ?? order.totalAmount ?? 0).toDouble()).toStringAsFixed(2)}",
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
