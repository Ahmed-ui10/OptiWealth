import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../locale_provider.dart';
import '../../models/financial_goal_model.dart';
import 'widgets/custom_scaffold.dart';

// Screen for adding a new financial goal
class AddEditGoalScreen extends StatefulWidget {
  final int userId;
  const AddEditGoalScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _nameController = TextEditingController(); // Goal name input
  final _targetController = TextEditingController(); // Target amount input
  DateTime _deadline = DateTime.now().add(const Duration(days: 30)); // Default deadline: 30 days from now
  bool _loading = false; // Loading state for save operation

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    
    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'إضافة هدف مالي' : 'Add Financial Goal', // Dynamic title based on language
      showBackButton: true,
      hideMenu: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF2A3A4A), // Dark card background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text field for goal name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الهدف' : 'Goal Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF5B042)), // Orange highlight on focus
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v!.isNotEmpty
                        ? null
                        : (isArabic ? 'مطلوب' : 'Required'), // Required validation
                  ),
                  const SizedBox(height: 12),
                  // Text field for target amount (numeric only)
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'المبلغ المستهدف' : 'Target Amount',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF5B042)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => double.tryParse(v!) != null
                        ? null
                        : (isArabic ? 'رقم غير صالح' : 'Number required'), // Numeric validation
                  ),
                  const SizedBox(height: 12),
                  // Date picker tile for selecting deadline
                  ListTile(
                    title: Text(
                      isArabic
                          ? 'آخر موعد: ${_deadline.toLocal().toString().split(' ')[0]}'
                          : 'Deadline: ${_deadline.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFF5B042), // Orange calendar icon
                      ),
                      onPressed: () async {
                        // Show date picker dialog
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _deadline,
                          firstDate: DateTime.now(), // Cannot select past dates
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5), // Max 5 years from now
                          ),
                        );
                        if (date != null) {
                          setState(
                            () => _deadline = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit button or loading indicator
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            // Validate form before saving
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _loading = true);
                            
                            // Create FinancialGoal object
                            final goal = FinancialGoal(
                              userId: widget.userId,
                              goalName: _nameController.text,
                              targetAmount: double.parse(
                                _targetController.text,
                              ),
                              currentAmount: 0, // Starting from zero
                              deadline: _deadline,
                            );
                            
                            // Save goal via service
                            await GoalService().addGoal(goal);
                            
                            Navigator.pop(context, true); // Return true to indicate success
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B042), // Orange button
                            minimumSize: const Size(double.infinity, 50), // Full width button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'حفظ' : 'Save',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}