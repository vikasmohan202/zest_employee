

import 'order_model.dart';

class OrderResult {
  final bool success;
  final String message;
  final Order? order;

  OrderResult({
    required this.success,
    required this.message,
    this.order,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(
      success: json['success'] ?? false,
      message: (json['message'] ?? '').toString(),
      order: json['order'] != null ? Order.fromJson(json['order'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'order': order == null ? null : {} // not used for requests
    };
  }

  @override
  String toString() => 'OrderResult(success: $success, message: $message, order: $order)';
}
