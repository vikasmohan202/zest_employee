import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_employee/config/support_apis.dart';
import 'package:zest_employee/presentation/widgets/custom_appbar.dart';

class SupportChatScreen extends StatefulWidget {
  final String ticketId;

  const SupportChatScreen({super.key, required this.ticketId});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final SupportApi _api = SupportApi();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];

  bool loading = true;
  bool isSending = false;
  bool _initialized = false;

  static const Color background = Color(0xFF3E673D);
  static const Color userMessageColor = Color(0xFFDCF7C1);
  static const Color assistantMessageColor = Color(0xFF315A36);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    final res = await _api.ticketMessages(widget.ticketId);

    if (res.success && res.data["messages"] != null) {
      for (final msg in res.data["messages"]) {
        messages.add({
          "message": msg["message"],
          "isMe": msg["senderType"] == "user",
          "time": _formatTime(msg["sentAt"]),
        });
      }
    }

    setState(() => loading = false);
    _scrollToBottom();
  }

  String _formatTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    return TimeOfDay.fromDateTime(date).format(context);
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty || isSending) return;

    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      isSending = true;
      messages.add({
        "message": text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });

    _scrollToBottom();

    final res = await _api.sendMessage(widget.ticketId, text);

    if (!res.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.message)));
    }

    setState(() => isSending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _emptyChatUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              "Start the conversation",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Send your first message and our support team will reply shortly.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: CustomAppBar(title: "Support Chat"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : messages.isEmpty
                  ? _emptyChatUI()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg["isMe"];

                        return Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 6),
                              constraints: const BoxConstraints(maxWidth: 260),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? userMessageColor
                                    : assistantMessageColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                msg["message"],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isMe ? Colors.black87 : Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              msg["time"],
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
            ),

            // ================= INPUT =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFDFFBCF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: background, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(color: background),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: background,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
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
}
