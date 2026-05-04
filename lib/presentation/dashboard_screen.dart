import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dashboard_facade.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
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

  // State variables to show/hide all items
  bool _showAllTransactions = false;
  bool _showAllBudgets = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        final currency = _data['currency'] as String;
        Provider.of<CurrencyProvider>(
          context,
          listen: false,
        ).setTargetCurrency(currency);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(
    dynamic t,
    bool isArabic,
    CurrencyProvider currency,
  ) {
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
              currency.format(t.amount, isArabic),
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

  void _showBudgetDetails(dynamic b, bool isArabic, CurrencyProvider currency) {
    final originalName =
        _categoryNames[b.categoryId] ?? 'Category ${b.categoryId}';
    final displayName = _translateCategory(originalName, isArabic);
    final remaining = b.budgetAmount - b.spentAmount;
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
              currency.format(b.budgetAmount, isArabic),
            ),
            _detailRow(
              isArabic ? 'المبلغ المنفق' : 'Spent Amount',
              currency.format(b.spentAmount, isArabic),
            ),
            _detailRow(
              isArabic ? 'المتبقي' : 'Remaining',
              currency.format(remaining, isArabic),
              textColor: remaining < 0 ? Colors.red : Colors.white,
            ),
            _detailRow(
              isArabic ? 'نسبة الإنفاق' : 'Spent Percentage',
              '${(b.spentPercentage * 100).toStringAsFixed(1)}%',
            ),
            _detailRow(
              isArabic ? 'الحالة' : 'Status',
              b.budgetStatus,
              textColor: b.budgetStatus == 'Exceeded'
                  ? Colors.red
                  : Colors.white,
            ),
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

  Widget _detailRow(
    String label,
    String value, {
    Color textColor = Colors.white,
  }) {
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
            child: Text(value, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currency = Provider.of<CurrencyProvider>(context);
    final balance = _data['balance'] ?? 0.0;
    final allTransactions = (_data['recent'] as List?) ?? [];
    final allBudgets = (_data['budgets'] as List?) ?? [];

    final displayedTransactions = _showAllTransactions
        ? allTransactions
        : allTransactions.take(5).toList();
    final displayedBudgets = _showAllBudgets
        ? allBudgets
        : allBudgets.take(5).toList();

    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'لوحة التحكم' : 'Dashboard',
      showBackButton: false,
      hideMenu: false,
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
                    _buildBalanceCard(balance, isArabic, currency),
                    const SizedBox(height: 20),
                    // Transactions section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'أحدث المعاملات' : 'Recent Transactions',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllTransactions = !_showAllTransactions;
                            });
                          },
                          child: Text(
                            _showAllTransactions
                                ? (isArabic ? 'إخفاء' : 'Show Less')
                                : (isArabic ? 'عرض الكل' : 'View All'),
                            style: const TextStyle(color: Color(0xFFF5B042)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...displayedTransactions.map(
                      (t) => _buildTransactionTile(t, isArabic, currency),
                    ),
                    if (displayedTransactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            isArabic ? 'لا توجد معاملات' : 'No transactions',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Budgets section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'الميزانيات النشطة' : 'Active Budgets',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllBudgets = !_showAllBudgets;
                            });
                          },
                          child: Text(
                            _showAllBudgets
                                ? (isArabic ? 'إخفاء' : 'Show Less')
                                : (isArabic ? 'عرض الكل' : 'View All'),
                            style: const TextStyle(color: Color(0xFFF5B042)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...displayedBudgets.map(
                      (b) => _buildBudgetCard(b, isArabic, currency),
                    ),
                    if (displayedBudgets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            isArabic
                                ? 'لا توجد ميزانيات نشطة'
                                : 'No active budgets',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(
    double balance,
    bool isArabic,
    CurrencyProvider currency,
  ) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5B042), Color(0xFFF39C12)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currency.format(balance, isArabic),
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

  Widget _buildTransactionTile(
    dynamic t,
    bool isArabic,
    CurrencyProvider currency,
  ) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(t, isArabic, currency),
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
            currency.format(t.amount, isArabic),
            style: TextStyle(
              color: t.transactionType ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b, bool isArabic, CurrencyProvider currency) {
    final originalName =
        _categoryNames[b.categoryId] ?? 'Category ${b.categoryId}';
    final displayName = _translateCategory(originalName, isArabic);
    final remaining = b.budgetAmount - b.spentAmount;
    return GestureDetector(
      onTap: () => _showBudgetDetails(b, isArabic, currency),
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
                    '${currency.format(b.spentAmount, isArabic)} / ${currency.format(b.budgetAmount, isArabic)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: b.spentPercentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[800],
                  color: b.spentPercentage >= 1
                      ? Colors.red
                      : const Color(0xFFF5B042),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isArabic
                    ? 'المتبقي: ${currency.format(remaining, isArabic)}'
                    : 'Remaining: ${currency.format(remaining, isArabic)}',
                style: TextStyle(
                  color: remaining < 0 ? Colors.red : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
