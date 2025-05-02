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

class _IncomeExpensePageState extends State<IncomeExpensePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
            ),
          ),
        ),
        title: const Text(
          'Income & Expense',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          unselectedLabelStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_downward, color: Colors.white),
              text: 'Income',
            ),
            Tab(
              icon: Icon(Icons.arrow_upward, color: Colors.white),
              text: 'Expense',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomeTab(),
          _buildExpenseTab(),
        ],
      ),
    );
  }

  Widget _buildIncomeTab() {
    return Consumer<IncomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.incomes?.isEmpty ?? true) {
          return _buildEmptyState(
              'No income records found', Icons.account_balance_wallet);
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchIncomes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.incomes?.length,
            itemBuilder: (context, index) {
              final income = provider.incomes?[index];
              return _buildIncomeCard(income!);
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.expenses.isEmpty) {
          return _buildEmptyState(
              'No expense records found', Icons.shopping_cart);
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchExpenses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return _buildExpenseCard(expense);
            },
          ),
        );
      },
    );
  }

  Widget _buildIncomeCard(Income income) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed("/detail_income", arguments: income),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.arrow_downward, color: AppColors.greenColor),
          ),
          title: Text(
            income.name,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(income.date),
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: income.isEarned
                          ? AppColors.greenColor.withOpacity(0.1)
                          : AppColors.redColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      income.isEarned ? 'Earned' : 'Not Earned',
                      style: TextStyle(
                        color: income.isEarned
                            ? AppColors.greenColor
                            : AppColors.redColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (income.isRecurring) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Recurring - ${income.frequency}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Text(
            CurrencyFormat.convertToIdr(income.amount),
            style: const TextStyle(
              color: AppColors.greenColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed("/detail_expense", arguments: expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.redColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_upward, color: AppColors.redColor),
          ),
          title: Text(
            expense.name,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(expense.date),
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.paymentMethod,
                      style: const TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (expense.isRequring) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Recurring - ${expense.frequency}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Text(
            CurrencyFormat.convertToIdr(expense.amount),
            style: const TextStyle(
              color: AppColors.redColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
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
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor))
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
                  AppColors.primaryColor,
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
                backgroundColor: AppColors.primaryColor,
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
            backgroundColor: AppColors.primaryColor,
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
              AppColors.primaryColor,
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
                backgroundColor: AppColors.primaryColor,
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
            backgroundColor: AppColors.primaryColor,
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
