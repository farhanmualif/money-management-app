import 'package:flutter/material.dart';
import 'package:money_app_new/screens/currency_converter_screen.dart';
import 'package:money_app_new/screens/pages/income_expense_page.dart';
import 'package:money_app_new/themes/themes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color.fromARGB(255, 55, 60, 160),
                      Color(0xFF1F2462),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomRight: Radius.zero,
                      bottomLeft: Radius.circular(20))),
              child: SafeArea(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                    ),
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 60,
                          ),
                          Text(
                            "ACCOUNTS",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Container(
                        height: 400,
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.of(context)
                              //         .pushNamed("/coming_soon");
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: AppColors.primary,
                              //     minimumSize: const Size(double.infinity, 50),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //   ),
                              //   child: const Text(
                              //     '+ ADD',
                              //     style: TextStyle(color: Colors.white),
                              //   ),
                              // ),
                              // const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const IncomeExpensePage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'VIEW ACCOUNTS',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CurrencyConverterScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '⟪ ⟫ CURRENCY CONVERSION',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
