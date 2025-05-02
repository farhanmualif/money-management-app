import 'package:flutter/material.dart';
import 'package:money_app_new/authentication/login_screen.dart';
import 'package:money_app_new/authentication/signup_screen.dart';
import 'package:money_app_new/models/expense.dart';
import 'package:money_app_new/models/goal.dart';
import 'package:money_app_new/models/income.dart';
import 'package:money_app_new/providers/auth_provider.dart';
import 'package:money_app_new/providers/balance_history_provider.dart';
import 'package:money_app_new/providers/expected_expense_provider.dart';
import 'package:money_app_new/providers/expected_income_provider.dart';
import 'package:money_app_new/providers/expense_provider.dart';
import 'package:money_app_new/providers/goal_provider.dart';
import 'package:money_app_new/providers/income_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/providers/transaction_provider.dart';
import 'package:money_app_new/providers/upcoming_expense_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app_new/screens/cooming_soon_screen.dart';
import 'package:money_app_new/screens/detail_expense_screen.dart';
import 'package:money_app_new/screens/detail_goal.dart';
import 'package:money_app_new/screens/detail_income_screen.dart';
import 'package:money_app_new/screens/form_add_goal_screen.dart';
import 'package:money_app_new/screens/form_update_expense_screen.dart';
import 'package:money_app_new/screens/form_update_income_screen.dart';
import 'package:money_app_new/screens/form_add_expense_screen.dart';
import 'package:money_app_new/screens/form_add_income_screen.dart';
import 'package:money_app_new/screens/form_update_profile_screen.dart';
import 'package:money_app_new/screens/home_screen.dart';
import 'package:money_app_new/screens/pages/account_page.dart';
import 'package:money_app_new/screens/pages/analytics_page.dart';
import 'package:money_app_new/screens/pages/income_expense_page.dart';
import 'package:money_app_new/screens/pages/profile_page.dart';
import 'package:money_app_new/screens/splash_screen.dart';
import 'package:money_app_new/themes/themes.dart';

import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UpcomingExpenseProvider()..fetchUpcomingExpenses()),
        ChangeNotifierProvider(
            create: (_) => ProfileProvider()..fetchProfile()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()..fetchIncomes()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BalanceHistoryProvider()),
        ChangeNotifierProvider(
            create: (_) => ExpenseProvider()..fetchExpenses()),
        ChangeNotifierProvider(create: (_) => ExpectedIncomeProvider()),
        ChangeNotifierProvider(create: (_) => ExpectedExpenseProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors
              .primaryColor, // Mengatur warna default untuk CircularProgressIndicator
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/form_add_income': (context) => const FormAddIncomeScreen(),
        '/form_add_expense': (context) => const FormAddExpenseScreen(),
        '/income_expanse': (context) => const IncomeExpensePage(),
        '/account_page': (context) => const AccountPage(),
        '/goal_tab': (context) => const GoalTab(),
        '/analitycs_page': (context) => const AnalyticsPage(),
        '/profile_page': (context) => const ProfilePage(),
        '/form_add_goal': (context) => const FormAddGoalScreen(),
        '/register': (context) => const SignupScreen(),
        '/coming_soon': (context) => const ComingSoonScreen(),
        "/detail_income": (context) {
          final income = ModalRoute.of(context)!.settings.arguments as Income;
          return DetailIncome(income: income);
        },
        "/form_update_income": (context) {
          final income = ModalRoute.of(context)!.settings.arguments as Income;
          return FormUpdateIncomeScreen(income: income);
        },
        '/form_update_profile': (context) => const FormUpdateProfileScreen(),
        "/form_update_expense": (context) {
          final expense = ModalRoute.of(context)!.settings.arguments as Expense;
          return FormUpdateExpenseScreen(expense: expense);
        },
        "/detail_expense": (context) {
          final expense = ModalRoute.of(context)!.settings.arguments as Expense;
          return DetailExpense(expense: expense);
        },
        "/detail_goal": (context) {
          final goal = ModalRoute.of(context)!.settings.arguments as Goal;
          return DetailGoal(goal: goal);
        }
      },
    );
  }
}
