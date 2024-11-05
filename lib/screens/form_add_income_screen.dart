// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/expected_income_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class FormAddIncomeScreen extends StatefulWidget {
  const FormAddIncomeScreen({super.key});

  @override
  State<FormAddIncomeScreen> createState() => _FormAddIncomeScreenState();
}

class _FormAddIncomeScreenState extends State<FormAddIncomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _name;
  String? _amount;
  DateTime? _expectedDate;
  bool _isRecurring = false;
  String _frequency = "Weekly";
  late IncomeProvider _incomeProvider;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _amountController.clear();
      _dateController.clear();
      _name = null;
      _amount = null;
      _expectedDate = null;
      _isRecurring = false;
      _frequency = "Weekly";
    });
  }

  void _confirmForm() async {
    if (_formKey.currentState!.validate()) {
      var incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
      var expectedIncome =
          Provider.of<ExpectedIncomeProvider>(context, listen: false);
      Income incomeResource = Income(
        id: "",
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        isRecurring: _isRecurring,
        isEarned: false,
        frequency: _frequency,
        accountId: "", // Anda perlu mengisi accountId yang sesuai
        date: _expectedDate ?? DateTime.now(),
      );
      try {
        await incomeProvider.addIncome(incomeResource);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          Navigator.of(context).pop();
          await expectedIncome.fetchExpectedIncome();
          await incomeProvider.fetchIncomes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _incomeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: 400, // Atur tinggi container sesuai kebutuhan
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color.fromARGB(255, 68, 74, 176),
                          Color(0xFF1F2462),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(20))),
                  child: SafeArea(
                    child: AppBar(
                      iconTheme: const IconThemeData(color: Colors.white),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context)
                      .size
                      .height, // Tambahkan height properti
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                offset: const Offset(0, 5)),
                          ]),
                      padding: const EdgeInsets.all(15),
                      child: Consumer<IncomeProvider>(
                        builder: (context, incomeProvider, child) {
                          if (incomeProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            );
                          }
                          return Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "NAME",
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                      hintText: "eg:Salary"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _name = value,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "AMOUNT",
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextFormField(
                                  controller: _amountController,
                                  decoration: const InputDecoration(
                                      hintText: "eg:5000"),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an amount';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _amount = value,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Expected Date",
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextFormField(
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                      hintText: "eg:10/02/2023"),
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _expectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _expectedDate = picked;
                                        _dateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(picked);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a date';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                RadioListTile<bool>(
                                  title: const Text('Non-Recurring'),
                                  value: false,
                                  groupValue: _isRecurring,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecurring = value!;
                                    });
                                  },
                                ),
                                RadioListTile<bool>(
                                  title: const Text('Recurring'),
                                  value: true,
                                  groupValue: _isRecurring,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecurring = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  "Frequency",
                                  style: TextStyle(fontSize: 15),
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    hintText: "Weekly",
                                    hintStyle: TextStyle(color: Colors.black),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  dropdownColor: Colors.white,
                                  value: _frequency,
                                  items: ["Weekly", "Monthly", "Daily"]
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        _frequency = value;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _clearForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          'CLEAR',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _confirmForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          minimumSize:
                                              const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          'CONFIRM',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
