import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/providers/api_provider.dart';
import 'package:wisepaise/providers/auth_provider.dart';
import 'package:wisepaise/screen/create_expense_page.dart';

import '../models/group_model.dart';
import '../models/type_model.dart';
import '../utils/constants.dart';
import '../utils/dialog_utils.dart';
import '../utils/expense_pie_chart.dart';
import '../utils/toast.dart';
import '../utils/utils.dart';

class ExpenseGroupDetailsPage extends StatefulWidget {
  Map<String, dynamic> groupMap;

  ExpenseGroupDetailsPage({required this.groupMap});

  @override
  State<ExpenseGroupDetailsPage> createState() =>
      _ExpenseGroupDetailsPageState(groupMap: groupMap);
}

class _ExpenseGroupDetailsPageState extends State<ExpenseGroupDetailsPage> {
  Map<String, dynamic> groupMap;

  _ExpenseGroupDetailsPageState({required this.groupMap});

  late GroupModel group;
  late List expenseList;

  @override
  void initState() {
    super.initState();
    group = GroupModel.fromJson(groupMap);
    expenseList = group.expenses.toList();
    expenseList.sort((a, b) {
      final dateA = DateTime.parse(a['expenseDate']);
      final dateB = DateTime.parse(b['expenseDate']);
      return dateB.compareTo(dateA); // 👈 descending
    });
    debugPrint("groupId:::${group.exGroupId}");
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<ApiProvider>(
      builder: (_, api, __) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(group.exGroupName),
            actions: [
              IconButton(
                onPressed: () {
                  DialogUtils.showGenericDialog(
                    context: context,
                    title: DialogUtils.titleText('Expense Chart'),
                    message: ExpensePieChart(expenses: group.expenses),
                    confirmText: 'Close',
                    showCancel: false,
                    confirmColor: Colors.red,
                    onConfirm: () => Navigator.of(context).pop(),
                  );
                },
                icon: Icon(FontAwesomeIcons.chartPie),
              ),
              IconButton(
                onPressed: () {
                  DialogUtils.showGenericDialog(
                    context: context,
                    title: DialogUtils.titleText('Delete Group?'),
                    message: Text(
                      'Are you sure you want to delete this Expense Group?',
                    ),
                    confirmText: 'Delete',
                    confirmColor: Colors.red,
                    onConfirm: () async {
                      Navigator.pop(context);
                      await api.deleteGroups(group.exGroupId, context).then((
                        Response res,
                      ) {
                        api.groupList.removeWhere(
                          (element) => element['exGroupId'] == group.exGroupId,
                        );
                        Navigator.pop(context);
                        Toasts.show(
                          context,
                          'Expense Group Deleted',
                          type: ToastType.success,
                        );
                      });
                    },
                    showCancel: true,
                    cancelText: 'Cancel',
                    onCancel: () => Navigator.pop(context),
                  );
                },
                icon: Icon(Icons.delete),
              ),
            ],
            actionsPadding: EdgeInsets.only(right: 10.0),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group image or fallback
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      group.exGroupImageURL.isNotEmpty
                                          ? Image.network(
                                            group.exGroupImageURL,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.group,
                                              size: 32,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 12),

                                // Group name & type
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.exGroupName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      if (group.exGroupDesc.isNotEmpty)
                                        Text(
                                          group.exGroupDesc,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            typeList
                                                .elementAt(
                                                  int.parse(group.exGroupType),
                                                )
                                                .icon,
                                            size: 20.0,
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            typeList
                                                .elementAt(
                                                  int.parse(group.exGroupType),
                                                )
                                                .name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.person, size: 20.0),
                                    SizedBox(width: 5.0),
                                    Text(
                                      auth.user!.displayName!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.date_range, size: 20.0),
                                    SizedBox(width: 5.0),
                                    Text(
                                      formatDateString(group.exGroupCreatedOn),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(height: 15.0),
                                Row(
                                  mainAxisAlignment:
                                      group.exGroupShared &&
                                              group.exGroupMembers.isNotEmpty
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (group.exGroupShared &&
                                        group.exGroupMembers.isNotEmpty)
                                      initialsRow(group.exGroupMembers),
                                    if (group.exGroupShared &&
                                        group.exGroupMembers.isNotEmpty)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.arrow_upward,
                                                color: Colors.green,
                                              ),
                                              Text(
                                                formatCurrency(
                                                  group.exGroupIncome,
                                                  context,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                formatCurrency(
                                                  group.exGroupExpenses,
                                                  context,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.arrow_upward,
                                                color: Colors.green,
                                              ),
                                              Text(
                                                formatCurrency(
                                                  group.exGroupIncome,
                                                  context,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                formatCurrency(
                                                  group.exGroupExpenses,
                                                  context,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          group.expenses.isEmpty
                              ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: buildCreateDataBox(
                                    context,
                                    "Be on Track 📊\n\n➕ Add your Expenses",
                                    () async {
                                      final updatedGroup = await Navigator.of(
                                        context,
                                      ).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CreateExpensePage(
                                                group: group.toJson(),
                                              ),
                                        ),
                                      );

                                      if (updatedGroup != null) {
                                        setState(() {
                                          group = GroupModel.fromJson(
                                            updatedGroup,
                                          );
                                        });
                                      }
                                    },
                                    LinearGradient(
                                      colors: [
                                        Color(0xFF3D7EAA),
                                        Color(0xFFFFE47A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              )
                              : ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    indent: 25.0,
                                    endIndent: 25.0,
                                    height: 15,
                                    thickness: 0.15,
                                  );
                                },
                                physics: BouncingScrollPhysics(),
                                itemCount: expenseList.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> expense = expenseList
                                      .elementAt(index);
                                  return Dismissible(
                                    key: ValueKey(expense['expenseId']),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
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
                                      final shouldDelete =
                                          await DialogUtils.showGenericDialog(
                                            context: context,
                                            title: DialogUtils.titleText(
                                              'Delete Expense?',
                                            ),
                                            message: const Text(
                                              'Are you sure you want to delete this expense?',
                                            ),
                                            onConfirm: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            onCancel:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            showCancel: true,
                                            cancelText: 'Cancel',
                                            confirmText: 'Delete',
                                            confirmColor: Colors.red,
                                          );
                                      return shouldDelete ?? false;
                                    },

                                    onDismissed: (direction) async {
                                      final removedExpense =
                                          group.expenses[index];
                                      setState(() {
                                        group.expenses.removeAt(
                                          index,
                                        ); // ✅ removes widget immediately
                                      });

                                      ApiProvider api =
                                          Provider.of<ApiProvider>(
                                            context,
                                            listen: false,
                                          );

                                      await api
                                          .updateGroup(context, group.toJson())
                                          .then((Response resp) {
                                            debugPrint(
                                              resp.statusCode.toString(),
                                            );
                                            if (resp.statusCode == 200) {
                                              Toasts.show(
                                                context,
                                                "Expense ${expense['expenseTitle']} Removed",
                                                type: ToastType.success,
                                              );

                                              api.groupList.removeWhere(
                                                (element) =>
                                                    element['exGroupId'] ==
                                                    group.exGroupId,
                                              );
                                              api.groupList.add(resp.data);
                                              setState(() {
                                                group = GroupModel.fromJson(
                                                  resp.data,
                                                );
                                              });
                                            }
                                          });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          DialogUtils.showGenericDialog(
                                            context: context,
                                            showCancel: false,
                                            onConfirm:
                                                () => Navigator.pop(context),
                                            confirmColor: Colors.green,
                                            confirmText: 'Close',
                                            title: SizedBox.shrink(),
                                            message: SizedBox(
                                              child: expenseCard(expense),
                                            ),
                                          );
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        splashColor: Colors.grey.shade100,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        leading: Card(
                                          elevation: 0.0,
                                          margin: EdgeInsets.zero,
                                          shape: CircleBorder(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            height: 65.0,
                                            width: 65.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  DateTime.parse(
                                                    expense['expenseDate'],
                                                  ).day.toString(),
                                                  style: TextStyle(
                                                    fontSize: 17.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  month
                                                      .elementAt(
                                                        int.parse(
                                                              DateTime.parse(
                                                                expense['expenseDate'],
                                                              ).month.toString(),
                                                            ) -
                                                            1,
                                                      )
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          expense['expenseTitle'],
                                          style: TextStyle(fontSize: 17.5),
                                        ),
                                        subtitle: Text(
                                          '${expense['expensePaidBy']} ${expense['expenseSpendType'] == 'expense' ? "paid" : "received"} ₹${expense['expenseAmount']}',
                                          style: TextStyle(fontSize: 12.5),
                                        ),
                                        trailing: Card(
                                          color: expense['expenseSpendType'] ==
                                              'income'
                                              ? Colors.green
                                              : Colors.red,
                                          margin: EdgeInsets.zero,
                                          elevation: 0.0,
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Text(
                                              expense['expenseCategory'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
                if (api.isAPILoading) buildLoadingContainer(context: context),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final updatedGroup = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => CreateExpensePage(group: group.toJson()),
                ),
              );

              if (updatedGroup != null) {
                setState(() {
                  group = GroupModel.fromJson(updatedGroup);
                });
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget initialsRow(List<String> names) {
    final double avatarSize = 32;
    final double overlap = 25;
    final int maxToShow = 5;

    // show max 5 names, rest go in "+X"
    final visibleNames =
        names.length > maxToShow ? names.take(maxToShow).toList() : names;

    final totalCount = names.length;
    final extraCount = totalCount - visibleNames.length;

    // total width for positioning
    final double totalWidth =
        avatarSize +
        ((visibleNames.length - 1) + (extraCount > 0 ? 1 : 0)) * overlap;

    return GestureDetector(
      onTap: () {
        DialogUtils.showGenericDialog(
          context: context,
          title: DialogUtils.titleText('Group Members'),
          message: SizedBox(
            height:
                names.length > 5
                    ? MediaQuery.of(context).size.height / 3
                    : MediaQuery.of(context).size.height / 5,
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children:
                  names.map((name) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 30,
                          height: 30,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.group,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      title: Text(name),
                    );
                  }).toList(),
            ),
          ),
          showCancel: false,
          onConfirm: () {
            Navigator.of(context).pop();
          },
          confirmColor: Colors.green,
          confirmText: 'Close',
        );
      },
      child: SizedBox(
        height: avatarSize,
        width: totalWidth,
        child: Stack(
          children: [
            // actual initials
            for (int i = 0; i < visibleNames.length; i++)
              Positioned(
                left: i * overlap,
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.lightBlue,
                  child: Text(
                    getInitials(visibleNames[i]),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // "+X" avatar if more members
            if (extraCount > 0)
              Positioned(
                left: visibleNames.length * overlap,
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.blue,
                  child: Text(
                    "+$extraCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget expenseCard(Map<String, dynamic> expense) {
    return Card(
      margin: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      getCategoryIcon(
                        expense['expenseCategory'],
                        expense['expenseSpendType'],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense['expenseCategory'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                        ),
                        Text(
                          expense['expenseSubCategory'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "${expense['expenseSpendType'] == 'income' ? '+' : '-'} ₹${expense['expenseAmount']}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        expense['expenseSpendType'] == 'income'
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),
            Text(
              expense['expenseTitle'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              formatDateString(expense['expenseDate'], pattern: 'dd MMM yyyy'),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),

            Divider(height: 20),

            // Paid By + Payment Method
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Paid By: ${expense['expensePaidBy']}",
                    style: TextStyle(fontSize: 14),
                  ),

                  Icon(
                    payMethodList
                        .firstWhere(
                          (pay) =>
                              pay.payMethod == expense['expensePaymentMethod'],
                        )
                        .icon,
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Wrap(
              spacing: 6,
              children:
                  expense['expensePaidTo'].map<Widget>((name) {
                    return Chip(label: Text(name));
                  }).toList(),
            ),

            if (expense['expenseNote'].isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                "Note: ${expense['expenseNote']}",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            if (expense['expenseReceiptURL'].isNotEmpty) ...[
              SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.purple),
                    SizedBox(width: 6),
                    Text(
                      "View Attachment",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
