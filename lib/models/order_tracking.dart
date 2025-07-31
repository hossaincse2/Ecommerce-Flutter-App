class OrderTracking {
  final int id;
  final String status;
  final String date;
  final String time;
  final String note;

  OrderTracking({
    required this.id,
    required this.status,
    required this.date,
    required this.time,
    required this.note,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date,
      'time': time,
      'note': note,
    };
  }

  String get displayTime => '$date $time';
}