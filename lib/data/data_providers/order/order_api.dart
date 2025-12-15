import 'package:zest_employee/data/models/order_model.dart';

abstract class OrderApi {
  Future<List<Order>> getAllOrders(String id);
}
