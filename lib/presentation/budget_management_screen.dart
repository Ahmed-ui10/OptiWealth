import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';
import 'add_edit_budget_screen.dart';

class BudgetManagementScreen extends StatefulWidget {
  final int userId;
  const BudgetManagementScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  final BudgetService _service = BudgetService();
  List<Budget> _budgets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final budgets = await _service.getActiveBudgets(widget.userId);
    setState(() {
      _budgets = budgets;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الميزانيات' : 'Budgets')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _budgets.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(_budgets[i].category),
                  subtitle: LinearProgressIndicator(value: _budgets[i].spentPercentage),
                  trailing: Text('\$${_budgets[i].spentAmount} / \$${_budgets[i].budgetAmount}'),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditBudgetScreen(userId: widget.userId)));
          _load();
        },
      ),
    );
  }
}