import 'package:equatable/equatable.dart';
import 'package:zest_employee/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Loading state while fetching orders
class OrderLoadInProgress extends OrderState {
  const OrderLoadInProgress();
}

/// Loaded state with list of orders (you can include pagination metadata if desired)
class OrderLoadSuccess extends OrderState {
  final List<Order> orders;

  const OrderLoadSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// Specific single-order loaded (optional)
class OrderLoadOneSuccess extends OrderState {
  final Order order;

  const OrderLoadOneSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

/// Empty state (no orders)
class OrderEmpty extends OrderState {
  const OrderEmpty();
}

/// Failure state with message
class OrderLoadFailure extends OrderState {
  final String message;

  const OrderLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
