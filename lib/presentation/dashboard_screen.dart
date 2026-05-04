import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dashboard_facade.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import 'widgets/custom_scaffold.dart';

final Map<String, String> _enToAr = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};
final Map<String, String> _arToEn = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

String _translateCategory(String name, bool isArabic) {
  if (isArabic) return _enToAr[name] ?? name;
  return _arToEn[name] ?? name;
}

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
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await _facade.getDashboardData(widget.userId);
      final categories = await CategoryRepository().getAllCategories();
      final names = <int, String>{};
      for (var cat in categories) {
        names[cat.categoryId] = cat.name;
      }
      if (mounted) {
        setState(() {
          _data = data;
          _categoryNames = names;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(dynamic t, bool isArabic) {
    final categoryName = _categoryNames[t.categoryId] ?? 'Unknown';
    final translatedCategory = _translateCategory(categoryName, isArabic);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A4A),
        title: Text(
          isArabic ? 'تفاصيل المعاملة' : 'Transaction Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(isArabic ? 'الوصف' : 'Description', t.description),
            _detailRow(
              isArabic ? 'المبلغ' : 'Amount',
              isArabic ? '${t.amount} ج.م' : '${t.amount} E.P',
            ),
            _detailRow(
              isArabic ? 'التاريخ' : 'Date',
              _formatDateTime(t.dateTime),
            ),
            _detailRow(
              isArabic ? 'طريقة الدفع' : 'Payment Method',
              t.paymentMethod,
            ),
            _detailRow(
              isArabic ? 'النوع' : 'Type',
              t.transactionType
                  ? (isArabic ? 'دخل' : 'Income')
                  : (isArabic ? 'مصروف' : 'Expense'),
            ),
            _detailRow(isArabic ? 'التصنيف' : 'Category', translatedCategory),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isArabic ? 'إغلاق' : 'Close',
              style: const TextStyle(color: Color(0xFFF5B042)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetDetails(dynamic b, bool isArabic) {
    final originalName =
        _categoryNames[b.categoryId] ?? 'Category ${b.categoryId}';
    final displayName = _translateCategory(originalName, isArabic);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A4A),
        title: Text(
          isArabic ? 'تفاصيل الميزانية' : 'Budget Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(isArabic ? 'التصنيف' : 'Category', displayName),
            _detailRow(
              isArabic ? 'المبلغ المخطط' : 'Budget Amount',
              isArabic ? '${b.budgetAmount} ج.م' : '${b.budgetAmount} E.P',
            ),
            _detailRow(
              isArabic ? 'المبلغ المنفق' : 'Spent Amount',
              isArabic ? '${b.spentAmount} ج.م' : '${b.spentAmount} E.P',
            ),
            _detailRow(
              isArabic ? 'المتبقي' : 'Remaining',
              isArabic ? '${b.remaining} ج.م' : '${b.remaining} E.P',
            ),
            _detailRow(
              isArabic ? 'نسبة الإنفاق' : 'Spent Percentage',
              '${(b.spentPercentage * 100).toStringAsFixed(1)}%',
            ),
            _detailRow(isArabic ? 'الحالة' : 'Status', b.budgetStatus),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isArabic ? 'إغلاق' : 'Close',
              style: const TextStyle(color: Color(0xFFF5B042)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final balance = _data['balance'] ?? 0.0;

    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'لوحة التحكم' : 'Dashboard',
      showBackButton: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFF5B042),
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
    return GestureDetector(
      onTap: () => _showTransactionDetails(t, isArabic),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: const Color(0xFF2A3A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(
            t.transactionType ? Icons.arrow_upward : Icons.arrow_downward,
            color: t.transactionType ? Colors.green : Colors.red,
          ),
          title: Text(
            t.description,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _formatDateTime(t.dateTime),
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: Text(
            isArabic ? '${t.amount} ج.م' : '${t.amount} E.P',
            style: TextStyle(
              color: t.transactionType ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b, bool isArabic) {
    final originalName =
        _categoryNames[b.categoryId] ?? 'Category ${b.categoryId}';
    final displayName = _translateCategory(originalName, isArabic);
    return GestureDetector(
      onTap: () => _showBudgetDetails(b, isArabic),
      child: Card(
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
                    displayName,
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
      ),
    );
  }
}
