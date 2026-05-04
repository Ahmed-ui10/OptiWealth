import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../locale_provider.dart';
import '../../models/transaction_model.dart';
import 'widgets/custom_scaffold.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final int userId;
  const TransactionsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _service = TransactionService();
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final transactions = await _service.getUserTransactions(widget.userId);
    setState(() {
      _transactions = transactions;
      _loading = false;
    });
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
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
              ? 'هل أنت متأكد من حذف هذه المعاملة؟'
              : 'Are you sure you want to delete this transaction?',
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
      await _service.deleteTransaction(transaction.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'المعاملات' : 'Transactions',
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(userId: widget.userId),
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
                itemCount: _transactions.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF2A3A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _transactions[i].transactionType
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: _transactions[i].transactionType
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      _transactions[i].description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _transactions[i].dateTime.toLocal().toString(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _transactions[i].transactionType
                              ? '+${_transactions[i].amount}'
                              : '-${_transactions[i].amount}',
                          style: TextStyle(
                            color: _transactions[i].transactionType
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTransactionScreen(
                                  userId: widget.userId,
                                  transaction: _transactions[i],
                                ),
                              ),
                            );
                            if (result == true) _load();
                          },
                        ),
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
