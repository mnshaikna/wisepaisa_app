import 'package:flutter/material.dart';
import 'package:wisepaise/screen/create_reminder_page.dart';

class AllReminderPage extends StatefulWidget {
  const AllReminderPage({super.key});

  @override
  State<AllReminderPage> createState() => _AllReminderPageState();
}

class _AllReminderPageState extends State<AllReminderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Expense Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CreateReminderPage()),
            ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

        child: Icon(Icons.add),
      ),
    );
  }
}
