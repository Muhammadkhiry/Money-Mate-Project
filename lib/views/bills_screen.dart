import 'package:flutter/material.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/services/api_services.dart';

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
    final success = await ApiServices(
      api: DioConsumer(),
    ).payBill(bill.billId!, UserModel.currentUser!.token);

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
        : DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // SEARCH
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

                // TABS (Paid / Unpaid)
                TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: "Paid"),
                    Tab(text: "Unpaid"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      // -------------------------
                      // PAID LIST
                      // -------------------------
                      _buildBillsList(
                        displayedBills
                            .where((b) => b.billStatus == "paid")
                            .toList(),
                      ),

                      // -------------------------
                      // UNPAID LIST
                      // -------------------------
                      _buildBillsList(
                        displayedBills
                            .where((b) => b.billStatus != "paid")
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildBillsList(List<Bill> bills) {
    if (bills.isEmpty) {
      return Center(
        child: Text(
          "No bills here",
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return GestureDetector(
          onTap: () => _showBillPopup(bill),
          child: Container(
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
              leading: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bill.billStatus == "paid"
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bill.billStatus ?? "",
                  style: TextStyle(
                    color: bill.billStatus == "paid"
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                UserModel.currentUser!.userType == "customer"
                    ? (bill.companyName ?? "Unknown")
                    : (bill.customerName ?? "Unknown"),
              ),
              subtitle: Text("${bill.billAmount} EGP"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bill.billStatus == "paid"
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bill.createdAt!.substring(0, 10),
                  // bill.billStatus ?? "",
                  // style: TextStyle(
                  //   color: bill.billStatus == "paid"
                  //       ? Colors.green
                  //       : Colors.red,
                  //   fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
