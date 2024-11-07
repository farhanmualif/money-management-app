import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expected_income_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';

class IncomeExpensePage extends StatefulWidget {
  const IncomeExpensePage({super.key});

  @override
  State<IncomeExpensePage> createState() => _IncomeExpensePageState();
}

class _IncomeExpensePageState extends State<IncomeExpensePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: 'INCOME'),
              Tab(text: 'EXPENSE'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IncomeTab(),
            ExpenseTab(),
          ],
        ),
      ),
    );
  }
}

class IncomeTab extends StatelessWidget {
  const IncomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, ExpectedIncomeProvider>(
      builder: (context, incomeProvider, expectedIncomeProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await incomeProvider.fetchProfile();
            await expectedIncomeProvider.fetchExpectedIncome();
          },
          child: incomeProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    _buildButtonAddIncome(context),
                    _buildIncomeList(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Consumer2<ExpectedIncomeProvider, ProfileProvider>(
      builder: (context, expectedIncomeProvider, profileProvider, _) {
        return SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 35),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary,
                  Color.fromARGB(255, 80, 80, 200),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                _buildHeaderItem('EXPECTED INCOME',
                    expectedIncomeProvider.expectedIncome?.expectedIncome ?? 0),
                const SizedBox(height: 16),
                _buildHeaderItem('CURRENT INCOME',
                    profileProvider.profile?.totalIncome ?? 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderItem(String title, int amount) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyFormat.convertToIdr(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonAddIncome(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'INCOME SOURCES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/form_add_income");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('+ ADD', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeList() {
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, _) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final income = incomeProvider.incomes?[index];
              if (income == null) return const SizedBox.shrink();

              return IncomeListItem(income: income);
            },
            childCount: incomeProvider.incomes?.length ?? 0,
          ),
        );
      },
    );
  }
}

class IncomeListItem extends StatelessWidget {
  final Income income;

  const IncomeListItem({super.key, required this.income});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed("/detail_income", arguments: income),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.payment, color: Colors.white),
          ),
          title: Text(income.name),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(income.date)),
          trailing: Text(
            CurrencyFormat.convertToIdr(income.amount),
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ExpenseTab extends StatelessWidget {
  const ExpenseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpenseProvider, ExpectedExpenseProvider, ProfileProvider>(
        builder: (context, expenseProvider, expectedExpenseProvider,
            profileProvider, child) {
      return RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.fetchExpenses();
          await expectedExpenseProvider.fetchExpectedExpense();
          await profileProvider.fetchProfile();
        },
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildButtonAddExpense(context),
            _buildExpenseList(),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 35),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary,
              Color.fromARGB(255, 80, 80, 200),
            ],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Consumer2<ExpectedExpenseProvider, ProfileProvider>(
          builder: (context, expectedExpenseProvider, profileProvider, child) {
            return Column(
              children: [
                _buildHeaderItem(
                    'EXPECTED EXPENSE',
                    expectedExpenseProvider
                            .expectedExpenseResponse?.data.expectedExpense ??
                        0),
                const SizedBox(height: 16),
                _buildHeaderItem('CURRENT EXPENSE',
                    profileProvider.profile?.totalExpenses ?? 0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String title, int amount) {
    print("Header Item Called: $title, Amount: $amount");
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyFormat.convertToIdr(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonAddExpense(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'EXPENSE SOURCES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/form_add_expense");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('+ ADD', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        return SliverToBoxAdapter(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var expense in expenseProvider.expenses ?? [])
                  ExpenseListItem(expense: expense),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed("/detail_expense", arguments: expense),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.payment, color: Colors.white),
          ),
          title: Text(expense.name),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(expense.date)),
          trailing: Text(
            CurrencyFormat.convertToIdr(expense.amount),
            style: TextStyle(
                color: expense.isEarned == true ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
