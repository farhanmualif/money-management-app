import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/providers/balance_history_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/providers/transaction_provider.dart';
import 'package:money_app_new/providers/upcoming_expense_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
        Provider.of<UpcomingExpenseProvider>(context, listen: false)
            .fetchUpcomingExpenses();
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: _buildMainContent(context),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color.fromARGB(255, 68, 74, 176), Color(0xFF1F2462)],
          ),
        ),
      ),
      title: const Text("Hello World",
          style: TextStyle(color: Colors.white, fontSize: 16)),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/coming_soon'),
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        )
      ],
    );
  }

  Widget _buildHeaderGradient() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color.fromARGB(255, 68, 74, 176), Color(0xFF1F2462)],
          ),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeaderGradient(),
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 85), // Memberikan ruang untuk card
                      _buildUpcomingExpenses(),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 60, // Sesuaikan posisi vertikal card
          left: 0,
          right: 0,
          child: _buildBalanceCard(context),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<ProfileProvider>(
              builder: (_, profileProvider, __) => Text(
                CurrencyFormat.convertToIdr(
                    profileProvider.profile?.totalBalance ?? 0),
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text("Total Balance"),
                const SizedBox(width: 50),
                Expanded(child: _buildBalanceHistoryChart()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHistoryChart() {
    return SizedBox(
      height: 50,
      child: Consumer<BalanceHistoryProvider>(
        builder: (_, provider, __) {
          if (provider.balanceHistory.isEmpty) {
            return const Center(child: Text('Balance history not found'));
          }
          return LineChart(_createLineChartData(provider));
        },
      ),
    );
  }

  LineChartData _createLineChartData(BalanceHistoryProvider provider) {
    final maxY = provider.balanceHistory
            .map((history) => history.balance)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() *
        1.1;

    // Introduce a threshold value (e.g., 20% of the max value)
    final threshold = maxY * 0.2;

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: provider.balanceHistory.asMap().entries.map((entry) {
            final spot =
                FlSpot(entry.key.toDouble(), entry.value.balance.toDouble());
            // Check if the spot's y-value is below the threshold
            if (spot.y < threshold) {
              // Create a new FlSpot with the y-value set to the threshold
              return FlSpot(spot.x, threshold);
            } else {
              return spot;
            }
          }).toList(),
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: maxY,
    );
  }

  Widget _buildUpcomingExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 15),
          child: Text(
            "Upcoming Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: Consumer<UpcomingExpenseProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.upcomingExpenses.length,
                itemBuilder: (context, index) =>
                    _buildExpenseCard(provider.upcomingExpenses[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(dynamic expense) {
    return Card(
      margin: const EdgeInsets.only(left: 20),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(expense.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(CurrencyFormat.convertToIdr(expense.amount),
                style: const TextStyle(color: Colors.green)),
            Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(expense.date)),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Consumer<TransactionProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.transactions.isEmpty) {
              return const Center(child: Text("No transaction data"));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.transactions.length,
              itemBuilder: (_, index) =>
                  _buildTransactionCard(provider.transactions[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        title: Text(transaction.name),
        subtitle: Text(transaction.paymentMethod),
        trailing: Text(
          CurrencyFormat.convertToIdr(transaction.amount),
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
