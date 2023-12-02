import 'package:assignment3/models/database_helper.dart';
import 'package:assignment3/models/meal_planner.dart';
import 'package:assignment3/pages/edit_meal_plan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assignment3/pages/add_meal_plan.dart';

void main() {
  runApp(FlutterCaloriesCalculator());
}

class FlutterCaloriesCalculator extends StatelessWidget {
  // setup main app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MealPlanPage(),
    );
  }
}

// Create the MealPlan page
class MealPlanPage extends StatefulWidget {
  @override
  _MealPlanPageState createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<MealPlan> mealPlan = [];

  final DatabaseHelper dbHelper = DatabaseHelper();

  // Fetch a meal plan given a certain date string
  Future<void> fetchMealPlan(String date) async {
    List<Map<String, dynamic>> plans = await dbHelper.getMealPlanByDate(date);

    // Parse the list and update the state variable
    List<MealPlan> mealPlansList =
    plans.map((map) => MealPlan.fromMap(map)).toList();
    setState(() {
      mealPlan = mealPlansList;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMealPlan(selectedDate);
  }

  // Configure the date picker and fetch the meal plan for that particular date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      fetchMealPlan(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasMealPlan = mealPlan.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDate),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: !hasMealPlan
          ? _buildNoMealPlanLayout(context)
          : _buildMealPlanList(),
      floatingActionButton: hasMealPlan
          ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMealPlan(
                selectedDate: selectedDate,
                plans: mealPlan,
              ),
            ),
          );

          if (result != null && result == true) {
            fetchMealPlan(selectedDate);
          }
        },
        child: const Icon(Icons.edit),
      )
          : FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealPlan(
                selectedDate: selectedDate,
              ),
            ),
          );

          if (result != null && result == true) {
            fetchMealPlan(selectedDate);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
      hasMealPlan ? FloatingActionButtonLocation.endFloat : null,
    );
  }

  Widget _buildNoMealPlanLayout(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No meal plan available for this date.'),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMealPlanList() {
    return ListView.builder(
      itemCount: mealPlan.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(mealPlan[index].foodName),
            subtitle: Text('Calories: ${mealPlan[index].foodCalories}'),
          ),
        );
      },
    );
  }
}
