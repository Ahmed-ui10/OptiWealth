import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import 'widgets/custom_scaffold.dart';

final Map<String, String> _enToArTx = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};
final Map<String, String> _arToEnTx = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

String _translateTx(String name, bool isArabic) {
  if (isArabic)
    return _enToArTx[name] ?? name;
  else
    return _arToEnTx[name] ?? name;
}

class AddEditTransactionScreen extends StatefulWidget {
  final int userId;
  final Transaction? transaction;
  const AddEditTransactionScreen({
    Key? key,
    required this.userId,
    this.transaction,
  }) : super(key: key);

  @override
  _AddEditTransactionScreenState createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isIncome = true;
  int? _categoryId;
  String _paymentMethod = 'Cash';
  List<Category> _categories = [];
  bool _loading = false;
  final TransactionService _service = TransactionService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.transaction != null) {
      _isIncome = widget.transaction!.transactionType;
      _amountController.text = widget.transaction!.amount.toString();
      _descController.text = widget.transaction!.description;
      _categoryId = widget.transaction!.categoryId;
      _paymentMethod = widget.transaction!.paymentMethod;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryRepository().getAllCategories();
    setState(() => _categories = cats);
  }

  DateTime _nowWithoutMillis() =>
      DateTime.now().toLocal().copyWith(millisecond: 0, microsecond: 0);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _loading = true);
    final transaction = Transaction(
      id: widget.transaction?.id ?? 0,
      userId: widget.userId,
      transactionType: _isIncome,
      amount: double.parse(_amountController.text),
      dateTime: widget.transaction?.dateTime ?? _nowWithoutMillis(),
      description: _descController.text,
      paymentMethod: _paymentMethod,
      categoryId: _categoryId!,
    );
    if (widget.transaction == null) {
      await _service.addTransaction(transaction);
    } else {
      await _service.updateTransaction(transaction);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final title = isArabic
        ? (widget.transaction == null ? 'إضافة معاملة' : 'تعديل معاملة')
        : (widget.transaction == null ? 'Add Transaction' : 'Edit Transaction');

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
                  SwitchListTile(
                    title: Text(
                      isArabic ? 'دخل' : 'Income',
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: _isIncome,
                    onChanged: (v) => setState(() => _isIncome = v),
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'المبلغ' : 'Amount',
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
                        : (isArabic ? 'أدخل رقمًا' : 'Number required'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الوصف' : 'Description',
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
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    dropdownColor: const Color(0xFF2A3A4A),
                    style: const TextStyle(color: Colors.white),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.categoryId,
                            child: Text(_translateTx(c.name, isArabic)),
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
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    dropdownColor: const Color(0xFF2A3A4A),
                    style: const TextStyle(color: Colors.white),
                    items: ['Cash', 'Credit Card', 'Bank Transfer']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'طريقة الدفع' : 'Payment Method',
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
