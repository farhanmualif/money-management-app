import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/themes/themes.dart';

class FormUpdateIncomeScreen extends StatefulWidget {
  final Income income;
  const FormUpdateIncomeScreen({super.key, required this.income});

  @override
  State<FormUpdateIncomeScreen> createState() => _FormUpdateIncomeScreenState();
}

class _FormUpdateIncomeScreenState extends State<FormUpdateIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late bool _isRecurring;
  late String _frequency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.income.name);
    _amountController =
        TextEditingController(text: widget.income.amount.toString());
    _dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(widget.income.date));
    _isRecurring = widget.income.isRecurring;
    _frequency = widget.income.frequency;
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
      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      final updatedIncome = Income(
        id: widget.income.id,
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        isRecurring: _isRecurring,
        isEarned: widget.income.isEarned,
        frequency: _frequency,
        accountId: widget.income.accountId,
        date: DateFormat('yyyy/MM/dd').parse(_dateController.text),
      );

      try {
        await incomeProvider.update(updatedIncome);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data updated successfully'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pushReplacementNamed("/income_expanse");
        await incomeProvider.fetchIncomes();
        }
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
      title: const Text("Update Income", style: TextStyle(color: Colors.white)),
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
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, child) {
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
                child: incomeProvider.isUpdating
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
          _buildTextFormField("NAME", _nameController, "eg: Salary"),
          const SizedBox(height: 20),
          _buildTextFormField(
              "AMOUNT", _amountController, "eg: 5000", TextInputType.number),
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
          decoration: InputDecoration(hintText: hint),
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
          decoration: const InputDecoration(hintText: "eg: 10/02/2023"),
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
    );
  }

  Widget _buildFrequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Frequency", style: TextStyle(fontSize: 15)),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            hintText: "Weekly",
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: _frequency,
          items: ["Weekly", "Monthly", "Daily"].map((String value) {
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
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, child) {
        return ElevatedButton(
          onPressed: incomeProvider.isUpdating ? null : _confirmForm,
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
