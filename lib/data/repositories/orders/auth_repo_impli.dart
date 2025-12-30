// lib/data/repositories/order_repository_impl.dart
import 'package:zest_employee/data/data_providers/order/order_api.dart';
import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/data/models/order_status_response.dart';
import 'package:zest_employee/data/repositories/orders/auth_repo.dart';
class OrderRepositoryImpl implements OrderRepository {
  final OrderApi _api;

  OrderRepositoryImpl({required OrderApi api}) : _api = api;

  @override
  Future<List<Order>> getAllOrders(String id) {
    return _api.getAllOrders(id);
  }

  @override
  Future<OrderStatusResponse> updateOrderStatus(
    String id,
    String status,
  ) {
    return _api.updateOrderStatus(id, status);
  }

  // Not implemented yet (safe)
  @override
  Future<Order> createOrder(Order order) {
    throw UnimplementedError();
  }

  @override
  Future<Order> updateOrder(String id, Map<String, dynamic> updates) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteOrder(String id) {
    throw UnimplementedError();
  }
}
