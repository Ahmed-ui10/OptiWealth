import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
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
  Map<int, String> _categoryNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final budgets = await _service.getActiveBudgets(widget.userId);
    final cats = await CategoryRepository().getAllCategories();
    setState(() {
      _budgets = budgets;
      _categoryNames = {for (var c in cats) c.categoryId: c.name};
      _loading = false;
    });
  }

  Future<void> _deleteBudget(Budget budget) async {
    final isArabic = Provider.of<LocaleProvider>(context, listen: false).isArabic;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(isArabic ? 'هل أنت متأكد من حذف هذه الميزانية؟' : 'Are you sure you want to delete this budget?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isArabic ? 'حذف' : 'Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteBudget(budget.budgetId);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الميزانيات' : 'Budgets')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _budgets.length,
              itemBuilder: (ctx, i) {
                final budget = _budgets[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(_categoryNames[budget.categoryId] ?? 'Category ${budget.categoryId}'),
                    subtitle: LinearProgressIndicator(
                      value: budget.spentPercentage,
                      backgroundColor: Colors.grey[300],
                      color: budget.spentPercentage >= 1.0 ? Colors.red : Colors.blue,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${budget.spentAmount}/${budget.budgetAmount}'),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddEditBudgetScreen(userId: widget.userId, budget: budget)),
                            );
                            if (result == true) _load();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBudget(budget),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditBudgetScreen(userId: widget.userId)),
          );
          if (result == true) _load();
        },
      ),
    );
  }
}