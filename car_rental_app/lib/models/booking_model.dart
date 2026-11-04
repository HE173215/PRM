import 'car_model.dart';

class BookingModel {
  final String id;

  final CarModel car;

  final DateTime startDate;
  final DateTime endDate;

  final double pricePerDay;

  final int totalDays;

  final double totalAmount;

  final String status;

  final String paymentStatus;

  final String note;

  BookingModel({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.totalDays,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.note,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id']?.toString() ?? '',

      car: CarModel.fromJson(json['car'] as Map<String, dynamic>? ?? {}),

      startDate: DateTime.parse(json['startDate']).toLocal(),

      endDate: DateTime.parse(json['endDate']).toLocal(),

      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,

      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,

      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,

      status: json['status']?.toString() ?? '',

      paymentStatus: json['paymentStatus']?.toString() ?? '',

      note: json['note']?.toString() ?? '',
    );
  }
}
