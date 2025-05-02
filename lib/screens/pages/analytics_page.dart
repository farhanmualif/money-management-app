import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/models/goal.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/goal_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/screens/widgets/custome_dropdown.dart';
import 'package:money_app_new/screens/widgets/indocator.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';
import 'dart:math' show max;

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          title: const Text(
            'Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: 'GOAL'),
              Tab(text: 'INCOME'),
              Tab(text: 'EXPENSE'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GoalTab(),
            IncomeTab(),
            ExpenseTab(),
          ],
        ),
      ),
    );
  }
}

class IncomeTab extends StatefulWidget {
  const IncomeTab({super.key});

  @override
  State<IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends State<IncomeTab> {
  int touchedIndex = -1;
  List<Income>? _incomes;
  String? _selectedDropdownValue = 'All Income';
  final List<Color> _chartColors = [
    const Color(0xFF2563EB), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF06B6D4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncomes(null);
    });
  }

  Future<void> _loadIncomes(String? selectedDropdownValue) async {
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    await incomeProvider.fetchIncomes();
    if (mounted) {
      setState(() {
        _incomes = incomeProvider.incomes;
        _selectedDropdownValue = selectedDropdownValue;
        // Filter incomes based on the selected dropdown value
        if (selectedDropdownValue != null) {
          switch (selectedDropdownValue) {
            case 'All Income':
              _incomes = _incomes?.toList();
              break;
            case 'Earned Income':
              _incomes = _incomes?.where((income) => income.isEarned).toList();
              break;

            default:
              // Handle default case or unknown value
              break;
          }
        }
        // Sort incomes by amount in descending order
        _incomes?.sort((a, b) => b.amount.compareTo(a.amount));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadIncomes(_selectedDropdownValue),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20),
              child: CustomDropdown(
                type: 'Income',
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDropdownValue = newValue;
                    _loadIncomes(newValue);
                  });
                },
              ),
            ),
            if (_incomes == null)
              const Center(child: CircularProgressIndicator())
            else if (_incomes!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No income data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 300,
                    margin: const EdgeInsets.only(top: 19, bottom: 32),
                    padding: const EdgeInsets.all(20),
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Income Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: _incomes!.asMap().entries.map((entry) {
                            return _buildLegendItem(
                              entry.value.name,
                              _chartColors[entry.key % _chartColors.length],
                              entry.value.amount,
                              _calculatePercentage(entry.value.amount),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      String label, Color color, int amount, double percentage) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyFormat.convertToIdr(amount)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePercentage(int amount) {
    final totalAmount = _incomes!.fold(0, (sum, income) => sum + income.amount);
    return (amount / totalAmount) * 100;
  }

  List<PieChartSectionData> showingSections() {
    return _incomes!.asMap().entries.map((entry) {
      final isTouched = entry.key == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final percentage = _calculatePercentage(entry.value.amount);

      return PieChartSectionData(
        color: _chartColors[entry.key % _chartColors.length],
        value: entry.value.amount.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class GoalTab extends StatefulWidget {
  const GoalTab({super.key});

  @override
  State<GoalTab> createState() => _GoalTabState();
}

class _GoalTabState extends State<GoalTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.goals.isEmpty) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: AppColors.textColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No goals yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textColor.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAddButton(),
            ],
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail_goal',
                        arguments: goal,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textColor.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            _buildAddButton(),
          ],
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        heroTag: 'add_goal_fab',
        onPressed: () => Navigator.pushNamed(context, '/form_add_goal'),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ExpenseTab extends StatefulWidget {
  const ExpenseTab({super.key});

  @override
  State<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  int touchedIndex = -1;
  final List<Color> _chartColors = [
    const Color(0xFF2563EB), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF06B6D4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 64,
                  color: AppColors.textColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No expense data yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textColor.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Group expenses by name
        final expenseGroups = <String, double>{};
        for (var expense in provider.expenses) {
          expenseGroups[expense.name] =
              (expenseGroups[expense.name] ?? 0) + expense.amount;
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 21),
                padding: const EdgeInsets.all(20),
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: showingSections(expenseGroups),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: expenseGroups.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        return _buildLegendItem(
                          entry.value.key,
                          _chartColors[entry.key % _chartColors.length],
                          entry.value.value.toInt(),
                          _calculatePercentage(
                              entry.value.value, expenseGroups),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(Map<String, double> expenseGroups) {
    return expenseGroups.entries.toList().asMap().entries.map((entry) {
      final isTouched = entry.key == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final percentage = _calculatePercentage(entry.value.value, expenseGroups);

      return PieChartSectionData(
        color: _chartColors[entry.key % _chartColors.length],
        value: entry.value.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(
      String label, Color color, int amount, double percentage) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyFormat.convertToIdr(amount)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePercentage(
      double amount, Map<String, double> expenseGroups) {
    final total = expenseGroups.values.reduce((a, b) => a + b);
    return (amount / total) * 100;
  }
}
