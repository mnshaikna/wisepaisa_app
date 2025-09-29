import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/api_provider.dart';

import 'create_expense_group_page.dart';
import 'create_expense_page.dart';
import 'create_reminder_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

class MyDashboardPage extends StatefulWidget {
  const MyDashboardPage({super.key});

  @override
  State<MyDashboardPage> createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<MyDashboardPage> {
  int _selectedIndex = 0;

  // Pages are created once and kept alive
  final List<Widget> _pages = const [DashboardPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    // Get the current theme's brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on the theme
    final navBarColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final navBarShadowColor = isDarkMode ? Colors.transparent : Colors.grey;
    final speedDialBgColor =
        isDarkMode ? Colors.deepPurple.shade700 : Colors.white;
    final speedDialIconColor = isDarkMode ? Colors.white : Colors.black;

    return Consumer<ApiProvider>(
      builder: (_, api, __) {
        return Scaffold(
          floatingActionButton:
              api.isTimedOut
                  ? SizedBox.shrink()
                  : SpeedDial(
                    switchLabelPosition: true,
                    animationDuration: const Duration(milliseconds: 250),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    icon: Icons.add,
                    iconTheme: IconThemeData(
                      size: 25.0,
                      color: speedDialIconColor,
                    ),
                    backgroundColor: speedDialBgColor,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.4,
                    children: [
                      SpeedDialChild(
                        child: Icon(
                          FontAwesomeIcons.moneyBillTransfer,
                          size: 20.0,
                          color: speedDialIconColor,
                        ),
                        label: 'Add Expenses',
                        labelBackgroundColor: speedDialBgColor,
                        labelStyle: TextStyle(color: speedDialIconColor),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CreateExpensePage(group: const {}),
                              ),
                            ),
                      ),
                      SpeedDialChild(
                        child: Icon(
                          Icons.groups,
                          size: 27.5,
                          color: speedDialIconColor,
                        ),
                        label: 'Create Expense Group',
                        labelBackgroundColor: speedDialBgColor,
                        labelStyle: TextStyle(color: speedDialIconColor),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const CreateExpenseGroupPage(),
                              ),
                            ),
                      ),
                      SpeedDialChild(
                        child: Icon(
                          FontAwesomeIcons.userClock,
                          size: 20.0,
                          color: speedDialIconColor,
                        ),
                        label: 'Add Expense Reminder',
                        labelBackgroundColor: speedDialBgColor,
                        labelStyle: TextStyle(color: speedDialIconColor),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const CreateReminderPage(),
                              ),
                            ),
                      ),
                    ],
                  ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

          body: IndexedStack(index: _selectedIndex, children: _pages),

          bottomNavigationBar: BottomAppBar(
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            color: navBarColor,
            elevation: 8,
            shadowColor: navBarShadowColor,
            height: 65.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home, label: "Home", index: 0),
                  _buildNavItem(icon: Icons.person, label: "Profile", index: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    // Use theme colors for the nav bar items
    final selectedColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.deepPurple.shade300
            : Colors.deepPurple;
    final unselectedColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade600
            : Colors.grey;

    final color = isSelected ? selectedColor : unselectedColor;
    final double iconSize = isSelected ? 30.0 : 25.0;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(height: 4),
          Visibility(
            visible: isSelected,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.0,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
