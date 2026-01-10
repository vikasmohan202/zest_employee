import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:zest_employee/data/models/order_model.dart' as sm;
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/logic/bloc/order/order_bloc.dart';
import 'package:zest_employee/logic/bloc/order/order_event.dart';
import 'package:zest_employee/logic/bloc/order/order_state.dart';
import 'package:zest_employee/presentation/screens/motificatios.dart';
import 'package:zest_employee/presentation/screens/task_details_screen.dart';

// Service locator
final sl = GetIt.instance;

enum UiOrderStatus { Picked, Completed, Delivered, Remaining }

class UiOrder {
  final String id;
  final String name;
  final String phone;
  final String time;
  final String priority;
  final String address;
  final String service;
  final String items;
  final UiOrderStatus status;

  UiOrder({
    required this.id,
    required this.name,
    required this.phone,
    required this.time,
    required this.priority,
    required this.address,
    required this.service,
    required this.items,
    required this.status,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _bg = const Color.fromRGBO(51, 107, 63, 1);

  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = sl<OrderBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final employee = authState.employee;
        _orderBloc.add(OrderFetched(id: employee.id));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  UiOrder _mapServerToUi(sm.Order s) {
    final name =
        s.user?.fullName ??
        s.deliveryEmployee?.fullName ??
        s.pickupEmployee?.fullName ??
        'Unknown';
    final phone =
        s.user?.phoneNumber ??
        s.deliveryEmployee?.phoneNumber ??
        s.pickupEmployee?.phoneNumber ??
        '';
    String time;
    if (s.scheduledPickupDate != null && s.scheduledPickupTimeSlot != null) {
      time = '${s.scheduledPickupDate} • ${s.scheduledPickupTimeSlot}';
    } else if (s.createdAt != null) {
      final dt = s.createdAt!;
      time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      time = '';
    }
    final priority =
        (s.priceHistory.isNotEmpty && s.priceHistory.last.updatedAmount > 1000)
        ? 'High Priority'
        : 'Normal';
    final address =
        s.deliveryAddress?.area ??
        '' +
            ', ' +
            (s.deliveryAddress?.city ?? '') +
            ', ' +
            (s.deliveryAddress?.state ?? '');
    final service = s.items.isNotEmpty && s.items.first.category != null
        ? s.items.first.category!.categoryName
        : 'General';
    final items = s.items.length.toString();
    final status = _mapStatusString(s.orderStatus);

    return UiOrder(
      id: s.id,
      name: name,
      phone: phone,
      time: time,
      priority: priority,
      address: address,
      service: service,
      items: items,
      status: status,
    );
  }

  UiOrderStatus _mapStatusString(String v) {
    final s = v.toLowerCase();
    if (s.contains('in-process')) return UiOrderStatus.Picked;
    if (s.contains('pickup-scheduled,')) return UiOrderStatus.Completed;
    if (s.contains('delivered')) return UiOrderStatus.Delivered;
    return UiOrderStatus.Remaining;
  }

  Future<void> _onRefresh() async {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final employee = state.employee;
      _orderBloc.add(OrderRefreshed(employee.id));
    }
    await _orderBloc.stream.firstWhere((s) => s is! OrderLoadInProgress);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final employeeName = authState is AuthAuthenticated
        ? authState.employee.fullName
        : '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _orderBloc.add(OrderFetched(id: authState.employee.id));
        } else {}
      },
      child: BlocProvider.value(
        value: _orderBloc,
        child: Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoadInProgress || state is OrderInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OrderLoadFailure) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Center(child: Text('Error: ${state.message}')),
                        const SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final astate = context.read<AuthBloc>().state;
                              if (astate is AuthAuthenticated) {
                                final employee = astate.employee;
                                _orderBloc.add(OrderFetched(id: employee.id));
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is OrderEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No active orders')),
                      ],
                    );
                  }

                  if (state is OrderLoadSuccess) {
                    final uiOrders = state.orders.map(_mapServerToUi).toList();
                    final activeOrders = uiOrders
                        .where((o) => o.status != UiOrderStatus.Delivered)
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  // Icon(
                                  //   Icons.location_on_outlined,
                                  //   color: Colors.white70,
                                  //   size: 18,
                                  // ),
                                  SizedBox(width: 6),
                                  Text(
                                    employeeName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  // Icon(
                                  //   Icons.keyboard_arrow_down,
                                  //   color: Colors.white70,
                                  //   size: 18,
                                  // ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Welcome 👋",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[50],
                          ),
                        ),
                        Text(
                          'Lets make today productive!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[100],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Active Orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeOrders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No active orders'),
                          )
                        else
                          ...activeOrders.map((o) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: buildOrderCard(
                                context: context,
                                order: o,
                                cardColor: const Color(0xFFDFF6D8),
                                cardShadow: const Color(0x1A000000),
                                bgColor: _bg,
                                onTap: () {
                                  // navigate to details if needed
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TaskDetailsScreen(
                                        order: state.orders.firstWhere(
                                          (order) => order.id == o.id,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        const SizedBox(height: 24),
                      ],
                    );
                  }

                  if (state is OrderLoadOneSuccess) {
                    final sm.Order s = state.order;
                    final ui = _mapServerToUi(s);
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          buildOrderCard(
                            context: context,
                            order: ui,
                            cardColor: const Color(0xFFDFF6D8),
                            cardShadow: const Color(0x1A000000),
                            bgColor: _bg,
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A safe network image helper that avoids uncaught image exceptions
Widget safeNetworkImage(
  String? url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget? placeholder,
}) {
  if (url == null || url.isEmpty) {
    return placeholder ?? SizedBox(width: width, height: height);
  }

  // Basic sanity check: require http/https
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    // invalid url — return placeholder so it won't crash image system
    return placeholder ?? SizedBox(width: width, height: height);
  }

  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    // show progress while loading
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      final expected = loadingProgress.expectedTotalBytes;
      final loaded = loadingProgress.cumulativeBytesLoaded;
      final value = (expected != null && expected > 0)
          ? loaded / expected
          : null;
      return SizedBox(
        width: width,
        height: height,
        child: Center(child: CircularProgressIndicator(value: value)),
      );
    },
    // handle errors (DNS, 404, connectivity)
    errorBuilder: (context, error, stackTrace) {
      // log for debugging (optional)
      // debugPrint('safeNetworkImage load error: $error');
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 36),
      );
    },
  );
}

Widget buildOrderCard({
  required BuildContext context,
  required UiOrder order,
  required Color cardColor,
  required Color cardShadow,
  required Color bgColor,
  VoidCallback? onTap,
}) {
  final bool isHighPriority = order.priority.toLowerCase().contains('high');

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                order.phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
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
                    // Text(
                    // DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(order.time)),
                    //   style: TextStyle(fontSize: 12, color: Colors.green[800]),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.priority,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isHighPriority ? Colors.red : Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup or Delivery Address',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.address,
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
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.service,
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
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.items,
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
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
