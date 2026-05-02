/// Represents stored payment information (credit card, wallet, etc.)
class PaymentInfo {
  final String id;
  final String type; // e.g. "card", "upi", "bank"
  final String details; // masked number or descriptor
  final bool isDefault;

  PaymentInfo({
    required this.id,
    required this.type,
    required this.details,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'details': details, 'isDefault': isDefault};
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] as String,
      type: json['type'] as String,
      details: json['details'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
