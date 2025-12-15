import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zest_employee/data/models/order_model.dart';
import 'package:zest_employee/data/repositories/orders/auth_repo.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderInitial()) {
    on<OrderFetched>(_onFetched);
    on<OrderRefreshed>(_onRefreshed);
    on<OrderRequested>(_onRequested);
  }

  Future<void> _onFetched(OrderFetched event, Emitter<OrderState> emit) async {
    // If already loading, ignore
    if (state is OrderLoadInProgress) return;

    emit(const OrderLoadInProgress());

    try {
      // currently repository.getAllOrders() doesn't support pagination; pass-through if it does
      final List<Order> orders = await _orderRepository.getAllOrders(event.id);

      if (orders.isEmpty) {
        emit(const OrderEmpty());
      } else {
        emit(OrderLoadSuccess(orders));
      }
    } catch (e, st) {
      // Optional: log
      // print('OrderBloc._onFetched error: $e\n$st');
      emit(OrderLoadFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(OrderRefreshed event, Emitter<OrderState> emit) async {
    emit(const OrderLoadInProgress());
    try {
      final List<Order> orders = await _orderRepository.getAllOrders(event.id);
      if (orders.isEmpty) {
        emit(const OrderEmpty());
      } else {
        emit(OrderLoadSuccess(orders));
      }
    } catch (e) {
      emit(OrderLoadFailure(e.toString()));
    }
  }

  Future<void> _onRequested(OrderRequested event, Emitter<OrderState> emit) async {
    emit(const OrderLoadInProgress());
    // try {
    //   final Order? order = await _orderRepository.getOrderById(event.id);
    //   if (order == null) {
    //     emit(const OrderLoadFailure('Order not found'));
    //   } else {
    //     emit(OrderLoadOneSuccess(order));
    //   }
    // } catch (e) {
    //   emit(OrderLoadFailure(e.toString()));
    // }
  }
}
