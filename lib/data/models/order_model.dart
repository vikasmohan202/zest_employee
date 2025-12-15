// order_models.dart

class OrdersResponse {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<Order> orders;

  OrdersResponse({
    required this.success,
    required this.message,
    this.pagination,
    required this.orders,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalOrders;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalOrders,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: (json['currentPage'] ?? 1) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
      totalOrders: (json['totalOrders'] ?? 0) as int,
    );
  }
}

class Order {
  final String id;
  final UserDetail? user; // expanded user from `userId`
  final List<OrderItem> items;
  final double totalAmount;
  final double? finalAmount;
  final bool adminUpdated;
  final String orderStatus;
  final Address? deliveryAddress;
  final Address? pickupAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? isPaidAt;
  final List<PriceHistory> priceHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Employee? deliveryEmployee; // can be parsed from id or object
  final Employee? pickupEmployee; // can be parsed from id or object
  final String? deliveryTaskId;
  final String? pickupTaskId;
  final String?
  scheduledPickupDate; // kept as String (ISO) because JSON uses date string
  final String? scheduledPickupTimeSlot;

  Order({
    required this.id,
    this.user,
    required this.items,
    required this.totalAmount,
    this.finalAmount,
    required this.adminUpdated,
    required this.orderStatus,
    this.deliveryAddress,
    this.pickupAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.isPaidAt,
    required this.priceHistory,
    this.createdAt,
    this.updatedAt,
    this.deliveryEmployee,
    this.pickupEmployee,
    this.deliveryTaskId,
    this.pickupTaskId,
    this.scheduledPickupDate,
    this.scheduledPickupTimeSlot,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // parse employee fields that might be either a string id or full object
    Employee? parseMaybeEmployee(dynamic v) {
      if (v == null) return null;
      if (v is String) {
        return Employee(
          id: v,
          fullName: '',
          email: null,
          phoneNumber: null,
          profileImage: null,
          position: null,
          employeeStatus: null,
        );
      }
      if (v is Map<String, dynamic>) {
        return Employee.fromJson(v);
      }
      return null;
    }

    return Order(
      id: json['_id']?.toString() ?? '',
      user: json['userId'] != null && json['userId'] is Map<String, dynamic>
          ? UserDetail.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      finalAmount: json['finalAmount'] == null
          ? null
          : (json['finalAmount'] as num).toDouble(),
      adminUpdated: json['adminUpdated'] ?? false,
      orderStatus: json['orderStatus']?.toString() ?? '',
      deliveryAddress:
          json['deliveryAddress'] != null &&
              json['deliveryAddress'] is Map<String, dynamic>
          ? Address.fromJson(json['deliveryAddress'] as Map<String, dynamic>)
          : null,
      pickupAddress:
          json['pickupAddress'] != null &&
              json['pickupAddress'] is Map<String, dynamic>
          ? Address.fromJson(json['pickupAddress'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      isPaidAt: json['isPaidAt']?.toString(),
      priceHistory: (json['priceHistory'] as List<dynamic>? ?? [])
          .map((e) => PriceHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      deliveryEmployee: parseMaybeEmployee(json['deliveryEmployee']),
      pickupEmployee: parseMaybeEmployee(json['pickupEmployee']),
      deliveryTaskId: json['deliveryTaskId']?.toString(),
      pickupTaskId: json['pickupTaskId']?.toString(),
      scheduledPickupDate: json['scheduledPickupDate']?.toString(),
      scheduledPickupTimeSlot: json['scheduledPickupTimeSlot']?.toString(),
    );
  }
}

class UserDetail {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? userStatus;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? refreshToken;
  final String? accessToken;

  UserDetail({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.userStatus,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.refreshToken,
    this.accessToken,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['_id']?.toString() ?? '',
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      userStatus: json['userStatus']?.toString(),
      isEmailVerified: json['isEmailVerified'] is bool
          ? json['isEmailVerified'] as bool
          : null,
      isPhoneVerified: json['isPhoneVerified'] is bool
          ? json['isPhoneVerified'] as bool
          : null,
      isVerified: json['isVerified'] is bool
          ? json['isVerified'] as bool
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      refreshToken: json['refreshToken']?.toString(),
      accessToken: json['accessToken']?.toString(),
    );
  }
}

class OrderItem {
  final String id;
  final Category? category;
  final int quantity;
  final double pricePerPiece;
  final double totalPrice;

  OrderItem({
    required this.id,
    this.category,
    required this.quantity,
    required this.pricePerPiece,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['_id'] ?? '').toString(),
      category:
          json['categoryId'] != null &&
              json['categoryId'] is Map<String, dynamic>
          ? Category.fromJson(json['categoryId'] as Map<String, dynamic>)
          : null,
      quantity: (json['quantity'] ?? 0) as int,
      pricePerPiece: (json['pricePerPiece'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}

class Category {
  final String id;
  final String categoryName;
  final String? description;
  final String? profileImage;
  final double pricePerPiece;
  final String? estimatedDeliveryTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.categoryName,
    this.description,
    this.profileImage,
    required this.pricePerPiece,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['_id'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? '').toString(),
      description: json['description']?.toString(),
      profileImage: json['profileImage']?.toString(),
      pricePerPiece: (json['pricePerPiece'] ?? 0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

class PriceHistory {
  final double? previousAmount;
  final double updatedAmount;
  final DateTime? updatedAt;
  final String id;

  PriceHistory({
    this.previousAmount,
    required this.updatedAmount,
    this.updatedAt,
    required this.id,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      previousAmount: json['previousAmount'] == null
          ? null
          : (json['previousAmount'] as num).toDouble(),
      updatedAmount: (json['updatedAmount'] ?? 0).toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      id: (json['_id'] ?? '').toString(),
    );
  }
}

class Employee {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final String? position;
  final String? employeeStatus;

  Employee({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.position,
    this.employeeStatus,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      position: json['position']?.toString(),
      employeeStatus: json['employeeStatus']?.toString(),
    );
  }
}

/// Address and nested CurrentAddress (geo)
class Address {
  final CurrentAddress? currentAddress;
  final String id;
  final String? userId;
  final String? addressType;
  final String? zipCode;
  final String? houseNumber;
  final String? streetName;
  final String? area;
  final String? landmark;
  final String? city;
  final String? state;
  final bool? isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Address({
    this.currentAddress,
    required this.id,
    this.userId,
    this.addressType,
    this.zipCode,
    this.houseNumber,
    this.streetName,
    this.area,
    this.landmark,
    this.city,
    this.state,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      currentAddress:
          json['currentAddress'] != null &&
              json['currentAddress'] is Map<String, dynamic>
          ? CurrentAddress.fromJson(
              json['currentAddress'] as Map<String, dynamic>,
            )
          : null,
      id: (json['_id'] ?? '').toString(),
      userId: json['userId']?.toString(),
      addressType: json['addressType']?.toString(),
      zipCode: json['zipCode']?.toString(),
      houseNumber: json['houseNumber']?.toString(),
      streetName: json['streetName']?.toString(),
      area: json['area']?.toString(),
      landmark: json['landmark']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      isDefault: json['isDefault'] is bool ? json['isDefault'] as bool : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      v: json['__v'] is int ? json['__v'] as int : null,
    );
  }
}

class CurrentAddress {
  final String type;
  final List<double> coordinates;

  CurrentAddress({required this.type, required this.coordinates});

  factory CurrentAddress.fromJson(Map<String, dynamic> json) {
    final coords = (json['coordinates'] as List<dynamic>? ?? []).map((e) {
      // try to convert each coordinate to double
      if (e is num) return e.toDouble();
      if (e is String) return double.tryParse(e) ?? 0.0;
      return 0.0;
    }).toList();

    return CurrentAddress(
      type: json['type']?.toString() ?? '',
      coordinates: coords,
    );
  }
}
