import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/config/support_apis.dart';
import 'package:zest_employee/presentation/support/chat_screen.dart';
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final TextEditingController _subjectCtrl = TextEditingController();
  final SupportApi _api = SupportApi();

  bool loading = true;
  Map<String, dynamic>? openTicket;
  List<Map<String, dynamic>> pastTickets = [];

  static const Color background = Color(0xFF3E673D);
  static const Color cardColor = Color(0xFFDFFBCF);

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final res = await _api.myTickets();

    if (res.success && res.data["tickets"] != null) {
      final tickets = List<Map<String, dynamic>>.from(res.data["tickets"]);

      for (final t in tickets) {
        if (t["status"] != "closed" && openTicket == null) {
          openTicket = t;
        } else {
          pastTickets.add(t);
        }
      }
    }

    setState(() => loading = false);
  }

  Future<void> createTicket() async {
    if (_subjectCtrl.text.trim().isEmpty) return;

    setState(() => loading = true);

    final res = await _api.createTicket(_subjectCtrl.text.trim());

    setState(() => loading = false);

    if (res.success) {
      final ticketId = res.data["ticket"]['_id'] ?? res.data["_id"];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SupportChatScreen(ticketId: ticketId),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create ticket")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: CustomAppBar(title: "Support"),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    if (openTicket != null) _openTicketUI(),
                    if (openTicket == null) _createTicketUI(),
                    if (pastTickets.isNotEmpty) _pastTicketsUI(),
                  ],
                ),
              ),
      ),
    );
  }

  // ================= OPEN TICKET =================
  Widget _openTicketUI() {
    return _ticketCard(
      title: openTicket!["subject"],
      status: openTicket!["status"],
      buttonText: "Open Chat",
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupportChatScreen(ticketId: openTicket!["_id"]),
          ),
        );
      },
    );
  }

  // ================= CREATE TICKET =================
  Widget _createTicketUI() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _header("Create New Ticket"),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Support Request",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: background,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _subjectCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter ticket subject...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: createTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Create Ticket",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= PAST TICKETS =================
  Widget _pastTicketsUI() {
    return Column(
      children: [
        const SizedBox(height: 30),
        _header("Past Tickets"),
        ...pastTickets.map(
          (t) => _ticketCard(
            title: t["subject"],
            status: t["status"],
            buttonText: "View",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupportChatScreen(ticketId: t["_id"]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= REUSABLE CARD =================
  Widget _ticketCard({
    required String title,
    required String status,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: background,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Status: $status",
              style: GoogleFonts.poppins(color: background),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
