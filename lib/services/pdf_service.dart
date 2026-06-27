import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/expense.dart';

class PdfService {
  Future<pw.Document> generateMonthlyReport({
    required String month,
    required double income,
    required double budget,
    required double expenses,
    required double savings,
    required Map<String, double> categoryTotals,
    required List<Expense> expenseList,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),

        build: (context) => [
          pw.Text(
            "Household Expense Tracker",
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            "Monthly Expense Report",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.Divider(),

          pw.SizedBox(height: 20),

          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Month"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(month),
                  ),
                ],
              ),

              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Income"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("₹ ${income.toStringAsFixed(0)}"),
                  ),
                ],
              ),

              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Budget"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("₹ ${budget.toStringAsFixed(0)}"),
                  ),
                ],
              ),

              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Expenses"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("₹ ${expenses.toStringAsFixed(0)}"),
                  ),
                ],
              ),

              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Savings"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("₹ ${savings.toStringAsFixed(0)}"),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 25),

          pw.Text(
            "Category Summary",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "Category",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "Amount",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),

              ...categoryTotals.entries.map(
                (entry) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(entry.key),
                    ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("₹ ${entry.value.toStringAsFixed(0)}"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 25),

          pw.Text(
            "Expense History",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(),

            children: [
              pw.TableRow(
                children: [
                  headerCell("Date"),
                  headerCell("Item"),
                  headerCell("Category"),
                  headerCell("Amount"),
                ],
              ),

              ...expenseList.map((expense) {
                return pw.TableRow(
                  children: [
                    tableCell(expense.expenseDate.toString()),
                    tableCell(expense.item.toString()),
                    tableCell(expense.category.toString()),
                    tableCell(expense.amount.toStringAsFixed(0)),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
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
    required Map<String, double> categoryTotals,
    required List<Expense> expenseList,
  }) async {
    final pdf = await generateMonthlyReport(
      month: month,
      income: income,
      budget: budget,
      expenses: expenses,
      savings: savings,
      categoryTotals: categoryTotals,
      expenseList: expenseList,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text),
    );
  }
}
