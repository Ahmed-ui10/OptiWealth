import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../models/transaction_model.dart';
import 'widgets/custom_scaffold.dart';
import 'add_edit_transaction_screen.dart';

// Screen for displaying and managing all user transactions
class TransactionsScreen extends StatefulWidget {
  final int userId;
  const TransactionsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _service = TransactionService();
  List<Transaction> _transactions = []; // List of user transactions
  bool _loading = true; // Loading state for data fetch

  @override
  void initState() {
    super.initState();
    _load(); // Load transactions when screen initializes
  }

  // Load transactions from service
  Future<void> _load() async {
    setState(() => _loading = true);
    final transactions = await _service.getUserTransactions(widget.userId);
    setState(() {
      _transactions = transactions;
      _loading = false;
    });
  }

  // Delete a transaction with confirmation dialog
  Future<void> _deleteTransaction(Transaction transaction) async {
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
              ? 'هل أنت متأكد من حذف هذه المعاملة؟'
              : 'Are you sure you want to delete this transaction?',
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
      await _service.deleteTransaction(transaction.id!);
      _load();
    }
  }

  // Format DateTime to readable string (YYYY-MM-DD HH:MM:SS)
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currency = Provider.of<CurrencyProvider>(context);
    
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'المعاملات' : 'Transactions', // Dynamic title based on language
      showBackButton: false,
      hideMenu: false,
      // Floating action button to add a new transaction
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042), // Orange FAB
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(userId: widget.userId),
            ),
          );
          if (result == true) _load(); // Reload if transaction was added
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
                itemCount: _transactions.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF2A3A4A), // Dark card background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: ListTile(
                    leading: Icon(
                      // Upward arrow for income, downward for expense
                      _transactions[i].transactionType
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: _transactions[i].transactionType
                          ? Colors.green // Green for income
                          : Colors.red, // Red for expense
                    ),
                    title: Text(
                      _transactions[i].description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _formatDateTime(_transactions[i].dateTime),
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display amount with + for income, - for expense
                        Text(
                          _transactions[i].transactionType
                              ? '+${currency.format(_transactions[i].amount, isArabic)}'
                              : '-${currency.format(_transactions[i].amount, isArabic)}',
                          style: TextStyle(
                            color: _transactions[i].transactionType
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTransactionScreen(
                                  userId: widget.userId,
                                  transaction: _transactions[i], // Pass existing transaction for editing
                                ),
                              ),
                            );
                            if (result == true) _load(); // Reload after edit
                          },
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTransaction(_transactions[i]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}