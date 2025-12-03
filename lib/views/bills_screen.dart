import 'package:flutter/material.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/services/api_services.dart';

class BillsScreen extends StatefulWidget {
  final String? userType;
  final int? userId;

  const BillsScreen({super.key, required this.userType, required this.userId});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  BillsModel? model;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);

    final data = await ApiServices(
      api: DioConsumer(),
    ).billsView(widget.userType!, widget.userId!);

    setState(() {
      model = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: model?.bills?.length ?? 0,
            itemBuilder: (context, index) {
              final bill = model!.bills![index];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      bill.billId.toString(),
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                  // TITLE
                  title: Text(
                    widget.userType == "customer"
                        ? bill.companyName ?? "No company"
                        : bill.customerName ?? "No customer",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),

                  subtitle: Text(
                    bill.billStatus ?? "",
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  trailing: Text(
                    bill.billAmount!.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
  }
}
