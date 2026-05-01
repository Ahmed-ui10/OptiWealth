import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';

abstract class ExportStrategy {
  Future<File> export(List<Transaction> transactions, String filePath);
}

class CSVExportStrategy implements ExportStrategy {
  @override
  Future<File> export(List<Transaction> transactions, String filePath) async {
    List<List<dynamic>> rows = [
      ['ID', 'Type', 'Amount', 'Date', 'Description', 'Payment Method', 'Category']
    ];
    for (var t in transactions) {
      rows.add([
        t.id,
        t.transactionType ? 'Income' : 'Expense',
        t.amount,
        t.dateTime.toIso8601String(),
        t.description,
        t.paymentMethod,
        t.categoryId,
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    File file = File(filePath);
    return await file.writeAsString(csv);
  }
}

class PDFExportStrategy implements ExportStrategy {
  @override
  Future<File> export(List<Transaction> transactions, String filePath) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (context) => pw.Column(children: [
        pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
        ...transactions.map((t) => pw.Text('${t.dateTime.toLocal()}: ${t.amount} ${t.transactionType ? "+" : "-"}')),
      ]),
    ));
    final file = File(filePath);
    return await file.writeAsBytes(await pdf.save());
  }
}

class ExportService {
  Future<File> exportData(ExportStrategy strategy, List<Transaction> data, String path) {
    return strategy.export(data, path);
  }
}