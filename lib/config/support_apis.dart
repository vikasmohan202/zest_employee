import 'package:zest_employee/config/call_helper.dart';

class SupportApi {
  final CallHelper _helper = CallHelper();

  /// Create Ticket
  Future<ApiResponseWithData<Map<String, dynamic>>> createTicket(
      String subject) async {
    return _helper.postWithData(
      "api/support/create-ticket",
      {"subject": subject},
      {},
    );
  }

  /// My Tickets
  Future<ApiResponseWithData<Map<String, dynamic>>> myTickets() async {
    return _helper.getWithData(
      "api/support/my-tickets",
      {},
    );
  }
  /// Ticket Messages
Future<ApiResponseWithData<Map<String, dynamic>>> ticketMessages(
    String ticketId) async {
  return _helper.getWithData(
    "api/support/ticketMessages/$ticketId",
    {},
  );
}


  /// Send Message
  Future<ApiResponse> sendMessage(
      String ticketId, String message) async {
    return _helper.post(
      "api/support/send-message",
      {
        "ticketId": ticketId,
        "message": message,
      },
    );
  }
}
