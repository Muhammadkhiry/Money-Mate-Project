class BillResponse {
  final String message;
  final int billId;

  BillResponse({
    required this.message,
    required this.billId,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    return BillResponse(
      message: json["message"],
      billId: json["bill_id"],
    );
  }
}
