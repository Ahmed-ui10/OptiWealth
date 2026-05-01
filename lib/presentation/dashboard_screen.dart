import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dashboard_facade.dart';
import '../../locale_provider.dart';
import 'transactions_screen.dart';
import 'budget_management_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'notifications_screen.dart';
import 'profile_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardFacade _facade = DashboardFacade();
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _facade.getDashboardData(widget.userId);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(isArabic ? 'لوحة التحكم' : 'Dashboard', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(0, 245, 245, 245),

        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 255, 255, 255),
               Color.fromARGB(255, 38, 52, 154),
                 Color.fromARGB(255, 8, 15, 66),
               Color(0xFF0A0E27)],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 0, 7, 147),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                      Color.fromARGB(255, 38, 52, 154),
                      Color.fromARGB(255, 8, 15, 66),
                      Color(0xFF0A0E27)],
                ),
              ),
              child: Text(
                isArabic ? 'القائمة' : 'Menu',
                style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDrawerItem(
              Icons.home,
              isArabic ? 'الرئيسية' : 'Dashboard',
              () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              Icons.receipt,
              isArabic ? 'المعاملات' : 'Transactions',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionsScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.bar_chart,
              isArabic ? 'الميزانيات' : 'Budgets',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BudgetManagementScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            _buildDrawerItem(Icons.flag, isArabic ? 'الأهداف' : 'Goals', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalsScreen(userId: widget.userId),
                ),
              );
            }),
            _buildDrawerItem(
              Icons.pie_chart,
              isArabic ? 'التقارير' : 'Reports',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportsScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.notifications,
              isArabic ? 'الإشعارات' : 'Notifications',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              Icons.settings,
              isArabic ? 'الملف الشخصي' : 'Profile',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileSettingsScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 38, 52, 154),
                      Color.fromARGB(255, 8, 15, 66),
                      Color(0xFF0A0E27)],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(_data['balance'], isArabic),
                      const SizedBox(height: 20),
                      Text(
                        isArabic ? 'أحدث المعاملات' : 'Recent Transactions',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_data['recent'] as List).map(
                        (t) => _buildTransactionTile(t),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'الميزانيات النشطة' : 'Active Budgets',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_data['budgets'] as List).map(
                        (b) => _buildBudgetCard(b),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF5B042)),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }

  Widget _buildBalanceCard(double balance, bool isArabic) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5B042), Color(0xFFF39C12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isArabic ? 'الرصيد الكلي' : 'Total Balance',
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF2A3A4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          t.transactionType ? Icons.arrow_upward : Icons.arrow_downward,
          color: t.transactionType ? Colors.green : Colors.red,
        ),
        title: Text(t.description, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          t.dateTime.toLocal().toString(),
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Text(
          '\$${t.amount}',
          style: TextStyle(
            color: t.transactionType ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF2A3A4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  b.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${b.spentAmount} / \$${b.budgetAmount}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: b.spentPercentage,
                backgroundColor: Colors.grey[800],
                color: b.spentPercentage >= 1
                    ? Colors.red
                    : const Color(0xFFF5B042),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
