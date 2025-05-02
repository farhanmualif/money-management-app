import 'package:flutter/material.dart';
import 'package:money_app_new/providers/auth_provider.dart';
import 'package:money_app_new/providers/balance_history_provider.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expected_income_provider.dart';
import 'package:money_app_new/providers/goal_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/providers/transaction_provider.dart';
import 'package:money_app_new/providers/upcoming_expense_provider.dart';
// import 'package:money_app_new/screens/cooming_soon_screen.dart';
import 'package:money_app_new/screens/pages/account_page.dart';
import 'package:money_app_new/screens/pages/analytics_page.dart';
import 'package:money_app_new/screens/pages/home_page.dart';
import 'package:money_app_new/screens/pages/middle_page.dart';
import 'package:money_app_new/screens/pages/profile_page.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AccountPage(),
    const MiddlePage(),
    const AnalyticsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/income_expanse');
                },
                icon: const Icon(Icons.swap_vert, color: Colors.white)),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home, index: 0, label: 'Home'),
              _buildNavItem(
                  icon: Icons.account_balance_wallet,
                  index: 1,
                  label: 'Account'),
              const SizedBox(width: 48),
              _buildNavItem(
                  icon: Icons.bar_chart, index: 3, label: 'Analytics'),
              _buildNavItem(icon: Icons.person, index: 4, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required int index, required String label}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    Provider.of<TransactionProvider>(context, listen: false)
        .fetchTransactions();
    Provider.of<BalanceHistoryProvider>(context, listen: false)
        .fetchBalanceHistory();
    Provider.of<ExpectedIncomeProvider>(context, listen: false)
        .fetchExpectedIncome();
    Provider.of<ExpectedExpenseProvider>(context, listen: false)
        .fetchExpectedExpense();
    Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    Provider.of<AuthProvider>(context, listen: false).authenticated();
    Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    Provider.of<UpcomingExpenseProvider>(context, listen: false)
        .fetchUpcomingExpenses();
  }
}
