class BillsModel {
  List<Bill>? bills;

  BillsModel({this.bills});

  factory BillsModel.fromJson(Map<String, dynamic> json) => BillsModel(
    bills: (json['bills'] as List<dynamic>?)
        ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class Bill {
  int? billId;
  double? billAmount;
  String? billStatus;
  DateTime? createdAt;
  String? companyName;
  String? customerName;

  Bill({
    this.billId,
    this.billAmount,
    this.billStatus,
    this.createdAt,
    this.companyName,
    this.customerName,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    billId: json['bill_id'] as int?,
    billAmount: (json['bill_amount'] as num?)?.toDouble(),
    billStatus: json['bill_status'] as String?,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    companyName: json['company_name'] as String?,
    customerName: json['customer_name'] as String?,
  );
}
