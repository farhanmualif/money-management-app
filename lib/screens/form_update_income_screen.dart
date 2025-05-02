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
  bool _isLoading = false;

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
      setState(() => _isLoading = true);

      try {
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

        await incomeProvider.update(updatedIncome);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data updated successfully'),
              backgroundColor: Colors.green,
            ),
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
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Update Income',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Text(
                'Update your income details',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      'Name',
                      _nameController,
                      'Enter income name',
                      Icons.description,
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      'Amount',
                      _amountController,
                      'Enter amount',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    _buildRecurringSection(),
                    const SizedBox(height: 32),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.textColor.withOpacity(0.7),
            fontSize: 13,
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryColor),
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'This field is required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPECTED DATE',
          style: TextStyle(
            color: AppColors.textColor.withOpacity(0.7),
            fontSize: 13,
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
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today,
                  color: AppColors.primaryColor),
              hintText: 'Select date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate:
                    DateFormat('yyyy/MM/dd').parse(_dateController.text),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() => _dateController.text =
                    DateFormat('yyyy/MM/dd').format(picked));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECURRING',
          style: TextStyle(
            color: AppColors.textColor.withOpacity(0.7),
            fontSize: 13,
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
          child: Column(
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
              if (_isRecurring) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: _frequency,
                    items: ["Weekly", "Monthly", "Daily"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) setState(() => _frequency = value);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'UPDATE INCOME',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
      ),
    );
  }
}
