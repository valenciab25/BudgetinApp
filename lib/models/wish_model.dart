class WishModel {
  final int id;
  final String name;
  final double amount;
  final String dateTarget;
  final String color;
  final String imagePath;

  WishModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dateTarget,
    required this.color,
    required this.imagePath,
  });

  // Constructor dari Map (untuk query database)
  factory WishModel.fromMap(Map<String, dynamic> map) {
    return WishModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      dateTarget: map['dateTarget'],
      color: map['color'],
      imagePath: map['imagePath'],
    );
  }

  // Konversi ke Map (untuk insert/update database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dateTarget': dateTarget,
      'color': color,
      'imagePath': imagePath,
    };
  }
}