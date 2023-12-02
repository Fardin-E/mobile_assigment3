class MealPlan {
  int id;
  int foodId;
  String date;
  String foodName;
  int foodCalories;

  MealPlan({
    required this.id,
    required this.foodId,
    required this.date,
    required this.foodName,
    required this.foodCalories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodId,
      'date': date,
      'food_name': foodName,
      'food_calories': foodCalories,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      foodId: map['food_id'],
      date: map['date'],
      foodName: map['food_name'],
      foodCalories: map['food_calories'],
    );
  }
}