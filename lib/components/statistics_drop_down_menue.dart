import 'package:flutter/material.dart';

class StatisticsDropDownMenue extends StatelessWidget {
  final void Function(String?) onSelected;

  const StatisticsDropDownMenue({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: DropdownMenu<String>(
        width: 250,
        initialSelection: "This Month",
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 18,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(3),
          shadowColor: WidgetStateProperty.all(Color(0xff4CAF50)),
          surfaceTintColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        trailingIcon: Icon(Icons.keyboard_arrow_down, size: 30),

        dropdownMenuEntries: [
          DropdownMenuEntry(value: "Today", label: "Today"),
          DropdownMenuEntry(value: "This Week", label: "This Week"),
          DropdownMenuEntry(value: "This Month", label: "This Month"),
          DropdownMenuEntry(value: "This Year", label: "This Year"),
        ],

        onSelected: onSelected,
      ),
    );
  }
}
