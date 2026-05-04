import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
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

String _translate(String name, bool isArabic) {
  if (isArabic)
    return _enToAr[name] ?? name;
  else
    return _arToEn[name] ?? name;
}

class AddEditBudgetScreen extends StatefulWidget {
  final int userId;
  final Budget? budget;
  const AddEditBudgetScreen({Key? key, required this.userId, this.budget})
    : super(key: key);

  @override
  _AddEditBudgetScreenState createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _categoryId;
  List<Category> _categories = [];
  int _threshold = 80;
  bool _loading = false;
  final TransactionRepository _transactionRepo = TransactionRepository();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.budgetAmount.toString();
      _categoryId = widget.budget!.categoryId;
      _threshold = widget.budget!.alertThreshold;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryRepository().getAllCategories();
    setState(() => _categories = cats);
  }

  DateTime _startOfMonth(DateTime now) => DateTime(now.year, now.month, 1);
  DateTime _endOfMonth(DateTime now) =>
      DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

  Future<double> _calculateExistingSpentAmount(
    int userId,
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _transactionRepo.getTransactionsByUser(
      userId,
      categoryId: categoryId,
      startDate: start,
      endDate: end,
    );
    double net = 0.0;
    for (var tx in transactions) {
      if (!tx.transactionType) {
        net += tx.amount;
      } else {
        net -= tx.amount;
      }
    }
    return net;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final startDate = _startOfMonth(now);
    final endDate = _endOfMonth(now);

    double initialSpent = widget.budget?.spentAmount ?? 0.0;
    if (widget.budget == null) {
      initialSpent = await _calculateExistingSpentAmount(
        widget.userId,
        _categoryId!,
        startDate,
        endDate,
      );
    }

    final budget = Budget(
      budgetId: widget.budget?.budgetId,
      userId: widget.userId,
      categoryId: _categoryId!,
      budgetAmount: double.parse(_amountController.text),
      startDate: startDate,
      endDate: endDate,
      alertThreshold: _threshold,
      spentAmount: initialSpent,
      budgetStatus: widget.budget?.budgetStatus ?? 'On Track',
    );
    if (budget.spentAmount >= budget.budgetAmount) {
      budget.budgetStatus = 'Exceeded';
    } else if (budget.spentAmount >=
        budget.budgetAmount * (budget.alertThreshold / 100)) {
      budget.budgetStatus = 'Near Limit';
    } else {
      budget.budgetStatus = 'On Track';
    }

    if (widget.budget == null) {
      await BudgetService().createBudget(budget);
    } else {
      await BudgetService().updateBudget(budget);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final title = isArabic
        ? (widget.budget == null ? 'إضافة ميزانية' : 'تعديل ميزانية')
        : (widget.budget == null ? 'Create Budget' : 'Edit Budget');

    return CustomScaffold(
      userId: widget.userId,
      title: title,
      showBackButton: true,
      hideMenu: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF2A3A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    dropdownColor: const Color(0xFF2A3A4A),
                    style: const TextStyle(color: Colors.white),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.categoryId,
                            child: Text(_translate(c.name, isArabic)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _categoryId = val),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'التصنيف' : 'Category',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF5B042)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v != null ? null : (isArabic ? 'مطلوب' : 'Required'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'قيمة الميزانية' : 'Budget Amount',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF5B042)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => double.tryParse(v!) != null
                        ? null
                        : (isArabic ? 'رقم غير صالح' : 'Number required'),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _threshold.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '$_threshold%',
                    onChanged: (v) => setState(() => _threshold = v.toInt()),
                  ),
                  Text(
                    isArabic
                        ? 'تنبيه عند $_threshold%'
                        : 'Alert at $_threshold%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B042),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'حفظ' : 'Save',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
