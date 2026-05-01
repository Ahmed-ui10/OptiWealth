import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/report_service.dart';
import '../../locale_provider.dart';

class ReportsScreen extends StatefulWidget {
  final int userId;
  const ReportsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _service = ReportService();
  Map<String, dynamic>? _report;
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
    final report = await _service.generateReport(widget.userId, start, end);
    setState(() {
      _report = {
        'categoryTotals': report.categoryTotals,
        'incomeVsExpense': report.incomeVsExpenseData,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'التقارير' : 'Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(isArabic ? 'المصروفات حسب التصنيف' : 'Expenses by Category', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  if ((_report?['categoryTotals'] ?? {}).isEmpty)
                    Center(child: Text(isArabic ? 'لا توجد بيانات' : 'No data available'))
                  else
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: (_report!['categoryTotals'] as Map<String, double>).entries.map<PieChartSectionData>((e) {
                            return PieChartSectionData(
                              value: e.value,
                              title: e.key,
                              radius: 60,
                              titleStyle: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(isArabic ? 'الدخل مقابل المصروفات' : 'Income vs Expense', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  if ((_report?['incomeVsExpense'] ?? {}).isEmpty)
                    Center(child: Text(isArabic ? 'لا توجد بيانات' : 'No data available'))
                  else
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: (_report!['incomeVsExpense']['income'] as double),
                                  color: Colors.green,
                                  width: 40,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: (_report!['incomeVsExpense']['expense'] as double),
                                  color: Colors.red,
                                  width: 40,
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  if (value == 0) return Text(isArabic ? 'دخل' : 'Income');
                                  if (value == 1) return Text(isArabic ? 'مصروف' : 'Expense');
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}