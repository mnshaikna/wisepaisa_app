import 'package:typed_data/typed_data.dart';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/models/expense_model.dart';
import 'package:wisepaise/providers/api_provider.dart';
import 'package:wisepaise/providers/auth_provider.dart';
import 'package:wisepaise/providers/settings_provider.dart';
import 'package:wisepaise/utils/utils.dart';

import '../models/type_model.dart';
import '../utils/toast.dart';
import 'home_page.dart';

class CreateExpensePage extends StatefulWidget {
  Map<String, dynamic> group;

  CreateExpensePage({super.key, required this.group});

  @override
  State<CreateExpensePage> createState() =>
      _CreateExpensePageState(group: group);
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  Map<String, dynamic> group;
  Uint8List? imageBytes;

  _CreateExpensePageState({required this.group});

  bool isExpense = true;
  TextEditingController dateController = TextEditingController(),
      descController = TextEditingController(),
      amountController = TextEditingController(),
      expenseNote = TextEditingController();
  String? paidBy;
  CategoryModel? selectedCategory;
  PaymentMethodModel? payMethod;
  String? subCategoryValue;
  final Set<String> paidTo = {};
  dynamic members;

  @override
  void initState() {
    super.initState();
    if (group.isNotEmpty) {
      debugPrint('groupId:::${group['exGroupId']}');
      AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      members =
          {...group['exGroupMembers'] ?? [], auth.user!.displayName!}.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiProvider>(
      builder: (_, api, __) {
        return Consumer<SettingsProvider>(
          builder: (_, set, __) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  group.isNotEmpty ? group['exGroupName'] : 'Add Expense',
                ),
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 0.0,
                          ),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 10.0),
                                Card(
                                  elevation: 2.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => isExpense = true,
                                                ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isExpense
                                                        ? Colors.green
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Expense",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => isExpense = false,
                                                ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    !isExpense
                                                        ? Colors.green
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Income",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: descController,
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: "Enter a Desc",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 16),
                                // Amount field
                                TextField(
                                  controller: amountController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      isExpense ? Icons.remove : Icons.add,
                                      color:
                                          isExpense ? Colors.red : Colors.green,
                                    ),
                                    hintText: set.currency,
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: dateController,
                                  readOnly: true,
                                  onTap:
                                      () => _showBottomSheetCalendar(context),
                                  decoration: InputDecoration(
                                    labelText: "Date",

                                    suffixIcon: IconButton(
                                      onPressed:
                                          () =>
                                              _showBottomSheetCalendar(context),
                                      icon: Icon(Icons.calendar_today),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    // Category Dropdown
                                    Expanded(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 250,
                                        ),
                                        child: DropdownButtonFormField<
                                          CategoryModel
                                        >(
                                          decoration: InputDecoration(
                                            labelText: "Category",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          value: selectedCategory,
                                          isExpanded: true,
                                          menuMaxHeight: 250.0,

                                          // 🔑 Choose expense or income list
                                          items:
                                              (isExpense
                                                      ? catList["expense"]!
                                                      : catList["income"]!)
                                                  .map((cat) {
                                                    return DropdownMenuItem<
                                                      CategoryModel
                                                    >(
                                                      value: cat,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 4,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              cat.icon,
                                                              size: 20,
                                                              color:
                                                                  Colors
                                                                      .blueAccent,
                                                            ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                cat.cat,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),

                                          // 👇 Control how selected item is displayed
                                          selectedItemBuilder: (context) {
                                            return (isExpense
                                                    ? catList["expense"]!
                                                    : catList["income"]!)
                                                .map((cat) {
                                                  return Row(
                                                    children: [
                                                      Icon(
                                                        cat.icon,
                                                        size: 20,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Expanded(
                                                        child: Text(
                                                          cat.cat,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList();
                                          },

                                          onChanged: (CategoryModel? val) {
                                            setState(() {
                                              selectedCategory = val;
                                              subCategoryValue = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // SubCategory Dropdown (depends on selectedCategory)
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: "Sub-Category",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        isExpanded: true,
                                        menuMaxHeight: 250.0,
                                        value: subCategoryValue,
                                        items:
                                            (selectedCategory?.subCat ?? [])
                                                .map((sub) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: sub,
                                                    child: Text(
                                                      sub,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                      maxLines: 1,
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                        onChanged: (String? val) {
                                          setState(() {
                                            subCategoryValue = val;
                                            debugPrint(
                                              'Dropdown Value::: $subCategoryValue',
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 250),
                                  child: DropdownButtonFormField<
                                    PaymentMethodModel
                                  >(
                                    decoration: InputDecoration(
                                      labelText: "Payment Method",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    value: payMethod,
                                    isExpanded: true,
                                    menuMaxHeight: 250.0,
                                    items:
                                        payMethodList.map((pay) {
                                          return DropdownMenuItem<
                                            PaymentMethodModel
                                          >(
                                            value: pay,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      8,
                                                    ), // rounded corners
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    pay.icon,
                                                    size: 20,
                                                    color: Colors.blueAccent,
                                                  ),
                                                  SizedBox(width: 15),
                                                  Text(pay.payMethod),
                                                  // here it’s okay if long
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    // 👇 This controls how selected item is shown
                                    selectedItemBuilder: (context) {
                                      return payMethodList.map((pay) {
                                        return Row(
                                          children: [
                                            Icon(
                                              pay.icon,
                                              size: 20,
                                              color: Colors.blueAccent,
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                pay.payMethod,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                    onChanged: (PaymentMethodModel? val) {
                                      setState(() {
                                        payMethod = val;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: expenseNote,
                                  textCapitalization: TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    labelText: "Write a note (Optional)",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                imageBytes == null
                                    ? buildCreateDataBox(
                                      context,
                                      "Got a Receipt to add?\n\n➕ Tap to add attachment",
                                      () {
                                        _showAttachmentOptions(context);
                                      },
                                      LinearGradient(
                                        colors: [
                                          Color(0xFF56CCF2),
                                          Color(0xFF2F80ED),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    )
                                    : GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          imageBytes = null;
                                        });
                                        Toasts.show(
                                          context,
                                          'Image removed',
                                          type: ToastType.info,
                                        );
                                      },
                                      child: Container(
                                        height: 250.0,
                                        width: double.infinity,
                                        padding: EdgeInsets.all(0.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          border: Border.all(
                                            width: 1.0,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black54
                                                    : Colors.white54,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          child: Image.memory(
                                            imageBytes as Uint8List,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                if (group.isNotEmpty)
                                  const SizedBox(height: 16),
                                if (group.isNotEmpty && members.length > 1)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Paid By Section (Single Select)
                                      const Text(
                                        "Paid By",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10.0,
                                        runSpacing: 10.0,
                                        children:
                                            members.map<Widget>((name) {
                                              final isSelected = paidBy == name;
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    paidBy = name;
                                                  });
                                                },
                                                child: SizedBox(
                                                  width: 75.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 28,
                                                        backgroundColor:
                                                            isSelected
                                                                ? Colors.green
                                                                : Colors
                                                                    .grey
                                                                    .shade300,
                                                        child: Text(
                                                          name[0].toUpperCase(),
                                                          // First letter
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              isSelected
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color:
                                                              isSelected
                                                                  ? Colors.green
                                                                  : Theme.of(
                                                                        context,
                                                                      ).brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Paid To",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10.0,
                                        runSpacing: 10.0,
                                        children:
                                            members.map<Widget>((name) {
                                              final isSelected = paidTo
                                                  .contains(name);
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (isSelected) {
                                                      paidTo.remove(name);
                                                    } else {
                                                      paidTo.add(name);
                                                    }
                                                  });
                                                },
                                                child: SizedBox(
                                                  width: 75.0,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 28,
                                                        backgroundColor:
                                                            isSelected
                                                                ? Colors.green
                                                                : Colors
                                                                    .grey
                                                                    .shade300,
                                                        child: Text(
                                                          name[0].toUpperCase(),
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              isSelected
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color:
                                                              isSelected
                                                                  ? Colors.green
                                                                  : Theme.of(
                                                                        context,
                                                                      ).brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (validateForm()) {
                                if (group.isNotEmpty) {
                                  if (members.length == 1) {
                                    AuthProvider auth =
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        );
                                    paidBy = auth.user!.displayName!;
                                    paidTo.add(auth.user!.displayName!);
                                  }
                                  ExpenseModel expense = ExpenseModel(
                                    expenseId: '',
                                    expenseTitle: descController.text.trim(),
                                    expenseNote: expenseNote.text.trim(),
                                    expenseAmount: double.parse(
                                      amountController.text.trim(),
                                    ),
                                    expenseSpendType:
                                        isExpense ? 'expense' : 'income',
                                    expenseDate: dateController.text.trim(),
                                    expensePaidTo: paidTo.toList(),
                                    expenseCategory:
                                        selectedCategory!.cat.toString(),
                                    expenseSubCategory:
                                        subCategoryValue.toString(),
                                    expensePaymentMethod:
                                        payMethod!.payMethod.toString(),
                                    expensePaidBy: paidBy.toString(),
                                    expenseReceiptURL: '',
                                    expenseUserId: '',
                                  );
                                  List<dynamic> expenses =
                                      group['expenses'] ?? [];
                                  expenses.add(expense.toJson());
                                  debugPrint(
                                    'Expense Data:::${expense.toJson().toString()}',
                                  );
                                  group['expenses'] = expenses;

                                  await api.updateGroup(context, group).then((
                                    Response resp,
                                  ) {
                                    debugPrint(resp.statusCode.toString());
                                    if (resp.statusCode == 200) {
                                      Toasts.show(
                                        context,
                                        'Expense successfully added',
                                        type: ToastType.success,
                                      );
                                      api.groupList.removeWhere(
                                        (element) =>
                                            element['exGroupId'] ==
                                            group['exGroupId'],
                                      );
                                      api.groupList.add(resp.data);
                                      Navigator.pop(context, resp.data);
                                    }
                                  });
                                } else {
                                  debugPrint('Add Expense');

                                  AuthProvider auth = Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  );
                                  paidBy = auth.user!.displayName!;
                                  paidTo.add(auth.user!.displayName!);

                                  ExpenseModel expense = ExpenseModel(
                                    expenseId: '',
                                    expenseTitle: descController.text.trim(),
                                    expenseNote: expenseNote.text.trim(),
                                    expenseAmount: double.parse(
                                      amountController.text.trim(),
                                    ),
                                    expenseSpendType:
                                        isExpense ? 'expense' : 'income',
                                    expenseDate: dateController.text.trim(),
                                    expensePaidTo: paidTo.toList(),
                                    expenseCategory:
                                        selectedCategory!.cat.toString(),
                                    expenseSubCategory:
                                        subCategoryValue.toString(),
                                    expensePaymentMethod:
                                        payMethod!.payMethod.toString(),
                                    expensePaidBy: paidBy.toString(),
                                    expenseReceiptURL: '',
                                    expenseUserId: auth.user!.id,
                                  );

                                  debugPrint(
                                    'Expense Data:::${expense.toJson().toString()}',
                                  );

                                  await api
                                      .createExpense(context, expense.toJson())
                                      .then((Response resp) {
                                        debugPrint(resp.statusCode.toString());
                                        if (resp.statusCode == 200) {
                                          Toasts.show(
                                            context,
                                            'Expense successfully Created',
                                            type: ToastType.success,
                                          );

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      MyDashboardPage(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        }
                                      });
                                }
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Add Expense'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              textStyle: TextStyle(
                                fontSize: 15.0,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (api.isAPILoading) buildLoadingContainer(context: context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheetCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              Navigator.of(context).pop();
              dateController.text = DateFormat('yyyy-MM-dd').format(date);
            },
          ),
        );
      },
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    height: 5.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                  title: const Text("Take a photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFile(pickType: ImageSource.camera).then((bytes) {
                      setState(() {
                        imageBytes = bytes!;
                      });
                    });
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: const Icon(Icons.image, color: Colors.green),
                  title: const Text("Choose from gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFile(pickType: ImageSource.gallery).then((bytes) {
                      setState(() {
                        imageBytes = bytes!;
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool validateForm() {
    if (descController.text.trim().isEmpty) {
      Toasts.show(context, 'Enter a Desc', type: ToastType.error);
      return false;
    }
    if (amountController.text.trim().isEmpty ||
        amountController.text.trim() == '0') {
      Toasts.show(context, 'Enter amount', type: ToastType.error);
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      Toasts.show(context, 'Choose a date', type: ToastType.error);
      return false;
    }
    if (selectedCategory == null || selectedCategory!.cat.isEmpty) {
      Toasts.show(context, 'Select a category', type: ToastType.error);
      return false;
    }
    if (subCategoryValue == null || subCategoryValue!.isEmpty) {
      Toasts.show(context, 'Select a sub category', type: ToastType.error);
      return false;
    }
    if (payMethod == null || payMethod!.payMethod.isEmpty) {
      Toasts.show(context, 'Select a Payment method', type: ToastType.error);
      return false;
    }
    if ((members != null && members.length > 1) &&
        (paidBy == null || paidBy!.isEmpty)) {
      Toasts.show(context, 'Select PaidBy', type: ToastType.error);
      return false;
    }
    if (members != null && members.length > 1 && (paidTo.isEmpty)) {
      Toasts.show(context, 'Select PaidTo', type: ToastType.error);
      return false;
    }
    return true;
  }
}
