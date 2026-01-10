import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart'; // Add this import

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
  final Color _primaryColor = const Color.fromRGBO(51, 107, 63, 1);
  final Color _secondaryColor = const Color.fromRGBO(76, 175, 80, 1);
  final Color _accentColor = const Color.fromRGBO(255, 193, 7, 1);
  final Color _cardColor = const Color.fromRGBO(255, 255, 255, 1);
  final Color _textColor = const Color.fromRGBO(33, 33, 33, 1);
  final Color _lightTextColor = const Color.fromRGBO(117, 117, 117, 1);

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
        }
      },
      child: BlocProvider.value(
        value: _orderBloc,
        child: Scaffold(
          backgroundColor: _primaryColor,
          body: SafeArea(
            child: RefreshIndicator(
              backgroundColor: _primaryColor,
              color: Colors.white,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Header Sliver
                  SliverAppBar(
                    backgroundColor: _primaryColor,
                    expandedHeight: 180.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _primaryColor,
                              _primaryColor.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Welcome Text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome, $employeeName",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Let\'s make today productive!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Notification Icon with Badge
                                  Stack(
                                    children: [
                                      IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const NotificationScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Stats Section
                  SliverToBoxAdapter(child: _buildStatsSection(context)),
                  // Orders Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        if (state is OrderLoadInProgress ||
                            state is OrderInitial) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading orders...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (state is OrderLoadFailure) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Failed to load orders',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      state.message,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: _primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        final astate = context
                                            .read<AuthBloc>()
                                            .state;
                                        if (astate is AuthAuthenticated) {
                                          final employee = astate.employee;
                                          _orderBloc.add(
                                            OrderFetched(id: employee.id),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Try Again',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (state is OrderEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.checklist_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 64,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No Active Orders',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'All caught up! New orders will appear here.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _secondaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 14,
                                        ),
                                      ),
                                      onPressed: _onRefresh,
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.refresh, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Refresh',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (state is OrderLoadSuccess) {
                          final uiOrders = state.orders
                              .map(_mapServerToUi)
                              .toList();
                          final activeOrders = uiOrders
                              .where((o) => o.status != UiOrderStatus.Delivered)
                              .toList();

                          if (activeOrders.isEmpty) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.assignment_turned_in,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 64,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'All Orders Completed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Great job! You\'ve completed all active orders.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildEnhancedOrderCard(
                                  context: context,
                                  order: activeOrders[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailsScreen(
                                          order: state.orders.firstWhere(
                                            (order) =>
                                                order.id ==
                                                activeOrders[index].id,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }, childCount: activeOrders.length),
                          );
                        }

                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _secondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.today, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      if (state is OrderLoadSuccess) {
                        final todayCount = state.orders.length;
                        return Text(
                          '$todayCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Total Orders',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      if (state is OrderLoadSuccess) {
                        final activeCount = state.orders
                            .where(
                              (o) =>
                                  _mapStatusString(o.orderStatus) !=
                                  UiOrderStatus.Delivered,
                            )
                            .length;
                        return Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOrderCard({
    required BuildContext context,
    required UiOrder order,
    VoidCallback? onTap,
  }) {
    final bool isHighPriority = order.priority.toLowerCase().contains('high');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHighPriority
                      ? [Colors.red.shade100, Colors.red.shade50]
                      : [_primaryColor.withOpacity(0.1), Colors.green.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Customer Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryColor.withOpacity(0.1),
                      border: Border.all(
                        color: _primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        order.name.isNotEmpty
                            ? order.name[0].toUpperCase()
                            : 'C',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: _lightTextColor),
                            const SizedBox(width: 4),
                            Text(
                              order.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: _lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isHighPriority
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHighPriority
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isHighPriority ? Icons.warning : Icons.check_circle,
                          size: 12,
                          color: isHighPriority ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.priority,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isHighPriority ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Order Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Time Row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 16,
                        color: _secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.time,
                          style: TextStyle(
                            fontSize: 14,
                            color: _textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Details Grid
                  Row(
                    children: [
                      _buildDetailItem(
                        icon: Icons.location_on,
                        label: 'Address',
                        value: order.address,
                        flex: 3,
                      ),
                      const SizedBox(width: 12),
                      _buildDetailItem(
                        icon: Icons.category,
                        label: 'Service',
                        value: order.service,
                        flex: 2,
                      ),
                      const SizedBox(width: 12),
                      _buildDetailItem(
                        icon: Icons.inventory,
                        label: 'Items',
                        value: order.items,
                        flex: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: onTap,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: _lightTextColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _lightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(UiOrderStatus status) {
    switch (status) {
      case UiOrderStatus.Picked:
        return Colors.orange;
      case UiOrderStatus.Completed:
        return Colors.green;
      case UiOrderStatus.Delivered:
        return Colors.blue;
      case UiOrderStatus.Remaining:
        return Colors.grey;
    }
  }

  String _getStatusText(UiOrderStatus status) {
    switch (status) {
      case UiOrderStatus.Picked:
        return 'Picked';
      case UiOrderStatus.Completed:
        return 'Completed';
      case UiOrderStatus.Delivered:
        return 'Delivered';
      case UiOrderStatus.Remaining:
        return 'Pending';
    }
  }
}
