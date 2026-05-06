import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../models/budget_model.dart';
import 'widgets/custom_scaffold.dart';
import 'add_edit_budget_screen.dart';

// English to Arabic translation mapping for budget categories
final Map<String, String> _enToArBM = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};

// Arabic to English translation mapping for budget categories
final Map<String, String> _arToEnBM = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

// Helper function to translate category names based on current language
String _translateBM(String name, bool isArabic) {
  if (isArabic)
    return _enToArBM[name] ?? name;
  else
    return _arToEnBM[name] ?? name;
}

// Main screen for managing budgets - displays list of active budgets with progress indicators
class BudgetManagementScreen extends StatefulWidget {
  final int userId;
  const BudgetManagementScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  final BudgetService _service = BudgetService();
  List<Budget> _budgets = []; // List of active budgets
  Map<int, String> _categoryNames = {}; // Cache category IDs to names
  bool _loading = true; // Loading state for data fetch

  @override
  void initState() {
    super.initState();
    _load(); // Load budgets when screen initializes
  }

  // Load budgets and category names from repositories
  Future<void> _load() async {
    setState(() => _loading = true);
    final budgets = await _service.getActiveBudgets(widget.userId);
    final cats = await CategoryRepository().getAllCategories();
    setState(() {
      _budgets = budgets;
      _categoryNames = {for (var c in cats) c.categoryId: c.name}; // Build category name map
      _loading = false;
    });
  }

  // Delete a budget with confirmation dialog
  Future<void> _deleteBudget(Budget budget) async {
    if (budget.budgetId == null) return;
    
    final isArabic = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).isArabic;
    
    // Show confirmation dialog
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
              style: const TextStyle(color: Color(0xFFF5B042)), // Orange cancel button
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red), // Red delete button
            ),
          ),
        ],
      ),
    );
    
    // If confirmed, delete and reload
    if (confirm == true) {
      await _service.deleteBudget(budget.budgetId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currency = Provider.of<CurrencyProvider>(context);
    
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الميزانيات' : 'Budgets',
      showBackButton: false,
      hideMenu: false,
      // Floating action button to add new budget
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042), // Orange FAB
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditBudgetScreen(userId: widget.userId),
            ),
          );
          if (result == true) _load(); // Reload if budget was added/edited
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load, // Pull-to-refresh functionality
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
                  final remaining = budget.budgetAmount - budget.spentAmount;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFF2A3A4A), // Dark card background
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
                          // Progress bar showing spent percentage vs budget
                          LinearProgressIndicator(
                            value: budget.spentPercentage.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[800],
                            color: budget.spentPercentage >= 1.0
                                ? Colors.red // Red when exceeded
                                : const Color(0xFFF5B042), // Orange when within limit
                          ),
                          const SizedBox(height: 4),
                          // Display spent amount vs total budget
                          Text(
                            '${currency.format(budget.spentAmount, isArabic)} / ${currency.format(budget.budgetAmount, isArabic)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          // Display remaining amount (negative if exceeded)
                          Text(
                            isArabic
                                ? 'المتبقي: ${currency.format(remaining, isArabic)}'
                                : 'Remaining: ${currency.format(remaining, isArabic)}',
                            style: TextStyle(
                              color: remaining < 0
                                  ? Colors.red // Red text when over budget
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditBudgetScreen(
                                    userId: widget.userId,
                                    budget: budget, // Pass existing budget for editing
                                  ),
                                ),
                              );
                              if (result == true) _load(); // Reload after edit
                            },
                          ),
                          // Delete button
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