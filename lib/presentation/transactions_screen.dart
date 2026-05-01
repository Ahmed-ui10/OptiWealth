import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/transaction_service.dart';
import '../../locale_provider.dart';
import '../../models/transaction_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'المعاملات' : 'Transactions')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(_transactions[i].description),
                subtitle: Text(_transactions[i].dateTime.toLocal().toString()),
                trailing: Text('${_transactions[i].transactionType ? "+" : "-"}\$${_transactions[i].amount}'),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTransactionScreen(userId: widget.userId)));
          _load();
        },
      ),
    );
  }
}