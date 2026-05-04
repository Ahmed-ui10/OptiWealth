import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';
import 'widgets/custom_scaffold.dart';
import 'add_edit_budget_screen.dart';

final Map<String, String> _enToArBM = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};
final Map<String, String> _arToEnBM = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

String _translateBM(String name, bool isArabic) {
  if (isArabic)
    return _enToArBM[name] ?? name;
  else
    return _arToEnBM[name] ?? name;
}

class BudgetManagementScreen extends StatefulWidget {
  final int userId;
  const BudgetManagementScreen({Key? key, required this.userId})
    : super(key: key);

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
    if (budget.budgetId == null) return;
    final isArabic = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).isArabic;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A4A),
        title: Text(
          isArabic ? 'تأكيد الحذف' : 'Confirm Delete',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف هذه الميزانية؟'
              : 'Are you sure you want to delete this budget?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Color(0xFFF5B042)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteBudget(budget.budgetId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الميزانيات' : 'Budgets',
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditBudgetScreen(userId: widget.userId),
            ),
          );
          if (result == true) _load();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF5B042),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _budgets.length,
                itemBuilder: (ctx, i) {
                  final budget = _budgets[i];
                  final originalName =
                      _categoryNames[budget.categoryId] ??
                      'Category ${budget.categoryId}';
                  final displayName = _translateBM(originalName, isArabic);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFF2A3A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: budget.spentPercentage,
                            backgroundColor: Colors.grey[800],
                            color: budget.spentPercentage >= 1.0
                                ? Colors.red
                                : const Color(0xFFF5B042),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? '${budget.spentAmount} ج.م / ${budget.budgetAmount} ج.م'
                                : '${budget.spentAmount} E.P / ${budget.budgetAmount} E.P',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditBudgetScreen(
                                    userId: widget.userId,
                                    budget: budget,
                                  ),
                                ),
                              );
                              if (result == true) _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBudget(budget),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
