import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:money_app_new/themes/themes.dart';

class FormUpdateExpenseScreen extends StatefulWidget {
  final Expense expense;
  const FormUpdateExpenseScreen({super.key, required this.expense});

  @override
  State<FormUpdateExpenseScreen> createState() =>
      _FormUpdateExpenseScreenState();
}

class _FormUpdateExpenseScreenState extends State<FormUpdateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late bool _isRecurring;
  late String _frequency;

  // Definisikan list frekuensi yang valid
  final List<String> _validFrequencies = ["Daily", "Weekly", "Monthly"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense.name);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(widget.expense.date));
    _isRecurring = widget.expense.isRequring;

    // Pastikan _frequency selalu memiliki nilai yang valid
    _frequency = _validFrequencies.contains(widget.expense.frequency)
        ? widget.expense.frequency
        : _validFrequencies.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _confirmForm() async {
    if (_formKey.currentState!.validate()) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final expextedExpenseProvider =
          Provider.of<ExpectedExpenseProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final updatedExpense = Expense(
        id: widget.expense.id,
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        isRequring: _isRecurring,
        frequency: _frequency,
        isEarned: widget.expense.isEarned,
        accountId: widget.expense.accountId,
        paymentMethod: widget.expense.paymentMethod,
        date: DateFormat('yyyy/MM/dd').parse(_dateController.text),
        createdAt: widget.expense.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        await expenseProvider.updateExpense(updatedExpense);
        await expextedExpenseProvider.fetchExpectedExpense();
        await profileProvider.fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data updated successfully'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pushReplacementNamed("/income_expanse");
        }
        await expenseProvider.fetchExpenses();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildFormContent(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color.fromARGB(255, 68, 74, 176), Color(0xFF1F2462)],
          ),
        ),
      ),
      title:
          const Text("Update Expense", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color.fromARGB(255, 68, 74, 176), Color(0xFF1F2462)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
      ),
    );
  }

  Widget _buildFormContent() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: expenseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildForm(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFormField("NAME", _nameController, "eg: Rent"),
          const SizedBox(height: 20),
          _buildTextFormField(
              "AMOUNT", _amountController, "eg: 1000", TextInputType.number),
          const SizedBox(height: 20),
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildRecurringRadioButtons(),
          _buildFrequencyDropdown(),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
      String label, TextEditingController controller, String hint,
      [TextInputType? keyboardType]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) =>
              value?.isEmpty ?? true ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Expected Date", style: TextStyle(fontSize: 15)),
        TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(
            hintText: "eg: 2023/02/10",
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateFormat('yyyy/MM/dd').parse(_dateController.text),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() => _dateController.text =
                  DateFormat('yyyy/MM/dd').format(picked));
            }
          },
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a date' : null,
        ),
      ],
    );
  }

  Widget _buildRecurringRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recurring", style: TextStyle(fontSize: 15)),
        Column(
          children: [
            RadioListTile<bool>(
              title: const Text('Non-Recurring'),
              value: false,
              groupValue: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value!),
            ),
            RadioListTile<bool>(
              title: const Text('Recurring'),
              value: true,
              groupValue: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Frequency", style: TextStyle(fontSize: 15)),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: _frequency,
          items: _validFrequencies.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? value) {
            if (value != null) setState(() => _frequency = value);
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return ElevatedButton(
          onPressed: expenseProvider.isLoading ? null : _confirmForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: const Text('CONFIRM', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
