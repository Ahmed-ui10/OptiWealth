import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../locale_provider.dart';
import '../../models/financial_goal_model.dart';

class AddEditGoalScreen extends StatefulWidget {
  final int userId;
  const AddEditGoalScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline = DateTime.now().add(Duration(days: 30));
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'إضافة هدف' : 'Add Goal')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: isArabic ? 'اسم الهدف' : 'Goal Name'),
                validator: (v) => v!.isNotEmpty ? null : (isArabic ? 'مطلوب' : 'Required'),
              ),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isArabic ? 'المبلغ المستهدف' : 'Target Amount'),
                validator: (v) => double.tryParse(v!) != null ? null : (isArabic ? 'رقم غير صالح' : 'Number required'),
              ),
              ListTile(
                title: Text(isArabic ? 'آخر موعد: ${_deadline.toLocal()}' : 'Deadline: ${_deadline.toLocal()}'),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) setState(() => _deadline = date);
                  },
                ),
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);
                        final goal = FinancialGoal(
                          id: 0,
                          userId: widget.userId,
                          goalName: _nameController.text,
                          targetAmount: double.parse(_targetController.text),
                          currentAmount: 0,
                          deadline: _deadline,
                        );
                        await GoalService().addGoal(goal);
                        Navigator.pop(context);
                      },
                      child: Text(isArabic ? 'حفظ' : 'Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}