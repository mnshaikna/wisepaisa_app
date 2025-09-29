import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/models/type_model.dart';
import 'package:wisepaise/utils/toast.dart';

import '../providers/api_provider.dart';
import '../providers/settings_provider.dart';
import 'constants.dart';
import 'dialog_utils.dart';

void unfocusKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

String formatCurrency(num amount, BuildContext context, {String? locale}) {
  final currencyCode =
      Provider.of<SettingsProvider>(context, listen: false).currency;
  final formatter = NumberFormat.simpleCurrency(
    name: currencyCode,
    locale: locale ?? 'en',
  );
  return formatter.format(amount);
}

String formatDateString(String dateStr, {String pattern = 'MMM dd, yyyy'}) {
  final DateTime date = DateTime.parse(dateStr);
  final formatter = DateFormat(pattern);
  return formatter.format(date);
}

IconData getCategoryIcon(String category, String type) {
  CategoryModel thisCat = catList[type]!.firstWhere(
    (cat) => cat.cat == category,
  );
  return thisCat.icon;
}

Material buildCreateDataBox(
  BuildContext context,
  String title,
  var onTapFunction,
  Gradient gradients,
) {
  return Material(
    color: Colors.grey.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onTapFunction,
      child: Ink(
        height: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: gradients,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

Widget buildLoadingContainer({
  required BuildContext context,
  bool showBgColor = false,
}) {
  return Container(
    color:
        showBgColor
            ? (Theme.of(context).brightness == Brightness.light
                ? Colors.white54
                : Colors.black)
            : Colors.black54,
    child: Center(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          margin: EdgeInsets.all(10.0),
          height: 75.0,
          width: 100.0,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Image.asset('assets/loader.gif', fit: BoxFit.fill),
        ),
      ),
    ),
  );
}

Future<Uint8List?> pickFile({
  ImageSource pickType = ImageSource.gallery,
}) async {
  Uint8List? bytes;
  final ImagePicker picker = ImagePicker();
  await picker.pickImage(source: pickType).then((file) async {
    debugPrint(file!.name.toString());
    await file.readAsBytes().then((byte) {
      bytes = byte;
    });
  });
  debugPrint(bytes.toString());
  return Future.value(bytes);
}

List<Widget> buildGroupedExpenseWidgets(
  List<Map<String, dynamic>> expenses,
  BuildContext context,
) {
  // Parse and sort by date desc
  final DateFormat inputFmt = DateFormat('yyyy-MM-dd');
  final DateFormat headerFmt = DateFormat('MMM yyyy');

  List<Map<String, dynamic>> parsed =
      expenses.map((e) {
        String dateStr = (e['expenseDate'] ?? '').toString();
        DateTime? dt;
        try {
          if (dateStr.isNotEmpty) dt = inputFmt.parse(dateStr);
        } catch (_) {
          dt = null;
        }
        return {...e, '_parsedDate': dt};
      }).toList();

  parsed.sort((a, b) {
    DateTime? da = a['_parsedDate'];
    DateTime? db = b['_parsedDate'];
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });

  Map<String, List<Map<String, dynamic>>> groups = {};
  for (var e in parsed) {
    DateTime? dt = e['_parsedDate'];
    String key = dt == null ? 'Unknown' : headerFmt.format(dt);
    groups.putIfAbsent(key, () => []).add(e);
  }

  final theme = Theme.of(context);
  List<Widget> widgets = [];
  groups.forEach((header, items) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
        child: Text(
          header,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    widgets.addAll(
      items.take(10).map((e) {
        final String spendType =
            (e['expenseSpendType'] ?? 'expense').toString();
        final bool isExpense = spendType.toLowerCase() == 'expense';
        return Dismissible(
          key: ValueKey(e['expenseId']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.0),
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
              title: DialogUtils.titleText('Delete Expense?'),
              message: const Text(
                'Are you sure you want to delete this expense?',
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

            String strExpId = e['expenseId'];

            api.userExpenseList.removeWhere(
              (exp) => exp['expenseId'] == strExpId,
            );

            await api.deleteExpense(context, strExpId).then((Response resp) {
              debugPrint(resp.statusCode.toString());
              if (resp.statusCode == 200) {
                Toasts.show(
                  context,
                  "Expense ${e['expenseTitle']} Removed",
                  type: ToastType.success,
                );
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ListTile(
              isThreeLine: true,
              onTap: () {
                DialogUtils.showGenericDialog(
                  context: context,
                  showCancel: false,
                  onConfirm: () => Navigator.pop(context),
                  confirmColor: Colors.green,
                  confirmText: 'Close',
                  title: SizedBox.shrink(),
                  message: SizedBox(child: expenseCard(e)),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              splashColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 2.5),

              leading: Card(
                margin: EdgeInsets.zero,
                elevation: 0.0,
                shape: CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  height: 65.0,
                  width: 65.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateTime.parse(e['expenseDate']).day.toString(),
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
                                      e['expenseDate'],
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
              title: Text(e['expenseTitle'], style: TextStyle(fontSize: 17.5)),
              subtitle: Text(
                '${e['expenseCategory']} • ${e['expenseSubCategory']}',
                style: TextStyle(fontSize: 12.5),
              ),
              trailing: Card(
                margin: EdgeInsets.zero,
                elevation: 0.0,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e['expenseSpendType'] == 'expense'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color:
                            e['expenseSpendType'] == 'expense'
                                ? Colors.red
                                : Colors.green,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        formatCurrency(e['expenseAmount'], context),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              e['expenseSpendType'] == 'expense'
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
    widgets.add(
      const Divider(height: 5, thickness: 0.25, indent: 25.0, endIndent: 25.0),
    );
  });
  return widgets;
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
