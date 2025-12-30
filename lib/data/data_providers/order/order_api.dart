import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/data/models/order_status_response.dart';

abstract class OrderApi {
  Future<List<Order>> getAllOrders(String id);

  Future<OrderStatusResponse> updateOrderStatus(
    String id,
    String orderStatus,
  );
}
