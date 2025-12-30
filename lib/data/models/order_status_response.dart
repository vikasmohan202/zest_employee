import 'package:zest_employee/data/models/order_model.dart';

class OrderStatusResponse {
  final String message;
  final Order order;

  OrderStatusResponse({
    required this.message,
    required this.order,
  });

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusResponse(
      message: json['message'] ?? '',
      order: Order.fromJson(json['order'] ?? {}),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'message': message,
  //     'order': order.toJson(),
  //   };
  // }
}
