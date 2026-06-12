class TransactionEntity {
  final String transactionRef;
  final String vehicleLicense;
  final String vehicleType;
  final String price;
  final String priceName;
  final String priceType;
  final String? issuingState;
  final String? enumeratingState;
  final String? enumeratingLga;
  final String payerFirstName;
  final String payerLastName;
  final String payerPhone;
  final String payerEmail;
  final String transactionType;
  final String paymentMethod;
  final String? paymentRef;
  final double baseFee;
  final double adminFee;
  final double transactionFee;
  final double vat;
  final double totalAmount;
  final String status;
  final String serviceNumber;
  final String channelNumber;
  final String agentNumber;
  final String terminalId;
  final String? createdAt;

  const TransactionEntity({
    required this.transactionRef,
    required this.vehicleLicense,
    required this.vehicleType,
    required this.price,
    required this.priceName,
    required this.priceType,
    this.issuingState,
    this.enumeratingState,
    this.enumeratingLga,
    required this.payerFirstName,
    required this.payerLastName,
    required this.payerPhone,
    required this.payerEmail,
    required this.transactionType,
    required this.paymentMethod,
    this.paymentRef,
    required this.baseFee,
    required this.adminFee,
    required this.transactionFee,
    required this.vat,
    required this.totalAmount,
    this.status = 'pending',
    required this.serviceNumber,
    required this.channelNumber,
    required this.agentNumber,
    required this.terminalId,
    this.createdAt,
  });

  TransactionEntity copyWith({
    String? transactionRef,
    String? vehicleLicense,
    String? vehicleType,
    String? price,
    String? priceName,
    String? priceType,
    String? issuingState,
    String? enumeratingState,
    String? enumeratingLga,
    String? payerFirstName,
    String? payerLastName,
    String? payerPhone,
    String? payerEmail,
    String? transactionType,
    String? paymentMethod,
    String? paymentRef,
    double? baseFee,
    double? adminFee,
    double? transactionFee,
    double? vat,
    double? totalAmount,
    String? status,
    String? serviceNumber,
    String? channelNumber,
    String? agentNumber,
    String? terminalId,
    String? createdAt,
  }) {
    return TransactionEntity(
      transactionRef: transactionRef ?? this.transactionRef,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      priceName: priceName ?? this.priceName,
      priceType: priceType ?? this.priceType,
      issuingState: issuingState ?? this.issuingState,
      enumeratingState: enumeratingState ?? this.enumeratingState,
      enumeratingLga: enumeratingLga ?? this.enumeratingLga,
      payerFirstName: payerFirstName ?? this.payerFirstName,
      payerLastName: payerLastName ?? this.payerLastName,
      payerPhone: payerPhone ?? this.payerPhone,
      payerEmail: payerEmail ?? this.payerEmail,
      transactionType: transactionType ?? this.transactionType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentRef: paymentRef ?? this.paymentRef,
      baseFee: baseFee ?? this.baseFee,
      adminFee: adminFee ?? this.adminFee,
      transactionFee: transactionFee ?? this.transactionFee,
      vat: vat ?? this.vat,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      serviceNumber: serviceNumber ?? this.serviceNumber,
      channelNumber: channelNumber ?? this.channelNumber,
      agentNumber: agentNumber ?? this.agentNumber,
      terminalId: terminalId ?? this.terminalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionEntity(ref: $transactionRef, license: $vehicleLicense, '
        'amount: $totalAmount, status: $status)';
  }
}
