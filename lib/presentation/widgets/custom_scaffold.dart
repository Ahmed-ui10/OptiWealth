import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../locale_provider.dart';
import '../dashboard_screen.dart';
import '../transactions_screen.dart';
import '../budget_management_screen.dart';
import '../goals_screen.dart';
import '../reports_screen.dart';
import '../notifications_screen.dart';
import '../profile_settings_screen.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int userId;
  final bool showBackButton;
  final bool hideMenu;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const CustomScaffold({
    Key? key,
    required this.body,
    required this.title,
    required this.userId,
    this.showBackButton = false,
    this.hideMenu = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: _buildLeading(context, isArabic),
        actions: _buildActions(context, isArabic),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFF26349A),
                Color(0xFF0A0E27),
                Color(0xFF26349A),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
      drawer: (!isArabic && !hideMenu) ? _buildDrawer(context, isArabic) : null,
      endDrawer: (isArabic && !hideMenu)
          ? _buildDrawer(context, isArabic)
          : null,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFF26349A),
              Color(0xFF080F42),
              Color(0xFF0A0E27),
            ],
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget? _buildLeading(BuildContext context, bool isArabic) {
    if (!isArabic) {
      if (showBackButton) {
        return IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        );
      }
      if (!hideMenu) {
        return Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        );
      }
    }
    return null;
  }

  List<Widget> _buildActions(BuildContext context, bool isArabic) {
    if (isArabic) {
      if (showBackButton) {
        return [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ];
      }
      if (!hideMenu) {
        return [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ];
      }
    }
    return [];
  }

  Widget _buildDrawer(BuildContext context, bool isArabic) {
    return Drawer(
      backgroundColor: const Color(0xFF000793),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF26349A),
                  Color(0xFF080F42),
                  Color(0xFF0A0E27),
                ],
              ),
            ),
            child: Text(
              isArabic ? 'القائمة' : 'Menu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.home,
            isArabic ? 'الرئيسية' : 'Dashboard',
            DashboardScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.receipt,
            isArabic ? 'المعاملات' : 'Transactions',
            TransactionsScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.bar_chart,
            isArabic ? 'الميزانيات' : 'Budgets',
            BudgetManagementScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.flag,
            isArabic ? 'الأهداف' : 'Goals',
            GoalsScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.pie_chart,
            isArabic ? 'التقارير' : 'Reports',
            ReportsScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.notifications,
            isArabic ? 'الإشعارات' : 'Notifications',
            NotificationsScreen(userId: userId),
          ),
          _buildDrawerItem(
            context,
            Icons.settings,
            isArabic ? 'الملف الشخصي' : 'Profile',
            ProfileSettingsScreen(userId: userId),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF5B042)),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
