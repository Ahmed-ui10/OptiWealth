import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';

// Abstract strategy interface for different export formats
abstract class ExportStrategy {
  Future<File> export(List<Transaction> transactions, String filePath);
}

// Concrete strategy for exporting transactions as CSV (Comma Separated Values)
class CSVExportStrategy implements ExportStrategy {
  @override
  Future<File> export(List<Transaction> transactions, String filePath) async {
    // Define header row
    List<List<dynamic>> rows = [
      ['ID', 'Type', 'Amount', 'Date', 'Description', 'Payment Method', 'Category']
    ];
    
    // Add transaction data rows
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
    
    // Convert rows to CSV string format
    String csv = const ListToCsvConverter().convert(rows);
    File file = File(filePath);
    return await file.writeAsString(csv);
  }
}

// Concrete strategy for exporting transactions as PDF document
class PDFExportStrategy implements ExportStrategy {
  @override
  Future<File> export(List<Transaction> transactions, String filePath) async {
    final pdf = pw.Document();
    
    // Create a PDF page with transaction report
    pdf.addPage(pw.Page(
      build: (context) => pw.Column(children: [
        pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
        // List each transaction with date and amount
        ...transactions.map((t) => pw.Text('${t.dateTime.toLocal()}: ${t.amount} ${t.transactionType ? "+" : "-"}')),
      ]),
    ));
    
    final file = File(filePath);
    return await file.writeAsBytes(await pdf.save());
  }
}

// Service class that uses the strategy pattern for exporting data
class ExportService {
  // Execute the selected export strategy
  Future<File> exportData(ExportStrategy strategy, List<Transaction> data, String path) {
    return strategy.export(data, path);
  }
}