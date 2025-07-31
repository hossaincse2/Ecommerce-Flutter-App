import 'order.dart';

class OrdersResponse {
  final List<Order> data;
  final OrdersMeta meta;

  OrdersResponse({
    required this.data,
    required this.meta,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((order) => Order.fromJson(order))
          .toList(),
      meta: OrdersMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class OrdersMeta {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;

  OrdersMeta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory OrdersMeta.fromJson(Map<String, dynamic> json) {
    return OrdersMeta(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }
}