import 'package:flutter/material.dart';
import 'package:assignment3/models/database_helper.dart';
import 'package:assignment3/models/database_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddMealPlan extends StatefulWidget {
  final String selectedDate;

  AddMealPlan({required this.selectedDate});

  @override
  _AddMealPlanState createState() => _AddMealPlanState();
}

class _AddMealPlanState extends State<AddMealPlan> {
  late DatabaseHelper databaseHelper;
  List<Food> foods = [];
  List<Food> selectedFoods = [];
  int totalCalories = 0;
  int targetCalories = 1000;

  List<MultiSelectItem<Food>> multiSelectFoods = [];

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    loadFoods();
  }

  // get all the food items to populate the multiselect
  Future<void> loadFoods() async {
    List<Food> fetchedFoods = await databaseHelper.getAllFoods();

    setState(() {
      foods = fetchedFoods;
      multiSelectFoods = fetchedFoods
          .map((food) => MultiSelectItem<Food>(
        food,
        food.name,
      ))
          .toList();
    });
  }

  // function to update the total calories
  void updateTotalCalories() {
    int sum = 0;
    for (var food in selectedFoods) {
      sum += food.calories;
    }
    setState(() {
      totalCalories = sum;
    });
  }

  // function to check to see if the calories exceed the set amount
  // if it does then show a toast
  void checkCaloriesExceeded() {
    if (totalCalories > targetCalories) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("EXCEEDED CALORIES"),
      ));
    }
  }

  // function to save the meal plan
  void saveMealPlan() async {
    if (totalCalories <= targetCalories) {
      for (var food in selectedFoods) {
        await databaseHelper.createMealPlan(food.id, widget.selectedDate);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal plan saved!'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Selected Date: ${widget.selectedDate}'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Calories',
                  hintText: 'Enter target calories',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: targetCalories.toString()),
                onChanged: (value) {
                  setState(() {
                    targetCalories = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            MultiSelectDialogField(
              items: multiSelectFoods,
              initialValue: selectedFoods,
              onConfirm: (values) {
                selectedFoods = values.cast<Food>();
                updateTotalCalories();
                checkCaloriesExceeded();
                setState(() {
                  multiSelectFoods.clear(); // Clear the multiSelectFoods list
                });
              },
              title: const Text('Select Foods'),
              selectedItemsTextStyle: const TextStyle(color: Colors.blue),
              buttonText: const Text('Select Foods'),
            ),
            const SizedBox(height: 10),
            Text('Total Calories: $totalCalories'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFoods.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      setState(() {
                        selectedFoods.removeAt(index);
                        updateTotalCalories();
                        checkCaloriesExceeded();
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(selectedFoods[index].name),
                        subtitle:
                        Text('Calories: ${selectedFoods[index].calories}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: totalCalories > targetCalories || selectedFoods.isEmpty
                  ? null
                  : saveMealPlan,
              backgroundColor:
              totalCalories > targetCalories || selectedFoods.isEmpty
                  ? Colors.grey
                  : null,
              child: const Icon(Icons.save),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
