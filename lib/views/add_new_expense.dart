import 'package:flutter/material.dart';

class AddNewExpense extends StatefulWidget {
  const AddNewExpense({super.key});

  @override
  State<AddNewExpense> createState() => _AddNewExpenseState();
}

class _AddNewExpenseState extends State<AddNewExpense> {
  // Controllers
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  // Category
  String? selectedCategory;

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xff4CAF50)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Add New Expense',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff52595C),
                  ),
                ),
                const SizedBox(height: 40),

                // Amount
                buildInputField(
                  controller: amountController,
                  icon: Icons.account_balance_wallet,
                  hint: 'Amount',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                // Description
                buildInputField(
                  controller: descriptionController,
                  icon: Icons.edit,
                  hint: 'Description',
                ),

                const SizedBox(height: 30),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  hint: Text("Category"),
                  decoration: inputDecoration(Icons.category),
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: "Food", child: Text("Food")),
                    DropdownMenuItem(
                      value: "Transport",
                      child: Text("Transport"),
                    ),
                    DropdownMenuItem(value: "Bills", child: Text("Bills")),
                    DropdownMenuItem(
                      value: "Shopping",
                      child: Text("Shopping"),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    selectedCategory = value;
                  }),
                  validator: (value) =>
                      value == null ? "Please select a category" : null,
                ),

                const SizedBox(height: 30),

                // Date Picker
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: inputDecoration(
                    Icons.calendar_today,
                  ).copyWith(hintText: "Pick a date"),
                  validator: (value) =>
                      value!.isEmpty ? "Please select a date" : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );

                    if (picked != null) {
                      dateController.text =
                          "${picked.year}-${picked.month}-${picked.day}";
                    }
                  },
                ),

                const SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Save logic here later
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4CAF50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Save Expense",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: inputDecoration(icon).copyWith(hintText: hint),
      keyboardType: keyboardType,
      validator: (value) =>
          value!.isEmpty ? "This field cannot be empty" : null,
    );
  }

  // Common decoration
  InputDecoration inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 32, color: const Color(0xff6E6E6C)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 0.7,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.4),
          width: 0.9,
        ),
      ),
    );
  }
}
