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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (expenseProvider.isLoading) {
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
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20))),
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
                      height: MediaQuery.of(context).size.height,
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
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  widget.expense.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "AMOUNT",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  CurrencyFormat.convertToIdr(
                                      widget.expense.amount),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "EXPECTED DATE",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(widget.expense.date),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "REQURING",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  widget.expense.isRequring
                                      ? "Recurring"
                                      : "Not Recurring",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "FREQUENCY",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  widget.expense.frequency,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Color.fromARGB(255, 141, 141, 141)),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _expenseEarned(widget.expense.id);
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
                                          backgroundColor: const Color.fromARGB(
                                              255, 174, 0, 32),
                                          minimumSize: const Size(300, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                              "/form_update_expense",
                                              arguments: widget.expense);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 243, 135, 73),
                                          minimumSize: const Size(20, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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

  void _expenseEarned(String expenseId) async {
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
        const SnackBar(
          content: Text("Terjadi Kesalahan"),
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
