import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../locale_provider.dart';
import '../../models/financial_goal_model.dart';
import 'add_edit_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  final int userId;
  const GoalsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _service = GoalService();
  List<FinancialGoal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final goals = await _service.getUserGoals(widget.userId);
    setState(() {
      _goals = goals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الأهداف المالية' : 'Financial Goals')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(_goals[i].goalName),
                  subtitle: LinearProgressIndicator(value: _goals[i].progress),
                  trailing: Text('\$${_goals[i].currentAmount} / \$${_goals[i].targetAmount}'),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditGoalScreen(userId: widget.userId)));
          _load();
        },
      ),
    );
  }
}