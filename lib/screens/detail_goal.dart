// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/models/goal.dart';
import 'package:money_app_new/providers/goal_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:provider/provider.dart';

class DetailGoal extends StatefulWidget {
  final Goal goal;
  const DetailGoal({super.key, required this.goal});

  @override
  State<DetailGoal> createState() => _DetailGoalState();
}

class _DetailGoalState extends State<DetailGoal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _name;
  String? _amount;
  DateTime? _expectedDate;
  final bool _isRecurring = false;
  final String _frequency = "Weekly";

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
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
                            widget.goal.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "DESCRIPTION",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.goal.description,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 141, 141, 141)),
                          ),
                          const SizedBox(height: 20),
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var goalProvider = Provider.of<GoalProvider>(context, listen: false);
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
                _deleteGoal(widget.goal.id);
                Navigator.of(context).pushReplacementNamed("/income_expanse");
                await goalProvider.fetchGoals();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGoal(String id) async {
    try {
      var goalProvider = Provider.of<GoalProvider>(context, listen: false);
      if (goalProvider == null) {
        print("GoalProvider tidak diinisialisasi");
        return;
      }

      await goalProvider.deleteGoal(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }

      try {
        await Navigator.of(context).pushReplacementNamed('/goal_tab');
      } catch (e) {
        print("Error navigasi: $e");
      }

      try {
        await goalProvider.fetchGoals();
      } catch (e) {
        print("Error memperbarui data: $e");
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
