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

// Custom scaffold widget with gradient background and responsive drawer (RTL/LTR support)
class CustomScaffold extends StatelessWidget {
  // Main content body of the screen
  final Widget body;
  // Title text shown in the AppBar
  final String title;
  // Current user ID passed to child screens
  final int userId;
  // Whether to show a back button in the AppBar
  final bool showBackButton;
  // Whether to completely hide the drawer menu
  final bool hideMenu;
  // Optional floating action button
  final Widget? floatingActionButton;
  // Position of the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  // Constructor with default values for optional parameters
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
    // Check if Arabic language is active via LocaleProvider
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;

    return Scaffold(
      // Base background color (visible behind gradients)
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0, // Remove shadow
        centerTitle: true, // Center the title horizontally
        leading: _buildLeading(context, isArabic), // Menu or back button based on direction
        actions: _buildActions(context, isArabic), // Additional actions (back button for RTL)
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
      // Drawer appears on the left for LTR (English), on the right for RTL (Arabic)
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

  // Builds the leading widget (left side of AppBar) based on language and flags
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

  // Builds the actions list (right side of AppBar) used for back or menu in RTL mode
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

  // Builds the drawer menu with all navigation items
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
          // Drawer items: Dashboard, Transactions, Budgets, Goals, Reports, Notifications, Profile
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

  // Builds a single drawer item with icon, title, and destination screen
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF5B042)), // Custom orange color for icons
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.pop(context); // Close drawer before navigating
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}