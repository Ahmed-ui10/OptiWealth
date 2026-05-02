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
  void initState()
  {
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

  @override
  Widget build(BuildContext context)
  {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الميزانيات' : 'Budgets')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _budgets.length,
              itemBuilder: (ctx, i)
            {
                final budget = _budgets[i];
                return Card(
                  child: ListTile(
                    title: Text(_categoryNames[budget.categoryId] ?? 'Category ${budget.categoryId}'),
                    subtitle: LinearProgressIndicator(
                      value: budget.spentPercentage,
                      color: budget.spentPercentage > 1.0 ? Colors.red : Colors.blue,
                    ),
                    trailing: Text('\$${budget.spentAmount.toStringAsFixed(2)} / \$${budget.budgetAmount}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async
        {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditBudgetScreen(userId: widget.userId)));
          _load();
        },
      ),
    );
  }
}
