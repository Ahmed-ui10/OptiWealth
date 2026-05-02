import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dashboard_facade.dart';
import '../../repositories/category_repository.dart';
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
  Map<int, String> _categoryNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _facade.getDashboardData(widget.userId);
    final categories = await CategoryRepository().getAllCategories();
    final names = <int, String>{};
    for (var cat in categories) {
      names[cat.categoryId] = cat.name;
    }
    setState(() {
      _data = data;
      _categoryNames = names;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final balance = _data['balance'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          isArabic ? 'لوحة التحكم' : 'Dashboard',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
      drawer: Drawer(
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
              Icons.home,
              isArabic ? 'الرئيسية' : 'Dashboard',
              DashboardScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.receipt,
              isArabic ? 'المعاملات' : 'Transactions',
              TransactionsScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.bar_chart,
              isArabic ? 'الميزانيات' : 'Budgets',
              BudgetManagementScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.flag,
              isArabic ? 'الأهداف' : 'Goals',
              GoalsScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.pie_chart,
              isArabic ? 'التقارير' : 'Reports',
              ReportsScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.notifications,
              isArabic ? 'الإشعارات' : 'Notifications',
              NotificationsScreen(userId: widget.userId),
            ),
            _buildDrawerItem(
              Icons.settings,
              isArabic ? 'الملف الشخصي' : 'Profile',
              ProfileSettingsScreen(userId: widget.userId),
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
                    colors: [
                      Colors.white,
                      Color(0xFF26349A),
                      Color(0xFF080F42),
                      Color(0xFF0A0E27),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(balance, isArabic),
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
                        (t) => _buildTransactionTile(t, isArabic),
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
                        (b) => _buildBudgetCard(b, isArabic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF5B042)),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () async {
        Navigator.pop(context); // إغلاق الدراور
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        _loadData(); // تحديث الداشبورد بعد العودة
      },
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
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? '${balance.toStringAsFixed(2)} ج.م'
                  : '${balance.toStringAsFixed(2)} E.P',
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

  Widget _buildTransactionTile(dynamic t, bool isArabic) {
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
          isArabic ? '${t.amount} ج.م' : '${t.amount} E.P',
          style: TextStyle(
            color: t.transactionType ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b, bool isArabic) {
    final categoryName =
        _categoryNames[b.categoryId] ?? 'Category ${b.categoryId}';
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
                  categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isArabic
                      ? '${b.spentAmount} ج.م / ${b.budgetAmount} ج.م'
                      : '${b.spentAmount} E.P / ${b.budgetAmount} E.P',
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
