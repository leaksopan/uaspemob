class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String? description;
  final String? imagePath;
  final DateTime date;
  final int userId;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.description,
    this.imagePath,
    required this.date,
    required this.userId,
  });

  // Convert Expense to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
      'image_path': imagePath,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      description: map['description'],
      imagePath: map['image_path'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
    );
  }

  // Create a copy of Expense with updated fields
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? description,
    String? imagePath,
    DateTime? date,
    int? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }
}
