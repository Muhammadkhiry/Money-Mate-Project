import 'package:flutter/material.dart';
import 'package:money_mate/core/api/dio_consumer.dart';
import 'package:money_mate/services/api_services.dart';
import 'package:money_mate/views/login_screen.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final emailController = TextEditingController();
  final amountController = TextEditingController();
  final billService = ApiServices(api: DioConsumer());

  bool loading = false;

  Future<void> submit() async {
  final amount = double.tryParse(amountController.text);
  if (amount == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid amount")),
    );
    return;
  }

  setState(() => loading = true);

  final result = await billService.createBill(
    customerEmail: emailController.text,
    billAmount: int.parse(amountController.text),
    token: LoginScreen.userModel!.token,
  );

  setState(() => loading = false);

  if (result?.message != null && result?.billId != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Done! Bill ID = ${result?.billId}")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to create bill")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Bill")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Customer Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Bill Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submit,
                    child: const Text("Create Bill"),
                  ),
          ],
        ),
      ),
    );
  }
}
