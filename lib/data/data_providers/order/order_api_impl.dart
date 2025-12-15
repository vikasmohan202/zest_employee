// lib/data/data_providers/order_api_impl.dart
import 'package:zest_employee/core/network/api_clients.dart';
import 'package:zest_employee/core/constants/api_end_point.dart';
import 'package:zest_employee/data/data_providers/order/order_api.dart';
import 'package:zest_employee/data/models/order_model.dart';

class OrderApiImpl implements OrderApi {
  final ApiClient _api;

  OrderApiImpl(this._api);

 

  @override
  Future<List<Order>> getAllOrders(String id) async {
    final url = "${Endpoints.baseUrl}${Endpoints.getAllOrder}/$id";

    final json = await _api.get(
      url
     // Endpoints.baseUrl + Endpoints.getAllOrder+"${/id}",
    );

    // Example JSON:
    // { "success": true, "orders": [ {...}, {...} ] }
    final List<dynamic> list = json['orders'] ?? [];

    return list
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
