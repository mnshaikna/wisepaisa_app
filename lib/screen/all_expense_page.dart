import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/api_provider.dart';

import '../utils/utils.dart';
import 'create_expense_page.dart';

class AllExpensePage extends StatefulWidget {
  const AllExpensePage({super.key});

  @override
  State<AllExpensePage> createState() => _AllExpensePageState();
}

class _AllExpensePageState extends State<AllExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApiProvider>(
      builder: (_, api, __) {
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: Text('Expenses')),
          body:
              api.userExpenseList.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: buildCreateDataBox(
                        context,
                        "Start tracking your spending 📊\n\n➕ Add your first Expense",
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateExpensePage(group: {}),
                          ),
                        ),
                        LinearGradient(
                          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildGroupedExpenseWidgets(
                        api.userExpenseList,
                        context,
                      ),
                    ),
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateExpensePage(group: {}),
                  ),
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),

            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
