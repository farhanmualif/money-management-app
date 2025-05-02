import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_app_new/models/balance_history.dart';
import 'package:money_app_new/screens/splash_screen.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';
import 'package:money_app_new/helper/currency_format.dart';
import 'package:money_app_new/providers/balance_history_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/providers/transaction_provider.dart';
import 'package:money_app_new/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Modern color scheme

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildBalanceSection(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildTransactionSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: true,
      backgroundColor: AppColors.surfaceColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<ProfileProvider>(
                    builder: (_, provider, __) => Text(
                      provider.profile?.firstName ?? 'User',
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTapDown: (TapDownDetails details) {
                  showMenu(
                    color: Colors.white,
                    
                    context: context,
                    position: RelativeRect.fromLTRB(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                      details.globalPosition.dx + 1,
                      details.globalPosition.dy + 1,
                    ),
                    items: [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.person_outline,
                                color: AppColors.primaryColor),
                            SizedBox(width: 8),
                            Text('Profile'),
                          ],
                        ),
                        onTap: () async {
                          await _deleteCache();

                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SplashScreen()),
                            );
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.redColor),
                            SizedBox(width: 8),
                            Text('Logout',
                                style: TextStyle(color: AppColors.redColor)),
                          ],
                        ),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  );
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.person_outline,
                      color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Consumer<BalanceHistoryProvider>(
                  builder: (_, provider, __) => Row(
                    children: [
                      const Icon(Icons.trending_up,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _calculateGrowthPercentage(provider.balanceHistory),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<ProfileProvider>(
            builder: (_, provider, __) => Text(
              CurrencyFormat.convertToIdr(
                provider.profile?.totalBalance ?? 0,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: _buildBalanceHistoryChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final actions = [
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Account',
        'color': AppColors.greenColor
      },
      {
        'icon': Icons.swap_vert,
        'label': 'Transaction',
        'color': AppColors.accentColor
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Analytics',
        'color': AppColors.primaryColor
      },
      {
        'icon': Icons.person,
        'label': 'Profile',
        'color': AppColors.secondaryColor
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            if (action['label'] == 'Transaction') {
              Navigator.of(context).pushNamed('/income_expanse');
            } else if (action['label'] == 'Account') {
              Navigator.of(context).pushNamed('/account_page');
            } else if (action['label'] == 'Analytics') {
              Navigator.of(context).pushNamed('/analitycs_page');
            } else if (action['label'] == 'Profile') {
              Navigator.of(context).pushNamed('/profile_page');
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'] as String,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<TransactionProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _buildTransactionItem(
                provider.transactions[index],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction.type.toString())
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type.toString()),
              color: _getTransactionColor(transaction.type.toString()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date.toString(),
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormat.convertToIdr(transaction.amount),
            style: TextStyle(
              color: _getTransactionColor(transaction.type.toString()),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return AppColors.greenColor;
      case 'expense':
        return AppColors.redColor;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Icons.arrow_downward;
      case 'expense':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  String _calculateGrowthPercentage(List<BalanceHistory> history) {
    if (history.length < 2) return '0%';

    final latestBalance = history.last.balance;
    final previousBalance = history.first.balance;

    if (previousBalance == 0) return '0%';

    final percentageChange =
        ((latestBalance - previousBalance) / previousBalance) * 100;
    final sign = percentageChange >= 0 ? '+' : '';
    return '$sign${percentageChange.toStringAsFixed(1)}%';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.redColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Periksa apakah cache benar-benar terhapus
      final allKeys = prefs.getKeys();
      if (allKeys.isEmpty) {
        debugPrint("Cache berhasil dihapus. Tidak ada key yang tersisa.");
      } else {
        debugPrint("Peringatan: Masih ada ${allKeys.length} key dalam cache.");
      }
    } catch (e) {
      debugPrint("Error saat menghapus cache: $e");
    }
  }
}
