import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/report_service.dart';
import '../../locale_provider.dart';
import '../../models/financial_report_model.dart';
import 'widgets/custom_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'التقارير المالية' : 'Financial Reports',
      showBackButton: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null || _report!.categoryTotals.isEmpty
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
                    _buildPieChartSection(isArabic),
                    const SizedBox(height: 40),
                    _buildBarChartSection(isArabic),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPieChartSection(bool isArabic) {
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
          height: 250,
          child: PieChart(
            PieChartData(
              sections: _report!.categoryTotals.entries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  title: e.key,
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: Colors
                      .primaries[e.key.hashCode % Colors.primaries.length],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartSection(bool isArabic) {
    final income = _report!.incomeVsExpenseData['income'] ?? 0.0;
    final expense = _report!.incomeVsExpenseData['expense'] ?? 0.0;
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
          height: 250,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: Colors.green,
                      width: 25,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: expense, color: Colors.red, width: 25),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      if (value == 0)
                        return Text(
                          isArabic ? 'دخل' : 'Income',
                          style: const TextStyle(color: Colors.white70),
                        );
                      if (value == 1)
                        return Text(
                          isArabic ? 'مصروف' : 'Expense',
                          style: const TextStyle(color: Colors.white70),
                        );
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
