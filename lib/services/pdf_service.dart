import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<pw.Document> generateMonthlyReport({
    required String month,
    required double income,
    required double budget,
    required double expenses,
    required double savings,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),

        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Text(
                "Household Expense Tracker",
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                "Monthly Expense Report",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Divider(),

              pw.SizedBox(height: 20),

              pw.Text("Month : $month"),
              pw.Text("Income : ₹ ${income.toStringAsFixed(0)}"),
              pw.Text("Budget : ₹ ${budget.toStringAsFixed(0)}"),
              pw.Text("Expenses : ₹ ${expenses.toStringAsFixed(0)}"),
              pw.Text("Savings : ₹ ${savings.toStringAsFixed(0)}"),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> previewPdf({
    required String month,
    required double income,
    required double budget,
    required double expenses,
    required double savings,
  }) async {
    final pdf = await generateMonthlyReport(
      month: month,
      income: income,
      budget: budget,
      expenses: expenses,
      savings: savings,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
