import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../repositories/category_repository.dart';
import '../../locale_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import 'widgets/custom_scaffold.dart';

// English to Arabic translation mapping for transaction categories
final Map<String, String> _enToArTx = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};

// Arabic to English translation mapping for transaction categories
final Map<String, String> _arToEnTx = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

// Helper function to translate category names based on current language
String _translateTx(String name, bool isArabic) {
  if (isArabic)
    return _enToArTx[name] ?? name;
  else
    return _arToEnTx[name] ?? name;
}

// Screen for adding a new transaction or editing an existing one
class AddEditTransactionScreen extends StatefulWidget {
  final int userId;
  final Transaction? transaction; // If provided, editing mode; otherwise creating new
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
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _amountController = TextEditingController(); // Transaction amount input
  final _descController = TextEditingController(); // Transaction description input
  bool _isIncome = true; // true = income, false = expense
  int? _categoryId; // Selected category ID
  String _paymentMethod = 'Cash'; // Payment method (Cash, Credit Card, Bank Transfer)
  List<Category> _categories = []; // List of available categories
  bool _loading = false; // Loading state for save operation
  final TransactionService _service = TransactionService();

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Fetch categories when screen initializes
    
    // If editing, populate fields with existing transaction data
    if (widget.transaction != null) {
      _isIncome = widget.transaction!.transactionType;
      _amountController.text = widget.transaction!.amount.toString();
      _descController.text = widget.transaction!.description;
      _categoryId = widget.transaction!.categoryId;
      _paymentMethod = widget.transaction!.paymentMethod;
    }
  }

  // Load all categories from repository
  Future<void> _loadCategories() async {
    final cats = await CategoryRepository().getAllCategories();
    setState(() => _categories = cats);
  }

  // Get current date/time without milliseconds for consistent storage
  DateTime _nowWithoutMillis() =>
      DateTime.now().toLocal().copyWith(millisecond: 0, microsecond: 0);

  // Save transaction (create or update)
  Future<void> _save() async {
    // Validate form and ensure category is selected
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _loading = true);
    
    // Create Transaction object with form data
    final transaction = Transaction(
      id: widget.transaction?.id ?? 0,
      userId: widget.userId,
      transactionType: _isIncome,
      amount: double.parse(_amountController.text),
      dateTime: widget.transaction?.dateTime ?? _nowWithoutMillis(), // Keep existing date or use current
      description: _descController.text,
      paymentMethod: _paymentMethod,
      categoryId: _categoryId!,
    );
    
    // Call appropriate service method (add or update)
    if (widget.transaction == null) {
      await _service.addTransaction(transaction);
    } else {
      await _service.updateTransaction(transaction);
    }
    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    // Dynamic title based on mode (add/edit) and language
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
          color: const Color(0xFF2A3A4A), // Dark card background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch toggle for Income (green) / Expense (red not shown but implied)
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
                  // Text field for amount (numeric only)
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
                        borderSide: const BorderSide(color: Color(0xFFF5B042)), // Orange highlight
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => double.tryParse(v!) != null
                        ? null
                        : (isArabic ? 'أدخل رقمًا' : 'Number required'), // Numeric validation
                  ),
                  const SizedBox(height: 12),
                  // Text field for description
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
                  // Dropdown for category selection
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    dropdownColor: const Color(0xFF2A3A4A),
                    style: const TextStyle(color: Colors.white),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.categoryId,
                            child: Text(_translateTx(c.name, isArabic)), // Translated category name
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
                        v != null ? null : (isArabic ? 'مطلوب' : 'Required'), // Required validation
                  ),
                  const SizedBox(height: 12),
                  // Dropdown for payment method
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
                  // Submit button or loading indicator
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B042), // Orange button
                            minimumSize: const Size(double.infinity, 50), // Full width button
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