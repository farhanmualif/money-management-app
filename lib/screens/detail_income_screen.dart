// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/expected_income_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class DetailIncome extends StatefulWidget {
  final Income income;
  const DetailIncome({super.key, required this.income});

  @override
  State<DetailIncome> createState() => _DetailIncomeState();
}

class _DetailIncomeState extends State<DetailIncome> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Income Detail',
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
      body: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, child) {
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
                        widget.income.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormat.convertToIdr(widget.income.amount),
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
                                  .format(widget.income.date),
                              Icons.calendar_today,
                            ),
                            const Divider(height: 1),
                            _buildDetailRow(
                              'Status',
                              widget.income.isEarned ? 'Earned' : 'Not Earned',
                              Icons.check_circle,
                              valueColor: widget.income.isEarned
                                  ? AppColors.greenColor
                                  : AppColors.redColor,
                              showBadge: true,
                            ),
                            const Divider(height: 1),
                            _buildDetailRow(
                              'Recurring',
                              widget.income.isRecurring ? 'Yes' : 'No',
                              Icons.repeat,
                            ),
                            if (widget.income.isRecurring) ...[
                              const Divider(height: 1),
                              _buildDetailRow(
                                'Frequency',
                                widget.income.frequency,
                                Icons.access_time,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildActionButtons(incomeProvider),
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

  Widget _buildActionButtons(IncomeProvider incomeProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
                _isLoading ? null : () => _incomeEarned(widget.income.id),
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
                    'MARK AS EARNED',
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
                      "/form_update_income",
                      arguments: widget.income,
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

  void _incomeEarned(String incomeId) async {
    setState(() => _isLoading = true);

    try {
      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      final expectedIncomeProvider =
          Provider.of<ExpectedIncomeProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      await incomeProvider.earned(context, incomeId);

      if (incomeProvider.error != null) {
        _showSnackBar(incomeProvider.error!, Colors.red);
        return;
      }

      await expectedIncomeProvider.fetchExpectedIncome();

      if (mounted) {
        _showSnackBar("Income Earned Successfully", Colors.green);
        Navigator.of(context).pop();
        await Future.wait([
          incomeProvider.fetchIncomes(),
          profileProvider.fetchProfile(),
        ]);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var incomeProvider =
            Provider.of<IncomeProvider>(context, listen: false);
        var profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        final expectedIncomeProvider =
            Provider.of<ExpectedIncomeProvider>(context, listen: false);
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
              onPressed: () async {
                _deleteIncome(widget.income.id);
                Navigator.of(context).pop();

                await expectedIncomeProvider.fetchExpectedIncome();
                await incomeProvider.fetchIncomes();
                await profileProvider.fetchProfile();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteIncome(String id) async {
    var incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    await incomeProvider.deleteIncome(id).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      await incomeProvider.fetchIncomes();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}
