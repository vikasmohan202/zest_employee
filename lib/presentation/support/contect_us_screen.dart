// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:zest/feature/profile/ui/chat_screen.dart';
// import 'package:zest/feature/profile/ui/create%20ticket.dart';
// import 'package:zest/feature/profile/ui/faq_screen.dart';

// class ContactUsScreen extends StatelessWidget {
//   const ContactUsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(51, 107, 63, 1),
//         elevation: 0,
//         centerTitle: true,
//         automaticallyImplyLeading: true,
//         title: Text(
//           "Contact Us",
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 22),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 12),

//             Text(
//               "Please choose what types of support do you need and let us know.",
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 height: 1.4,
//               ),
//             ),

//             const SizedBox(height: 35),

//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 18,
//                 crossAxisSpacing: 18,
//                 childAspectRatio: 1,
//                 children: [
//                   _supportCard(
//                     context,
//                     icon: Icons.chat_bubble_outline,
//                     iconBg: const Color(0xFF6ED67A),
//                     title: "Support Chat",
//                     subtitle: "24x7 Online Support",
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return CreateTicketScreen();
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                   _supportCard(
//                     context,
//                     icon: Icons.call_outlined,
//                     iconBg: const Color(0xFFF28C6A),
//                     title: "Call Center",
//                     subtitle: "24x7 Customer Service",
//                     onTap: () {},
//                   ),
//                   _supportCard(
//                     context,
//                     icon: Icons.email_outlined,
//                     iconBg: const Color(0xFF9C71F8),
//                     title: "Email",
//                     subtitle: "admin@shifty.com",
//                     onTap: () {},
//                   ),
//                   _supportCard(
//                     context,
//                     icon: Icons.help_outline,
//                     iconBg: const Color(0xFFF5DD59),
//                     title: "FAQ",
//                     subtitle: "+50 Answers",
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return FAQsScreen();
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),
//             _footer(),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _supportCard(
//     BuildContext context, {
//     required IconData icon,
//     required Color iconBg,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF3E6A4E),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.white24, width: 1),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               backgroundColor: iconBg,
//               radius: 28,
//               child: Icon(icon, color: Colors.white, size: 26),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _footer() {
//     return Column(
//       children: [
//         Text(
//           "Made By :",
//           style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Aayan Infotech",
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(width: 8),
//             const Icon(Icons.build, color: Colors.white70, size: 16),
//           ],
//         ),
//       ],
//     );
//   }
// }
