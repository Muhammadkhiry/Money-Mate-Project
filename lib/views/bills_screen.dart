import 'package:flutter/material.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/services/api_services.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  
  BillsModel? model;
  bool isLoading = true;
  @override
  void initState() {
    ApiServices(api: DioConsumer(), id: 5).billsView().then((data) {
      setState(() {
        isLoading = false;
        model = data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: model?.bills?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),

                    // الرقم أو الـ ID
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        model!.bills![index].billId.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    // اسم الشركة
                    title: Text(
                      model!.bills![index].companyName ?? "No company",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // حالة الفاتورة
                    subtitle: Text(
                      model!.bills![index].billStatus ?? "",
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    // السعر
                    trailing: Text(
                      model!.bills![index].billAmount!.toStringAsFixed(3),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
