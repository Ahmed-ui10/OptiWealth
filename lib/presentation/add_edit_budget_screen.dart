import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final int userId;
  final Budget? budget;
  const AddEditBudgetScreen({Key? key, required this.userId, this.budget}) : super(key: key);

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final budget = Budget(
      budgetId: widget.budget?.budgetId ?? 0,
      userId: widget.userId,
      categoryId: _categoryId!,
      budgetAmount: double.parse(_amountController.text),
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      alertThreshold: _threshold,
      spentAmount: widget.budget?.spentAmount ?? 0.0,
      budgetStatus: widget.budget?.budgetStatus ?? 'On Track',
    );
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
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? (widget.budget == null ? 'إضافة ميزانية' : 'تعديل ميزانية') : (widget.budget == null ? 'Create Budget' : 'Edit Budget'))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: _categories.map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                decoration: InputDecoration(labelText: isArabic ? 'التصنيف' : 'Category'),
                validator: (v) => v != null ? null : (isArabic ? 'مطلوب' : 'Required'),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isArabic ? 'قيمة الميزانية' : 'Budget Amount'),
                validator: (v) => double.tryParse(v!) != null ? null : (isArabic ? 'رقم غير صالح' : 'Number required'),
              ),
              Slider(
                value: _threshold.toDouble(),
                min: 50,
                max: 100,
                divisions: 10,
                label: '$_threshold%',
                onChanged: (v) => setState(() => _threshold = v.toInt()),
              ),
              Text(isArabic ? 'تنبيه عند $_threshold%' : 'Alert at $_threshold%'),
              SizedBox(height: 20),
              _loading ? CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: Text(isArabic ? 'حفظ' : 'Save')),
            ],
          ),
        ),
      ),
    );
  }
}