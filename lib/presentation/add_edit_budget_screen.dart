import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/budget_service.dart';
import '../../locale_provider.dart';
import '../../models/budget_model.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final int userId;
  const AddEditBudgetScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddEditBudgetScreenState createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  int _threshold = 80;
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final budget = Budget(
      budgetId: 0,
      userId: widget.userId,
      category: _categoryController.text,
      budgetAmount: double.parse(_amountController.text),
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      alertThreshold: _threshold,
    );
    await BudgetService().createBudget(budget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'إضافة ميزانية' : 'Create Budget')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: isArabic ? 'التصنيف' : 'Category'),
                validator: (v) => v!.isNotEmpty ? null : (isArabic ? 'مطلوب' : 'Required'),
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
              _loading ? CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: Text(isArabic ? 'إنشاء' : 'Create')),
            ],
          ),
        ),
      ),
    );
  }
}