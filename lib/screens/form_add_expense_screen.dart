// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class FormAddIExpenseScreen extends StatefulWidget {
  const FormAddIExpenseScreen({super.key});

  @override
  State<FormAddIExpenseScreen> createState() => _FormAddIExpenseScreenState();
}

class _FormAddIExpenseScreenState extends State<FormAddIExpenseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _paymentMethodController =
      TextEditingController();

  String? _name;
  String? _amount;
  DateTime? _expectedDate;
  bool _isRecurring = false;
  String _frequency = "Weekly";

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _amountController.clear();
      _dateController.clear();
      _paymentMethodController.clear();
      _name = null;
      _amount = null;
      _expectedDate = null;
      _isRecurring = false;
      _frequency = "Weekly";
    });
  }

  void _confirmForm() async {
    if (_formKey.currentState!.validate()) {
      var expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      var profileProfider =
          Provider.of<ProfileProvider>(context, listen: false);
      var expectedExpense =
          Provider.of<ExpectedExpenseProvider>(context, listen: false);
      Expense expenseResource = Expense(
        id: "",
        name: _nameController.text,
        isRequring: _isRecurring,
        frequency: _frequency,
        amount: int.parse(_amountController.text),
        paymentMethod: _paymentMethodController.text,
        accountId: "", // Anda perlu mengisi accountId yang sesuai
        date: _expectedDate ?? DateTime.now(),
        isEarned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await expenseProvider.addExpense(expenseResource);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          // Navigator.of(context, rootNavigator: true)
          //     .pushNamedAndRemoveUntil("/income_expanse", (route) => false);
          Navigator.of(context).pop();
          await expenseProvider.fetchExpenses();
          await expectedExpense.fetchExpectedExpense();
          await profileProfider.fetchProfile();
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
      body: SingleChildScrollView(
        child: Stack(
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
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            offset: const Offset(0, 5)),
                      ]),
                  padding: const EdgeInsets.all(15),
                  child: Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, child) {
                      if (expenseProvider.isLoading) {
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
                              decoration:
                                  const InputDecoration(hintText: "eg:Buy Car"),
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
                              decoration:
                                  const InputDecoration(hintText: "eg:5000"),
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
                              "EXPECTED DATE",
                              style: TextStyle(fontSize: 15),
                            ),
                            TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                  hintText: "eg:10/02/2023"),
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _expectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _expectedDate = picked;
                                    _dateController.text =
                                        DateFormat('dd/MM/yyyy').format(picked);
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
                            const Text(
                              "TYPE",
                              style: TextStyle(fontSize: 15),
                            ),
                            TextFormField(
                              controller: _paymentMethodController,
                              decoration: const InputDecoration(
                                  hintText: "eg:Transfer"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a type';
                                }
                                return null;
                              },
                              onSaved: (value) => _amount = value,
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
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Frequency",
                                hintText: "Weekly",
                              ),
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
                                        borderRadius: BorderRadius.circular(5),
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
                                        borderRadius: BorderRadius.circular(5),
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
      ),
    );
  }
}
