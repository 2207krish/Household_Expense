import 'models/expense.dart';
import 'database/database_helper.dart';
import 'package:flutter/material.dart';
import 'widgets/summary_card.dart';
import 'widgets/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/pdf_service.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Household Expense Tracker !!',

      theme: ThemeData(primarySwatch: Colors.green),
      home: const ExpenseScreen(),
    );
  }
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  Map<String, double> categoryTotals = {};
  double monthlyIncome = 0;
  double totalExpenses = 0;
  double monthlyBudget = 0;
  double savings = 0;
  String selectedMonth =
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

  String selectedCategory = '';
  String selectedPaymentMethod = 'UPI';
  DateTime selectedDate = DateTime.now();
  String savedItem = '';
  String savedAmount = '';
  String savedCategory = '';
  List<Expense> expenses = [];
  List<String> categories = [];
  List<Map<String, String>> months = [];
  Map<String, double> monthlyExpenseTotals = {};
  final List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
  ];
  final List<Color> barColors = [
    Color(0xFF64B5F6), // Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFD54F), // Amber
    Color(0xFF9575CD), // Purple
    Color(0xFFF06292), // Pink
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFFFB74D), // Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFFFFAB91),
  ];
  Future<void> loadExpenses() async {
    final data = await DatabaseHelper.instance.getAllExpenses();

    setState(() {
      expenses = data;
    });

    await calculateSummary();
  }

  Future<void> loadCategories() async {
    categories = await DatabaseHelper.instance.getCategories();

    if (categories.isEmpty) {
      await DatabaseHelper.instance.insertCategory('Vegetables');
      await DatabaseHelper.instance.insertCategory('Fruits');
      await DatabaseHelper.instance.insertCategory('Milk');
      await DatabaseHelper.instance.insertCategory('Groceries');
      await DatabaseHelper.instance.insertCategory('Petrol');
      await DatabaseHelper.instance.insertCategory('Medical');
      await DatabaseHelper.instance.insertCategory('Shopping');
      await DatabaseHelper.instance.insertCategory('Electricity');
      await DatabaseHelper.instance.insertCategory('Internet');
      await DatabaseHelper.instance.insertCategory('Other');

      categories = await DatabaseHelper.instance.getCategories();
    }
    categories.sort();
    debugPrint('Loaded Categories: $categories');
    if (categories.isNotEmpty && selectedCategory.isEmpty) {
      selectedCategory = categories.first;
    }

    setState(() {});
  }

  Future<void> calculateSummary() async {
    double total = 0;

    Map<String, double> totals = {};

    for (var expense in expenses) {
      final expenseMonth = expense.expenseDate.substring(0, 7);

      if (expenseMonth != selectedMonth) {
        continue;
      }

      total += expense.amount;

      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    monthlyIncome = await DatabaseHelper.instance.getCurrentMonthIncome(
      selectedMonth,
    );

    setState(() {
      totalExpenses = total;
      savings = monthlyIncome - totalExpenses;
      categoryTotals = totals;
    });
  }

  Future<void> loadMonthlyExpenseTotals() async {
    monthlyExpenseTotals = await DatabaseHelper.instance
        .getMonthlyExpenseTotals();

    if (mounted) {
      setState(() {});
    }
  }

  List<FlSpot> getMonthlySpots() {
    final entries = monthlyExpenseTotals.entries.toList();

    // Sort by month
    entries.sort((a, b) => a.key.compareTo(b.key));

    List<FlSpot> spots = [];

    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }

    return spots;
  }

  Widget buildMonthlyTrendGraph() {
    List<BarChartGroupData> bars = [];

    int index = 0;

    monthlyExpenseTotals.forEach((month, amount) {
      bars.add(
        BarChartGroupData(
          x: index,

          barRods: [
            BarChartRodData(
              toY: amount,
              width: 22,
              color: barColors[index % barColors.length],
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      );

      index++;
    });
    if (monthlyExpenseTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              "No monthly data available",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Colors.blue),

                SizedBox(width: 10),

                Text(
                  "Monthly Expense Trend",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 16,
                  maxY: monthlyExpenseTotals.values.reduce(max) * 1.2,

                  barGroups: bars,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                  ),

                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= monthlyExpenseTotals.length) {
                            return const SizedBox();
                          }

                          final month = monthlyExpenseTotals.keys.elementAt(
                            value.toInt(),
                          );

                          final monthName = [
                            "",
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "Jul",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec",
                          ];

                          final monthNo = int.parse(month.split("-")[1]);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              monthName[monthNo],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = monthlyExpenseTotals.keys.elementAt(
                          group.x,
                        );
                        final amount = rod.toY;

                        return BarTooltipItem(
                          '$month\n₹ ${amount.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    generateMonths();

    loadCategories();

    loadExpenses().then((_) async {
      await calculateSummary();
      await loadMonthlyExpenseTotals();
      await loadBudget();
    });
  }

  Future<void> addCategoryDialog() async {
    TextEditingController categoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertCategory(
                    categoryController.text.trim(),
                  );

                  await loadCategories();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveExpense() async {
    if (itemController.text.isEmpty || amountController.text.isEmpty) {
      return;
    }

    Expense expense = Expense(
      expenseDate:
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      category: selectedCategory,
      item: itemController.text,
      amount: double.parse(amountController.text),
      paymentMethod: selectedPaymentMethod,
    );

    await DatabaseHelper.instance.insertExpense(expense);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense Saved Successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    await loadExpenses();
    await calculateSummary();
    await loadMonthlyExpenseTotals();
    setState(() {
      savedCategory = selectedCategory;
      savedItem = itemController.text;
      savedAmount = amountController.text;
    });

    if (!mounted) return;

    itemController.clear();
    amountController.clear();
  }

  Future<void> editExpenseDialog(Expense expense) async {
    final itemController = TextEditingController(text: expense.item);

    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item'),
              ),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await updateExpense(
                  expense.id!,
                  itemController.text,
                  double.parse(amountController.text),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateExpense(int id, String item, double amount) async {
    await DatabaseHelper.instance.updateExpense(id, item, amount);

    await loadExpenses();

    await calculateSummary();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);

    await loadExpenses();

    await calculateSummary();
  }

  Future<void> saveIncome() async {
    if (incomeController.text.isEmpty) return;

    final currentMonth = selectedMonth;

    await DatabaseHelper.instance.saveIncome(
      currentMonth,
      double.parse(incomeController.text),
    );

    await calculateSummary();

    setState(() {});

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Income Saved')));

    incomeController.clear();
  }

  String formatDate(String dbDate) {
    final parts = dbDate.split('-');

    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  List<Expense> get filteredExpenses {
    return expenses.where((expense) {
      final expenseMonth = expense.expenseDate.substring(0, 7);
      return expenseMonth == selectedMonth;
    }).toList();
  }

  void updateDefaultDate() {
    final parts = selectedMonth.split('-');

    final selectedYear = int.parse(parts[0]);
    final selectedMonthNumber = int.parse(parts[1]);

    final today = DateTime.now();

    // Current month → today's date
    if (selectedYear == today.year && selectedMonthNumber == today.month) {
      selectedDate = today;
      return;
    }

    // Previous month → last day of selected month
    if (selectedYear < today.year ||
        (selectedYear == today.year && selectedMonthNumber < today.month)) {
      selectedDate = DateTime(selectedYear, selectedMonthNumber + 1, 0);
      return;
    }

    // Future month → first day of month
    selectedDate = DateTime(selectedYear, selectedMonthNumber, 1);
  }

  void generateMonths() {
    months.clear();

    final currentYear = DateTime.now().year;

    for (int year = currentYear - 2; year <= currentYear + 2; year++) {
      for (int month = 1; month <= 12; month++) {
        final value = '$year-${month.toString().padLeft(2, '0')}';

        const monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

        final label = '${monthNames[month - 1]} $year';

        months.add({'value': value, 'label': label});
      }
    }
  }

  Future<void> saveBudget() async {
    final prefs = await SharedPreferences.getInstance();

    monthlyBudget = double.tryParse(budgetController.text) ?? 0;

    await prefs.setDouble('budget_$selectedMonth', monthlyBudget);

    setState(() {});
  }

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();

    monthlyBudget = prefs.getDouble('budget_$selectedMonth') ?? 0;

    budgetController.text = monthlyBudget == 0
        ? ''
        : monthlyBudget.toStringAsFixed(0);

    setState(() {});
  }

  String getSelectedMonthLabel() {
    final month = months.firstWhere(
      (m) => m['value'] == selectedMonth,
      orElse: () => {'label': selectedMonth},
    );

    return month['label']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Household Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 55,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Household Expense Tracker',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Manage your household expenses efficiently',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "📅 ${getSelectedMonthLabel()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Select Month',
                  border: OutlineInputBorder(),
                ),
                items: months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month['value'],
                    child: Text(month['label']!),
                  );
                }).toList(),
                onChanged: (value) async {
                  selectedMonth = value!;

                  updateDefaultDate();

                  await loadBudget();

                  await calculateSummary();

                  setState(() {});
                },
              ),

              const SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Monthly Income',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: incomeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Income for $selectedMonth',
                          border: const OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: saveIncome,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Income"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.orange),

                          SizedBox(width: 10),

                          Text(
                            'Monthly Budget',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Budget for $selectedMonth',
                          prefixText: '₹ ',
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: saveBudget,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Budget"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Income',
                      value: '₹ ${monthlyIncome.toStringAsFixed(0)}',
                      color: Colors.green,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SummaryCard(
                      title: 'Expense',
                      value: '₹ ${totalExpenses.toStringAsFixed(0)}',
                      color: Colors.red,
                      icon: Icons.shopping_cart,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SummaryCard(
                      title: 'Savings',
                      value: '₹ ${savings.toStringAsFixed(0)}',
                      color: Colors.blue,
                      icon: Icons.savings,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await PdfService().previewPdf(
                    month: selectedMonth,
                    income: monthlyIncome,
                    budget: monthlyBudget,
                    expenses: totalExpenses,
                    savings: savings,
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export PDF"),
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.track_changes, color: Colors.deepOrange),
                          SizedBox(width: 10),
                          Text(
                            "Budget vs Actual",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      LinearProgressIndicator(
                        value: monthlyBudget == 0
                            ? 0
                            : totalExpenses / monthlyBudget,
                        minHeight: 14,
                        borderRadius: BorderRadius.circular(12),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          totalExpenses <= monthlyBudget
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Spent",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          Text(
                            "₹ ${totalExpenses.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Budget",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          Text(
                            "₹ ${monthlyBudget.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Remaining",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          Text(
                            "₹ ${(monthlyBudget - totalExpenses).toStringAsFixed(0)}",
                            style: TextStyle(
                              color: monthlyBudget >= totalExpenses
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: pickDate,
                    child: const Text('Change Date'),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: addCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),

              const SizedBox(height: 20),

              const Text(
                'Add Expense',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: itemController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Expense',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: saveExpense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildMonthlyTrendGraph(),
              const SizedBox(height: 25),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pie_chart, color: Colors.deepPurple),

                          SizedBox(width: 10),

                          Text(
                            'Expense Distribution',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      buildPieChart(categoryTotals),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bar_chart, color: Colors.orange),

                          SizedBox(width: 10),

                          Text(
                            'Category Summary',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Keep your existing Category Summary ListView here
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryTotals.length,
                        itemBuilder: (context, index) {
                          final category = categoryTotals.keys.elementAt(index);

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      Colors.primaries[index %
                                          Colors.primaries.length],
                                ),

                                title: Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                trailing: Text(
                                  '₹ ${categoryTotals[category]!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),

                              if (index != categoryTotals.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'Expense History',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.orange,
                        ),
                      ),

                      title: Text(
                        expense.item,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Text(
                        '${expense.category} • ${formatDate(expense.expenseDate)}',
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹ ${expense.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editExpenseDialog(expense);
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await deleteExpense(expense.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
