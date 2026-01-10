import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/config/injection_container.dart';

import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/logic/bloc/order/order_bloc.dart';
import 'package:zest_employee/logic/bloc/order/order_event.dart';
import 'package:zest_employee/logic/bloc/order/order_state.dart';
import 'package:zest_employee/presentation/screens/motificatios.dart';
import 'package:zest_employee/presentation/screens/task_details_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final Color _bg = const Color.fromRGBO(51, 107, 63, 1);
  int selectedIndex = 0;

  final List<String> _segments = [
    'in-process',
    'pickup-scheduled',
    'Delivered',
  ];

  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = sl<OrderBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _orderBloc.add(OrderFetched(id: authState.employee.id));
      }
    });
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc, // ✅ VERY IMPORTANT
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoadInProgress) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is OrderLoadFailure) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              // 📭 EMPTY
              if (state is OrderEmpty) {
                return const Center(
                  child: Text(
                    'No Orders Found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // ✅ SUCCESS
              if (state is OrderLoadSuccess) {
                final picked = state.orders
                    .where((e) => e.orderStatus == 'in-process')
                    .toList();

                final completed = state.orders
                    .where((e) => e.orderStatus == 'pickup-scheduled')
                    .toList();

                final delivered = state.orders
                    .where((e) => e.orderStatus == 'delivered')
                    .toList();

                return _buildBody(context, picked, completed, delivered);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Order> picked,
    List<Order> completed,
    List<Order> delivered,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 22),
          const Text(
            'Active Orders',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _segmentControl(),
          const SizedBox(height: 16),
          SizedBox(
            height: 600,
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildOrderList(context, picked),
                _buildOrderList(context, completed),
                _buildOrderList(context, delivered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text('Jakarta, Indonesia', style: TextStyle(color: Colors.white)),
              Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _segmentControl() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_segments.length, (i) {
          final isSelected = selectedIndex == i;
          return ChoiceChip(
            label: Text(
              _segments[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.green : Colors.white,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            backgroundColor: _bg.withOpacity(.7),
            selectedColor: Colors.white,
            onSelected: (_) => setState(() => selectedIndex = i),
          );
        }),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('No orders', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: buildOrderCard(
            context: context,
            order: order,
            cardColor: const Color(0xFFDFF6D8),
            cardShadow: const Color(0x1A000000),
            bgColor: _bg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailsScreen(order: order),
                ),
              ).then((_) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  _orderBloc.add(OrderFetched(id: authState.employee.id));
                }
              });
            },
          ),
        );
      },
    );
  }
}

Widget buildOrderCard({
  required BuildContext context,
  required Order order,
  required Color cardColor,
  required Color cardShadow,
  required Color bgColor,
  VoidCallback? onTap,
}) {
  final customerName = order.user?.fullName ?? 'Customer';
  final phone = order.user?.phoneNumber ?? '-';

  final time = order.createdAt != null
      ? '${order.createdAt!.hour}:${order.createdAt!.minute}'
      : '-';

  final priority = order.orderStatus;

  final address =
      order.pickupAddress?.area ??
      order.deliveryAddress?.area ??
      'Address not available';

  final service = order.items.isNotEmpty
      ? order.items.first.category?.categoryName ?? '-'
      : '-';

  final itemsCount = order.items.length.toString();

  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// DETAILS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup or Delivery Address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Type',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            service,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            itemsCount,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
