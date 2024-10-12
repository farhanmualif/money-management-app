import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: 'GOAL'),
              Tab(text: 'INCOME'),
              Tab(text: 'EXPENSE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GoalTab(),
            const IncomeTab(),
            const ExpenseTab(),
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
  final List<Color> _rainbowColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIncomes();
    });
  }

  Future<void> _loadIncomes() async {
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    await incomeProvider.fetchIncomes();
    if (mounted) {
      setState(() {
        _incomes = incomeProvider.incomes;
        // Sort incomes by amount in descending order
        _incomes?.sort((a, b) => b.amount.compareTo(a.amount));
      });
    }
  }

  Color _getColor(int index) {
    return _rainbowColors[index % _rainbowColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadIncomes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(20),
              child: CustomDropdown(
                type: 'Income',
              )),
          Expanded(
            flex: 2,
            child: _incomes == null
                ? const Center(child: CircularProgressIndicator())
                : PieChart(
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
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: showingSections(),
                    ),
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: _incomes == null
                  ? []
                  : _incomes!.asMap().entries.map((entry) {
                      return Indicator(
                        color: _getColor(entry.key),
                        text: entry.value.name,
                        isSquare: true,
                      );
                    }).toList(),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (_incomes == null || _incomes!.isEmpty) {
      return [
        PieChartSectionData(
          color: AppColors.primary,
          value: 100,
          title: '0%',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 13, color: Colors.black),
        ),
      ];
    } else {
      return _incomes!.asMap().entries.map((entry) {
        final isTouched = entry.key == touchedIndex;
        final fontSize = isTouched ? 16.0 : 13.0;
        final radius = isTouched ? 110.0 : 100.0;
        final totalAmount =
            _incomes!.fold(0, (sum, income) => sum + income.amount);
        final percentage = (entry.value.amount / totalAmount) * 100;

        return PieChartSectionData(
          color: _getColor(entry.key),
          value: entry.value.amount.toDouble(),
          title:
              '${CurrencyFormat.convertToIdr(entry.value.amount)}\n${percentage.toStringAsFixed(2)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class GoalTab extends StatelessWidget {
  GoalTab({super.key});

  final GoalProvider goalProvider = GoalProvider();

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    goalProvider.fetchGoals(); // Fetch goals when the tab is built

    return RefreshIndicator(
      onRefresh: () async {
        await goalProvider.fetchGoals();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildAddCalcuButton(context),
          ),
          _buildGoalList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primary,
            Color.fromARGB(255, 133, 130, 230),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        children: [
          Text(
            "Goal",
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildAddCalcuButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed("/coming_soon"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Calculator',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed("/form_add_goal"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('+ ADD', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList() {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        return goalProvider.isLoading
            ? SliverList(
                delegate: SliverChildListDelegate([
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ]),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildGoalItem(goalProvider.goals[index], context),
                  childCount: goalProvider.goals.length,
                ),
              );
      },
    );
  }

  Widget _buildGoalItem(Goal goal, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/detail_goal", arguments: goal);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: ListTile(
          title: Text(goal.name),
          subtitle: Text(goal.description),
        ),
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
  List<Expense>? _expenses;
  final List<Color> _rainbowColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  Future<void> _loadExpenses() async {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.fetchExpenses();
    if (mounted) {
      setState(() {
        _expenses = expenseProvider.expenses;
        _expenses?.sort((a, b) => b.amount.compareTo(a.amount));
      });
    }
  }

  Color _getColor(int index) {
    return _rainbowColors[index % _rainbowColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Container(
          //     margin: const EdgeInsets.all(20), child: const CustomDropdown()),
          Expanded(
            flex: 2,
            child: _expenses == null
                ? const Center(child: CircularProgressIndicator())
                : PieChart(
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
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: showingSections(),
                    ),
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: _expenses == null
                  ? []
                  : _expenses!.asMap().entries.map((entry) {
                      return Indicator(
                        color: _getColor(entry.key),
                        text: entry.value.name,
                        isSquare: true,
                      );
                    }).toList(),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (_expenses == null || _expenses!.isEmpty) {
      return [
        PieChartSectionData(
          color: AppColors.primary,
          value: 100,
          title: '0%',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 13, color: Colors.black),
        ),
      ];
    } else {
      return _expenses!.asMap().entries.map((entry) {
        final isTouched = entry.key == touchedIndex;
        final fontSize = isTouched ? 16.0 : 13.0;
        final radius = isTouched ? 110.0 : 100.0;
        final totalAmount =
            _expenses!.fold(0, (sum, expense) => sum + expense.amount);
        final percentage = (entry.value.amount / totalAmount) * 100;

        return PieChartSectionData(
          color: _getColor(entry.key),
          value: entry.value.amount.toDouble(),
          title:
              '${CurrencyFormat.convertToIdr(entry.value.amount)}\n${percentage.toStringAsFixed(2)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
