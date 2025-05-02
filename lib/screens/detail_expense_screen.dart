import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class DetailExpense extends StatefulWidget {
  final Expense expense;

  const DetailExpense({super.key, required this.expense});

  @override
  State<DetailExpense> createState() => _DetailExpenseState();
}

class _DetailExpenseState extends State<DetailExpense> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Expense Detail',
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
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.expense.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormat.convertToIdr(widget.expense.amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Expected Date',
                              DateFormat('dd MMMM yyyy')
                                  .format(widget.expense.date),
                              Icons.calendar_today,
                            ),
                            const Divider(height: 1),
                            _buildDetailRow(
                              'Status',
                              widget.expense.isEarned ? 'Paid' : 'Not Earned',
                              Icons.check_circle,
                              valueColor: widget.expense.isEarned
                                  ? AppColors.greenColor
                                  : AppColors.redColor,
                              showBadge: true,
                            ),
                            const Divider(height: 1),
                            _buildDetailRow(
                              'Payment Method',
                              widget.expense.paymentMethod,
                              Icons.payment,
                            ),
                            const Divider(height: 1),
                            _buildDetailRow(
                              'Recurring',
                              widget.expense.isRequring ? 'Yes' : 'No',
                              Icons.repeat,
                            ),
                            if (widget.expense.isRequring) ...[
                              const Divider(height: 1),
                              _buildDetailRow(
                                'Frequency',
                                widget.expense.frequency,
                                Icons.access_time,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildActionButtons(expenseProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool showBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (showBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (valueColor ?? Colors.black87).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ExpenseProvider expenseProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
                _isLoading ? null : () => _expenseEarned(widget.expense.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                    'MARK AS PAID',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/form_update_expense",
                      arguments: widget.expense,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'UPDATE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _expenseEarned(String expenseId) async {
    if (expenseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid expense ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      var expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      var profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      var expectedExpenseProvider =
          Provider.of<ExpectedExpenseProvider>(context, listen: false);
      debugPrint("id expense $expenseId");

      await expenseProvider.earned(context, expenseId);

      if (!mounted) return;

      if (expenseProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(expenseProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense Earned Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
      await profileProvider.fetchProfile();
      await expectedExpenseProvider.fetchExpectedExpense();
      await expenseProvider.fetchExpenses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Hapus"),
              onPressed: () {
                _deleteExpense(widget.expense.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(String id) async {
    var expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    var expectedExpenseProvider =
        Provider.of<ExpectedExpenseProvider>(context, listen: false);
    await expenseProvider.deleteExpense(id).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      await expenseProvider.fetchExpenses();
      await expectedExpenseProvider.fetchExpectedExpense();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}
