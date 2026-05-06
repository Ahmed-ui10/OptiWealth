import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../models/financial_goal_model.dart';
import 'widgets/custom_scaffold.dart';
import 'add_edit_goal_screen.dart';

// Screen for displaying and managing financial goals
class GoalsScreen extends StatefulWidget {
  final int userId;
  const GoalsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _service = GoalService();
  List<FinancialGoal> _goals = []; // List of user's financial goals
  bool _loading = true; // Loading state for data fetch

  @override
  void initState() {
    super.initState();
    _load(); // Load goals when screen initializes
  }

  // Load goals from service
  Future<void> _load() async {
    setState(() => _loading = true);
    final goals = await _service.getUserGoals(widget.userId);
    setState(() {
      _goals = goals;
      _loading = false;
    });
  }

  // Format date to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currency = Provider.of<CurrencyProvider>(context);
    
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الأهداف المالية' : 'Financial Goals', // Dynamic title based on language
      showBackButton: false,
      hideMenu: false,
      // Floating action button to add a new goal
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5B042), // Orange FAB
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditGoalScreen(userId: widget.userId),
            ),
          );
          if (result == true) _load(); // Reload if goal was added
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load, // Pull-to-refresh functionality
              color: const Color(0xFFF5B042),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _goals.length,
                itemBuilder: (ctx, i) {
                  final goal = _goals[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFF2A3A4A), // Dark card background
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
                          // Progress bar showing current amount vs target
                          LinearProgressIndicator(
                            value: goal.progress, // Should be between 0.0 and 1.0
                            backgroundColor: Colors.grey[800],
                            color: const Color(0xFFF5B042), // Orange progress bar
                          ),
                          const SizedBox(height: 4),
                          // Display current amount / target amount
                          Text(
                            '${currency.format(goal.currentAmount, isArabic)} / ${currency.format(goal.targetAmount, isArabic)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          // Display deadline date
                          Text(
                            '${isArabic ? 'آخر موعد' : 'Deadline'}: ${_formatDate(goal.deadline)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        goal.status, // Goal status (e.g., "Active", "Achieved", "Failed")
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