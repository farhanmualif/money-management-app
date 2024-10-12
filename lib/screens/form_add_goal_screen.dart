import 'package:flutter/material.dart';
import 'package:money_app_new/providers/goal_provider.dart';
import 'package:money_app_new/themes/themes.dart';

import 'package:provider/provider.dart';

class FormAddGoalScreen extends StatefulWidget {
  const FormAddGoalScreen({super.key});

  @override
  State<FormAddGoalScreen> createState() => _FormAddGoalScreenState();
}

class _FormAddGoalScreenState extends State<FormAddGoalScreen> {
  final _globalKey = GlobalKey<FormState>();
  final _nameGoalController = TextEditingController();
  final _descriptionGoalController = TextEditingController();

  @override
  void dispose() {
    _nameGoalController.dispose();
    _descriptionGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: 500,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _globalKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Goal Name"),
                        TextFormField(
                          controller: _nameGoalController,
                          decoration: const InputDecoration(
                              hintText: "Enter Goal Name"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter goal name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text("Description"),
                        TextFormField(
                          controller: _descriptionGoalController,
                          decoration: const InputDecoration(
                              hintText: "Enter Description"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Expanded(child: Container()),
                            Expanded(child: Container()),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_globalKey.currentState!.validate()) {
                                    try {
                                      await Provider.of<GoalProvider>(context,
                                              listen: false)
                                          .addGoal(_nameGoalController.text,
                                              _descriptionGoalController.text);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Add Goal Successfully"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'CONFIRM',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
