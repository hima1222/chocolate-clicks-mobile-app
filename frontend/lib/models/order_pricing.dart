class OrderPricing {
  const OrderPricing({
    required this.subtotal,
    required this.deliveryFee,
    this.serviceCharge = 0,
    this.taxAmount = 0,
    this.taxRate = 0,
    required this.totalAmount,
  });
  final double subtotal,
      deliveryFee,
      serviceCharge,
      taxAmount,
      taxRate,
      totalAmount;
  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    double value(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return OrderPricing(
      subtotal: value('subtotal'),
      deliveryFee: value('deliveryFee'),
      serviceCharge: value('serviceCharge'),
      taxAmount: value('taxAmount'),
      taxRate: value('taxRate'),
      totalAmount: value('totalAmount'),
    );
  }
  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'serviceCharge': serviceCharge,
    'taxAmount': taxAmount,
    'taxRate': taxRate,
    'totalAmount': totalAmount,
  };
}
