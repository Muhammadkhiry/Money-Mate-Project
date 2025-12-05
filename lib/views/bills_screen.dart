
import 'package:flutter/material.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/services/api_services.dart';
import 'package:money_mate/views/login_screen.dart';

class BillsScreen extends StatefulWidget {
  final String? userType, token;

  const BillsScreen({super.key, required this.userType, required this.token});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  BillsModel? model;
  List<Bill> displayedBills = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);

    final data = await ApiServices(
      api: DioConsumer(),
    ).billsView(widget.userType!, widget.token!);

    setState(() {
      model = data;
      displayedBills = data!.bills ?? [];
      isLoading = false;
    });
  }

  // -------------------------
  // SEARCH FILTER
  // -------------------------
  void _filterBills(String text) {
    if (text.isEmpty) {
      displayedBills = model!.bills!;
    } else {
      displayedBills = model!.bills!.where((bill) {
        final name = widget.userType == "customer"
            ? bill.companyName ?? ""
            : bill.customerName ?? "";

        return name.toLowerCase().contains(text.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  // -------------------------
  // POPUP DETAILS
  // -------------------------
  void _showBillPopup(Bill bill) {
    showDialog(
      context: context,
      builder: (context) {
        bool isPaid = bill.billStatus == "paid";

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Bill #${bill.billId}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Amount: ${bill.billAmount}"),
              Text("Status: ${bill.billStatus}"),
              Text("Date: ${bill.createdAt ?? "N/A"}"),
              SizedBox(height: 10),
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {
                    _changeBillStatus(bill);
                    Navigator.pop(context);
                  },
                  child: Text("Mark as PAID"),
                )
              else
                Text(
                  "Already Paid ✔️",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------
  // CHANGE STATUS FUNCTION
  // -------------------------
  Future<void> _changeBillStatus(Bill bill) async {
    // Call API
    final success = await ApiServices(api: DioConsumer()).payBill(bill.billId!,LoginScreen.userModel!.token);

    if (success) {
      setState(() {
        bill.billStatus = "paid";
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bill marked as PAID ✔️")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update bill ❌")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // -------------------------
              // SEARCH BAR
              // -------------------------
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterBills,
                  decoration: InputDecoration(
                    hintText: "Search bills...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: displayedBills.length,
                  itemBuilder: (context, index) {
                    final bill = displayedBills[index];

                    return GestureDetector(
                      onTap: () => _showBillPopup(bill),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
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
                          title: Text(
                            widget.userType == "customer"
                                ? bill.companyName ?? "No company"
                                : bill.customerName ?? "No customer",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
