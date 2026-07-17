class OrderResponse {
  final int id;
  final int userId;
  final String status;
  final double totalPrice;
  final String createdAt;
  final List<OrderItemResponse> items;

  const OrderResponse({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      status: json['status'] ?? '',
      totalPrice:
          (json['totalPrice'] is num) ? (json['totalPrice'] as num).toDouble() : 0.0,
      createdAt: json['createdAt'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'SHIPPED':
        return 'Shipped';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class OrderItemResponse {
  final int id;
  final String bookTitle;
  final int bookId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemResponse({
    required this.id,
    required this.bookTitle,
    required this.bookId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: json['id'] ?? 0,
      bookTitle: json['bookTitle'] ?? '',
      bookId: json['bookId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice:
          (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : 0.0,
      subtotal:
          (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : 0.0,
    );
  }
}

class CreateOrderRequest {
  final int userId;
  final List<OrderItemRequest> items;

  const CreateOrderRequest({required this.userId, required this.items});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemRequest {
  final int bookId;
  final int quantity;

  const OrderItemRequest({required this.bookId, required this.quantity});

  Map<String, dynamic> toJson() => {'bookId': bookId, 'quantity': quantity};
}
