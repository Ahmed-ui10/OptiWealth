import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/report_service.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../models/financial_report_model.dart';
import 'widgets/custom_scaffold.dart';

const Map<String, String> _enToAr = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
  'Cash': 'كاش',
  'Credit Card': 'بطاقة ائتمان',
  'Bank Transfer': 'تحويل بنكي',
};

const Map<String, String> _arToEn = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'بواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
  'كاش': 'Cash',
  'بطاقة ائتمان': 'Credit Card',
  'تحويل بنكي': 'Bank Transfer',
};

String _translate(String name, bool isArabic) {
  if (isArabic)
    return _enToAr[name] ?? name;
  else
    return _arToEn[name] ?? name;
}

class ReportsScreen extends StatefulWidget {
  final int userId;
  const ReportsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _service = ReportService();
  FinancialReport? _report;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    try {
      final report = await _service.generateReport(widget.userId, start, end);
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      return value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currency = Provider.of<CurrencyProvider>(context);
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'التقارير المالية' : 'Financial Reports',
      showBackButton: false,
      hideMenu: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
          ? Center(
              child: Text(
                isArabic
                    ? 'لا توجد بيانات لهذه الفترة'
                    : 'No data for this period',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF5B042),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_report!.categoryTotals.isNotEmpty)
                      _buildPieChartSection(isArabic),
                    const SizedBox(height: 40),
                    _buildIncomeExpenseBarChart(isArabic),
                    const SizedBox(height: 40),
                    _buildPaymentMethodTable(isArabic, currency),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPieChartSection(bool isArabic) {
    final Map<String, double> translatedTotals = {};
    for (var entry in _report!.categoryTotals.entries) {
      final translatedName = _translate(entry.key, isArabic);
      translatedTotals[translatedName] = entry.value;
    }
    return Column(
      children: [
        Text(
          isArabic ? 'المصروفات حسب التصنيف' : 'Expenses by Category',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: translatedTotals.entries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  title: e.key,
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: Colors
                      .primaries[e.key.hashCode % Colors.primaries.length],
                );
              }).toList(),
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseBarChart(bool isArabic) {
    final income = _report!.incomeVsExpenseData['income'] ?? 0.0;
    final expense = _report!.incomeVsExpenseData['expense'] ?? 0.0;
    final maxValue = income > expense ? income : expense;
    return Column(
      children: [
        Text(
          isArabic ? 'الدخل مقابل المصروفات' : 'Income vs Expense',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: Colors.green,
                      width: 35,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: expense,
                      color: Colors.red,
                      width: 35,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) {
                      String title = '';
                      if (value == 0) title = isArabic ? 'دخل' : 'Income';
                      if (value == 1) title = isArabic ? 'مصروف' : 'Expense';
                      return Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, _) => Text(
                      _formatNumber(value),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: maxValue > 0, // only draw if maxValue > 0
                drawVerticalLine: false,
                horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.white24, strokeWidth: 1),
              ),
              barTouchData: BarTouchData(enabled: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTable(bool isArabic, CurrencyProvider currency) {
    final incomeMap = _report!.incomeByMethod;
    final expenseMap = _report!.expenseByMethod;
    final allMethods = {...incomeMap.keys, ...expenseMap.keys}.toList();
    allMethods.sort();
    if (allMethods.isEmpty) return Container();
    double totalIncome = 0;
    double totalExpense = 0;
    for (var method in allMethods) {
      totalIncome += incomeMap[method] ?? 0;
      totalExpense += expenseMap[method] ?? 0;
    }
    final netTotal = totalIncome - totalExpense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic
              ? 'الدخل والمصروفات حسب طريقة الدفع'
              : 'Income & Expense by Payment Method',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF2A3A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        isArabic ? 'طريقة الدفع' : 'Method',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        isArabic ? 'الدخل' : 'Income',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        isArabic ? 'المصروفات' : 'Expense',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        isArabic ? 'صافي' : 'Net',
                        style: const TextStyle(
                          color: Color(0xFFF5B042),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                ...allMethods.map((method) {
                  final inc = incomeMap[method] ?? 0;
                  final exp = expenseMap[method] ?? 0;
                  final net = inc - exp;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _translate(method, isArabic),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currency.format(inc, isArabic),
                            style: const TextStyle(color: Colors.green),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currency.format(exp, isArabic),
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currency.format(net, isArabic),
                            style: TextStyle(
                              color: net >= 0 ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        isArabic ? 'الإجمالي' : 'Total',
                        style: const TextStyle(
                          color: Color(0xFFF5B042),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currency.format(totalIncome, isArabic),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currency.format(totalExpense, isArabic),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currency.format(netTotal, isArabic),
                        style: TextStyle(
                          color: netTotal >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
