// lib/data/repositories/order_repository.dart
import 'package:zest_employee/data/models/order_model.dart';

abstract class OrderRepository {
  /// Fetch all orders
  Future<List<Order>> getAllOrders(String id);

  /// Fetch single order by id
  // Future<Order?> getOrderById(String id);

  /// Create a new order, returns created Order (or throws)
  Future<Order> createOrder(Order order);

  /// Update order (partial or full) and return updated Order
  Future<Order> updateOrder(String id, Map<String, dynamic> updates);

  /// Change status for an order (e.g., "Delivered", "Cancelled")
  Future<Order> updateOrderStatus(String id, String status);

  /// Delete an order by id (if supported)
  Future<void> deleteOrder(String id);
}
