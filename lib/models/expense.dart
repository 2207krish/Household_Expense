class Expense {
  final int? id;
  final String expenseDate;
  final String category;
  final String item;
  final double amount;
  final String paymentMethod;

  Expense({
    this.id,
    required this.expenseDate,
    required this.category,
    required this.item,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseDate': expenseDate,
      'category': category,
      'item': item,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
  }
}