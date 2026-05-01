import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final int userId;
  const AddEditTransactionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddEditTransactionScreenState createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isIncome = true;
  String _categoryId = '';
  String _paymentMethod = 'Cash';
  List<Category> _categories = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = CategoryRepository();
    final cats = await repo.getAllCategories();
    setState(() => _categories = cats);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final transaction = Transaction(
      id: 0,
      userId: widget.userId,
      transactionType: _isIncome,
      amount: double.parse(_amountController.text),
      dateTime: DateTime.now(),
      description: _descController.text,
      paymentMethod: _paymentMethod,
      categoryId: _categoryId,
    );
    await TransactionService().addTransaction(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'إضافة معاملة' : 'Add Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(isArabic ? 'دخل' : 'Income'),
                value: _isIncome,
                onChanged: (v) => setState(() => _isIncome = v),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isArabic ? 'المبلغ' : 'Amount'),
                validator: (v) => double.tryParse(v!) != null ? null : (isArabic ? 'أدخل رقماً' : 'Number required'),
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: isArabic ? 'الوصف' : 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: _categoryId.isEmpty ? null : _categoryId,
                items: _categories.map((c) => DropdownMenuItem(value: c.categoryId.toString(), child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _categoryId = val!),
                decoration: InputDecoration(labelText: isArabic ? 'التصنيف' : 'Category'),
                validator: (v) => v != null ? null : (isArabic ? 'مطلوب' : 'Required'),
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: ['Cash', 'Credit Card', 'Bank Transfer']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              SizedBox(height: 20),
              _loading ? CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: Text(isArabic ? 'حفظ' : 'Save')),
            ],
          ),
        ),
      ),
    );
  }
}