import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}
class OrderStatusUpdated extends OrderEvent {
  final String orderId;
  final String status;
  final String employeeId;

  const OrderStatusUpdated({
    required this.orderId,
    required this.status,
    required this.employeeId,
  });

  @override
  List<Object?> get props => [orderId, status, employeeId];
}

/// Load first page (or all) of orders
class OrderFetched extends OrderEvent {
  /// optional page/limit for pagination
  final int page;
  final int limit;
  final bool forceRefresh;
  final  String id;

  const OrderFetched({required this.id,this.page = 1, this.limit = 50, this.forceRefresh = false});

  @override
  List<Object?> get props => [page, limit, forceRefresh];
}

/// Refresh orders (pull-to-refresh)
class OrderRefreshed extends OrderEvent {
  String id;
   OrderRefreshed(this.id);

  @override
  List<Object?> get props => [id];
}

/// Fetch single order by id (optional)
class OrderRequested extends OrderEvent {
  final String id;

  const OrderRequested(this.id);

  @override
  List<Object?> get props => [id];
}
