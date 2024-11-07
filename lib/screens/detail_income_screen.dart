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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _name;
  String? _amount;
  DateTime? _expectedDate;
  final bool _isRecurring = false;
  final String _frequency = "Weekly";

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, child) {
          if (incomeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "NAME",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.income.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "AMMOUNT",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            CurrencyFormat.convertToIdr(widget.income.amount),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Expected date",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd').format(widget.income.date),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "REQURING",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.income.isRecurring
                                ? "Reccuring"
                                : "Not-Requring",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "FREQUENCY",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.income.frequency,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _incomeEarned(widget.income.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(300, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                ' EARNED',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _confirmDelete,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 174, 0, 32),
                                    minimumSize: const Size(300, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    'DELETE',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        "/form_update_income",
                                        arguments: widget.income);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 243, 135, 73),
                                    minimumSize: const Size(20, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    'UPDATE',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _incomeEarned(String incomeId) async {
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

      // Panggil fetchExpectedIncome setelah income berhasil ditandai
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

                // Panggil fetchExpectedIncome setelah penghapusan
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
