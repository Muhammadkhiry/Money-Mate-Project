import 'package:flutter/material.dart';

class RadioListGroup<T> extends StatelessWidget {
  final List<String> titles;
  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;

  const RadioListGroup({
    super.key,
    required this.titles,
    required this.values,
    required this.selected,
    required this.onChanged,
  }) : assert(titles.length == values.length);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(titles.length, (index) {
        return Expanded(
          child: RadioListTile<T>(
            title: Text(titles[index]),
            value: values[index],
            groupValue: selected,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        );
      }),
    );
  }
}
