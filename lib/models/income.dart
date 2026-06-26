class Income {
  final int? id;
  final String month;
  final double income;

  Income({this.id, required this.month, required this.income});

  Map<String, dynamic> toMap() {
    return {'id': id, 'month': month, 'income': income};
  }
}
