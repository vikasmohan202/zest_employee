import 'package:flutter/material.dart';
import 'package:zest_employee/presentation/screens/motificatios.dart';
import 'package:zest_employee/presentation/screens/task_details_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final Color _bg = const Color.fromRGBO(51, 107, 63, 1);

  // 0 => Picked, 1 => Completed, 2 => Delivered
  int selectedIndex = 0;

  final List<Order> orders = [
    Order(
      name: 'John',
      phone: '+1234567890',
      time: '12:00 PM',
      priority: 'High Priority',
      address: '123 Main St. , NYC',
      service: 'Iron',
      items: '01',
      status: OrderStatus.Picked,
    ),
    Order(
      name: 'Mike',
      phone: '+1234567890',
      time: '1:00 PM',
      priority: 'Medium Priority',
      address: '456 Elm St., NYC',
      service: 'Dry Cleaning',
      items: '02',
      status: OrderStatus.Completed,
    ),
    Order(
      name: 'Priya',
      phone: '+919876543210',
      time: '2:00 PM',
      priority: 'Low Priority',
      address: '789 Market Rd. , Jakarta',
      service: 'Wash & Fold',
      items: '03',
      status: OrderStatus.Delivered,
    ),
    Order(
      name: 'Ravi',
      phone: '+919123456789',
      time: '3:30 PM',
      priority: 'High Priority',
      address: '10 Street Blvd, Delhi',
      service: 'Steam Iron',
      items: '02',
      status: OrderStatus.Remaining,
    ),
  ];

  final List<String> _segments = ['Picked', 'Completed', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    // Precompute lists for each status
    final pickedOrders = orders
        .where((e) => e.status == OrderStatus.Picked)
        .toList();
    final completedOrders = orders
        .where((e) => e.status == OrderStatus.Completed)
        .toList();
    final deliveredOrders = orders
        .where((e) => e.status == OrderStatus.Delivered)
        .toList();

    return Scaffold(
      backgroundColor: _bg,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Jakarta, Indonesia',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const NotificationScreen();
                              },
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Heading
              const Text(
                'Active Orders',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // Segmented control (ChoiceChips)
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_segments.length, (i) {
                    final isSelected = selectedIndex == i;
                    return ChoiceChip(
                      // labelPadding: const EdgeInsets.symmetric(
                      //   horizontal: 16,
                      //   vertical: 6,
                      // ),
                      label: Text(
                        _segments[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.green : Colors.white,
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false, // 👈 hides the check icon
                      backgroundColor: _bg.withOpacity(
                        .7,
                      ), // green for unselected
                      selectedColor: Colors.white, // white for selected
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedIndex = i;
                        });
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Content area - IndexedStack retains state of each list
              SizedBox(
                height: 600,
                child: IndexedStack(
                  index: selectedIndex,
                  children: [
                    _buildOrderList(context, pickedOrders),
                    _buildOrderList(context, completedOrders),
                    _buildOrderList(context, deliveredOrders),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No orders', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: buildOrderCard(
            context: context,
            order: o,
            cardColor: const Color(0xFFDFF6D8),
            cardShadow: const Color(0x1A000000),
            bgColor: _bg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskDetailsScreen()),
              );
            },
          ),
        );
      },
    );
  }
}

enum OrderStatus { Picked, Completed, Delivered, Remaining }

class Order {
  final String name;
  final String phone;
  final String time;
  final String priority;
  final String address;
  final String service;
  final String items;
  final OrderStatus status;

  Order({
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

// Keep your existing buildOrderCard implementation (unchanged).
Widget buildOrderCard({
  required BuildContext context,
  required Order order,
  required Color cardColor,
  required Color cardShadow,
  required Color bgColor,
  VoidCallback? onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap, // Makes the card tappable
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
                // --- HEADER (Name, Phone, Time, Priority) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    Text(
                      order.phone,
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
                            order.time,
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
                        order.priority,
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

                // --- DETAILS ROW (Address, Service, Items, Arrow) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address column
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

                    // Service column
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

                    // Items column + arrow
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

                    // Arrow button
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
