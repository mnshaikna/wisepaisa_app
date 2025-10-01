import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/api_provider.dart';
import 'package:wisepaise/screen/create_reminder_page.dart';

import '../utils/dialog_utils.dart';
import '../utils/toast.dart';
import '../utils/utils.dart';

class AllReminderPage extends StatefulWidget {
  const AllReminderPage({super.key});

  @override
  State<AllReminderPage> createState() => _AllReminderPageState();
}

class _AllReminderPageState extends State<AllReminderPage> {
  List<Map<String, dynamic>> getActiveReminders(ApiProvider api) {
    return api.expenseReminderList.where((rem) {
      return DateTime.parse(rem['reminderDate']).isAfter(DateTime.now()) &&
          rem['reminderIsActive'] == true;
    }).toList();
  }

  List<Map<String, dynamic>> getInactiveReminders(ApiProvider api) {
    return api.expenseReminderList.where((rem) {
      return !(DateTime.parse(rem['reminderDate']).isAfter(DateTime.now()) &&
          rem['reminderIsActive'] == true);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiProvider>(
      builder: (_, api, __) {
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: Text('Expense Reminders')),
          floatingActionButton: FloatingActionButton(
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateReminderPage()),
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              physics: BouncingScrollPhysics(),

              children: [
                getActiveReminders(api).isEmpty
                    ? SizedBox.shrink()
                    : Text(
                      'Active Reminders',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.5,
                      ),
                    ),
                SizedBox(height: 10.0),
                getActiveReminders(api).isEmpty
                    ? SizedBox.shrink()
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: getActiveReminders(api).length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> thisRem = getActiveReminders(
                          api,
                        ).elementAt(index);
                        return buildReminderCard(thisRem);
                      },
                    ),
                SizedBox(height: 10.0),
                getInactiveReminders(api).isEmpty
                    ? SizedBox.shrink()
                    : Text(
                      'Inactive/Expired Reminders',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.5,
                      ),
                    ),
                SizedBox(height: 10.0),
                getInactiveReminders(api).isEmpty
                    ? SizedBox.shrink()
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: getInactiveReminders(api).length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> thisRem = getInactiveReminders(
                          api,
                        ).elementAt(index);
                        return buildReminderCard(thisRem);
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildReminderCard(Map<String, dynamic> reminder) {
    final String title = (reminder['reminderName'] ?? '').toString();
    final String description =
        (reminder['reminderDescription'] ?? '').toString();
    final String date = (reminder['reminderDate'] ?? '').toString();
    final String amount = (reminder['reminderAmount'] ?? '0').toString();
    final String amountType =
        (reminder['reminderAmountType'] ?? 'expense').toString();
    final bool isRecurring =
        reminder['reminderIsRecurring'] == true ||
        reminder['reminderIsRecurring'] == 1;
    final bool isActive =
        reminder['reminderIsActive'] == true ||
        reminder['reminderIsActive'] == 1;

    final bool isExpense = amountType.toLowerCase() == 'expense';
    final Color accent = isExpense ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: ValueKey(reminder['reminderId']),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 10.0),
              Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          final shouldDelete = await DialogUtils.showGenericDialog(
            context: context,
            title: DialogUtils.titleText('Delete Reminder?'),
            message: const Text(
              'Are you sure you want to delete this reminder?',
            ),
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
            onCancel: () => Navigator.of(context).pop(false),
            showCancel: true,
            cancelText: 'Cancel',
            confirmText: 'Delete',
            confirmColor: Colors.red,
          );
          return shouldDelete ?? false;
        },

        onDismissed: (direction) async {
          ApiProvider api = Provider.of<ApiProvider>(context, listen: false);
          Navigator.of(context).pop();
          api.expenseReminderList.removeWhere(
            (rem) => rem['reminderId'] == reminder['reminderId'],
          );
          setState(() {
            if (DateTime.parse(
                  reminder['reminderDate'],
                ).isAfter(DateTime.now()) &&
                reminder['reminderIsActive']) {
              getActiveReminders(api).removeWhere(
                (element) => element['reminderId'] == reminder['reminderId'],
              );
            } else {
              getInactiveReminders(api).removeWhere(
                (element) => element['reminderId'] == reminder['reminderId'],
              );
            }
          });
          await api.deleteReminder(context, reminder['reminderId']).then((
            Response res,
          ) {
            Toasts.show(
              context,
              'Reminder "${reminder['reminderName']}" removed',
              type: ToastType.info,
            );
          });
        },

        child: ListTile(
          onTap: () {
            DialogUtils.showGenericDialog(
              context: context,
              title: DialogUtils.titleText(title),
              message: Container(
                width: 350,
                height: 150,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors:
                            Theme.of(context).brightness == Brightness.dark
                                ? [
                                  const Color(0xFF232526),
                                  const Color(0xFF414345),
                                ]
                                : [
                                  const Color(0xFF2193b0),
                                  const Color(0xFF6dd5ed),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                FontAwesomeIcons.userClock,
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isEmpty ? 'Untitled Reminder' : title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        isExpense
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      Expanded(
                                        child: Text(
                                          formatCurrency(
                                            double.tryParse(amount) ?? 0,
                                            context,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event, size: 14, color: accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  width: 0.15,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black54
                                          : Colors.white54,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isRecurring
                                        ? Icons.repeat
                                        : Icons.remove_red_eye_outlined,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRecurring ? 'Recurring' : 'One-time',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      //color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.15,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black54
                                          : Colors.white54,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.check_circle_outline
                                        : Icons.update_disabled,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActive ? 'Active' : 'Disabled',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.15,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black54
                                          : Colors.white54,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isExpense ? Icons.remove : Icons.add,
                                    size: 14,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isExpense ? 'Expense' : 'Income',
                                    style: TextStyle(
                                      fontSize: 12,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              showCancel: true,
              onConfirm: () {
                ApiProvider api = Provider.of<ApiProvider>(
                  context,
                  listen: false,
                );
                reminder['reminderIsActive'] = isActive ? false : true;
                api.updateReminder(context, reminder).then((Response resp) {
                  debugPrint(resp.statusCode.toString());
                  if (resp.statusCode == 200) {
                    debugPrint('resp.data:::${resp.data}');
                    Toasts.show(
                      context,
                      isActive
                          ? 'Reminder marked complete'
                          : 'Reminder enabled',
                      type: ToastType.success,
                    );
                    api.expenseReminderList.removeWhere(
                      (element) =>
                          element['reminderId'] == reminder['reminderId'],
                    );
                    api.expenseReminderList.add(resp.data);
                    api.updateRemindersList(api.expenseReminderList);
                    setState(() {
                      debugPrint('active remove:::${reminder['reminderId']}');
                      debugPrint('active block${reminder['reminderIsActive']}');
                      getActiveReminders(api).removeWhere(
                        (element) =>
                            element['reminderId'] == reminder['reminderId'],
                      );
                      getInactiveReminders(api).add(resp.data);
                      debugPrint(
                        'activeReminderList.length::${getActiveReminders(api).length}',
                      );
                      debugPrint(
                        'inactiveReminderList.length::${getInactiveReminders(api).length}',
                      );
                    });
                  }
                  Navigator.pop(context);
                });
              },
              confirmText: isActive ? 'Complete' : 'Enable',
              confirmColor: Colors.green,
              cancelText: 'Cancel',
              onCancel: () => Navigator.pop(context),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black54
                      : Colors.white54,
              width: 0.25,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),

          minTileHeight: 90.0,
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Icon(FontAwesomeIcons.userClock, color: accent, size: 20),
          ),
          title: Text(
            title.isEmpty ? 'Untitled Reminder' : title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              //color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.5,
                  ),
                  decoration: BoxDecoration(
                    // color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white54,
                      width: 0.15,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          // color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white54,
                      width: 0.15,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecurring
                            ? FontAwesomeIcons.repeat
                            : FontAwesomeIcons.one,
                        size: 12,
                        color: accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRecurring ? 'Recurring' : 'One-time',
                        style: const TextStyle(
                          fontSize: 11,
                          // color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                size: 14,
                color: isExpense ? Colors.red : Colors.green,
              ),
              Text(
                formatCurrency(double.tryParse(amount) ?? 0, context),
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
