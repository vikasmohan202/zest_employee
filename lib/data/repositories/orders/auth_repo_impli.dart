// lib/data/repositories/order_repository_impl.dart
import 'package:zest_employee/data/data_providers/order/order_api.dart';
import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/data/repositories/orders/auth_repo.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderApi _api;

  OrderRepositoryImpl({required OrderApi api}) : _api = api;

  @override
  Future<List<Order>> getAllOrders(String id) async {
    // Delegates to OrderApi which should return a list
    return await _api.getAllOrders(id);
  }

  // @override
  // Future<Order?> getOrderById(String id) async {
  //   // If your OrderApi doesn't yet have getOrderById, add it.
  //   if ((_api as dynamic).getOrderById != null) {
  //     return await (_api as dynamic).getOrderById(id) as Order?;
  //   }

  //   // Fallback: fetch all and find by id (inefficient but works until API exists)
  //   final all = await getAllOrders();
  //   return all.firstWhere((o) => o.id == id, orElse: () => null);
  // }

  @override
  Future<Order> createOrder(Order order) async {
    // Assuming OrderApi has createOrder; if not, implement it.
    if ((_api as dynamic).createOrder != null) {
      return await (_api as dynamic).createOrder(order) as Order;
    }

    throw UnimplementedError('createOrder not implemented in OrderApi');
  }

  @override
  Future<Order> updateOrder(String id, Map<String, dynamic> updates) async {
    if ((_api as dynamic).updateOrder != null) {
      return await (_api as dynamic).updateOrder(id, updates) as Order;
    }
    throw UnimplementedError('updateOrder not implemented in OrderApi');
  }

  @override
  Future<Order> updateOrderStatus(String id, String status) async {
    // If API provides a status-specific route, prefer that.
    if ((_api as dynamic).updateOrderStatus != null) {
      return await (_api as dynamic).updateOrderStatus(id, status) as Order;
    }

    // Fallback to partial update
    return await updateOrder(id, {'status': status});
  }

  @override
  Future<void> deleteOrder(String id) async {
    if ((_api as dynamic).deleteOrder != null) {
      await (_api as dynamic).deleteOrder(id);
      return;
    }

    throw UnimplementedError('deleteOrder not implemented in OrderApi');
  }
}
