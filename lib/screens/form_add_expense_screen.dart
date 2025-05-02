// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class FormAddExpenseScreen extends StatefulWidget {
  const FormAddExpenseScreen({super.key});

  @override
  State<FormAddExpenseScreen> createState() => _FormAddExpenseScreenState();
}

class _FormAddExpenseScreenState extends State<FormAddExpenseScreen> {
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

  bool _isLoading = false;

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
      setState(() => _isLoading = true);

      try {
        var expenseProvider =
            Provider.of<ExpenseProvider>(context, listen: false);
        var expectedExpense =
            Provider.of<ExpectedExpenseProvider>(context, listen: false);

        Expense expenseResource = Expense(
          id: "",
          name: _nameController.text,
          amount: int.parse(_amountController.text),
          isRequring: _isRecurring,
          isEarned: false,
          frequency: _frequency,
          accountId: "",
          paymentMethod: _paymentMethodController.text,
          date: _expectedDate ?? DateTime.now(),
          createdAt: _expectedDate ?? DateTime.now(),
          updatedAt: _expectedDate ?? DateTime.now(),
        );

        await expenseProvider.addExpense(expenseResource);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          Navigator.of(context).pop();
          await expectedExpense.fetchExpectedExpense();
          await expenseProvider.fetchExpenses();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.accentColor],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: "Expense Name",
                  controller: _nameController,
                  icon: Icons.shopping_bag_outlined,
                  hint: "e.g. Groceries",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expense name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: "Amount",
                  controller: _amountController,
                  icon: Icons.attach_money,
                  hint: "e.g. 500000",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDatePicker(),
                const SizedBox(height: 20),
                _buildInputField(
                  label: "Payment Method",
                  controller: _paymentMethodController,
                  icon: Icons.payment,
                  hint: "e.g. Cash, Credit Card",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment method';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildRecurringSection(),
                const SizedBox(height: 20),
                if (_isRecurring) _buildFrequencyDropdown(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryColor),
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textColor.withOpacity(0.5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(color: AppColors.accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date",
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _expectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primaryColor,
                        onPrimary: Colors.white,
                        surface: AppColors.surfaceColor,
                        onSurface: AppColors.textColor,
                        error: AppColors.accentColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _expectedDate = picked;
                  _dateController.text =
                      DateFormat('dd/MM/yyyy').format(picked);
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today,
                  color: AppColors.primaryColor),
              hintText: "Select date",
              hintStyle: TextStyle(
                color: AppColors.textColor.withOpacity(0.5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recurring Expense",
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: _isRecurring,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) => setState(() => _isRecurring = value!),
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: _isRecurring,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) => setState(() => _isRecurring = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frequency",
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _frequency,
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.repeat, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
              contentPadding: const EdgeInsets.all(16),
            ),
            items: ["Weekly", "Monthly", "Daily"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _frequency = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: AppColors.textColor,
              padding: const EdgeInsets.all(16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'CLEAR',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirmForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
