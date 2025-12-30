// lib/data/data_providers/order_api_impl.dart
import 'package:zest_employee/core/network/api_clients.dart';
import 'package:zest_employee/core/constants/api_end_point.dart';
import 'package:zest_employee/data/data_providers/order/order_api.dart';
import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/data/models/order_status_response.dart';

class OrderApiImpl implements OrderApi {
  final ApiClient _api;

  OrderApiImpl(this._api);

  @override
  Future<OrderStatusResponse> updateOrderStatus(
    String id,
    String orderStatus,
  ) async {
    final url = "${Endpoints.baseUrl}${Endpoints.updateOrderStatus}$id";

    final json = await _api.put(
      url,
      body: {'status': orderStatus},
    );

    return OrderStatusResponse.fromJson(json);
  }

  @override
  Future<List<Order>> getAllOrders(String id) async {
    final url = "${Endpoints.baseUrl}${Endpoints.getAllOrder}/$id";

    final json = await _api.get(url);
    final List<dynamic> list = json['orders'] ?? [];

    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

