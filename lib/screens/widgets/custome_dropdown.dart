import 'package:flutter/material.dart';
import 'package:money_app_new/themes/themes.dart';

// ignore: must_be_immutable
class CustomDropdown extends StatefulWidget {
  String type;
  CustomDropdown({super.key, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select Item',
          hintStyle: TextStyle(color: AppColors.primary),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
        isExpanded: true,
        value: selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue;
          });
        },
        items: <String>[
          'Current ${widget.type}',
          'Earned ${widget.type}',
          'Expected ${widget.type}',
          'All ${widget.type}'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
