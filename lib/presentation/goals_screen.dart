import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../locale_provider.dart';
import '../../models/financial_goal_model.dart';
import 'widgets/custom_scaffold.dart';
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
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الأهداف المالية' : 'Financial Goals',
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditGoalScreen(userId: widget.userId),
            ),
          );
          _load();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF5B042),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _goals.length,
                itemBuilder: (ctx, i) {
                  final goal = _goals[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFF2A3A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        goal.goalName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: goal.progress,
                            backgroundColor: Colors.grey[800],
                            color: const Color(0xFFF5B042),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? '${goal.currentAmount} ج.م / ${goal.targetAmount} ج.م'
                                : '${goal.currentAmount} E.P / ${goal.targetAmount} E.P',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      trailing: Text(
                        goal.status,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
