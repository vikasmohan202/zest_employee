import 'package:flutter/material.dart';
import 'package:zest_employee/presentation/screens/home_screen.dart';
import 'package:zest_employee/presentation/screens/order_screen.dart';
import 'package:zest_employee/presentation/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: const Color.fromRGBO(201, 248, 186, 1),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            elevation: 0,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: 'My Day',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),

          // /// ✅ Tip indicator under selected item
          // Positioned(
          //   top: 10,
          //   right: -10,
          //   left:
          //       (_currentIndex * MediaQuery.of(context).size.width / 3) +
          //       (MediaQuery.of(context).size.width / 6) -
          //       14,
          //   child: Container(
          //     child: Image.asset("assets/images/bow_indicator.png"),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class BowIndicator extends StatelessWidget {
  const BowIndicator({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 35,
      child: CustomPaint(painter: _BowPainter(color)),
    );
  }
}

class _BowPainter extends CustomPainter {
  final Color color;
  _BowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
