class ExpenseModel {
  String expenseId;
  String expenseTitle;
  String expenseNote;
  double expenseAmount;
  String expensePaymentMethod;
  String expenseDate;
  List<String> expensePaidTo;
  String expenseCategory;
  String expenseSubCategory;
  String expensePaidBy;
  String expenseReceiptURL;
  String expenseSpendType;
  String expenseUserId;

  ExpenseModel({
    required this.expenseId,
    required this.expenseTitle,
    required this.expenseNote,
    required this.expenseAmount,
    required this.expenseSpendType,
    required this.expenseDate,
    required this.expensePaidTo,
    required this.expenseCategory,
    required this.expenseSubCategory,
    required this.expensePaidBy,
    required this.expenseReceiptURL,
    required this.expensePaymentMethod,
    required this.expenseUserId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expenseId'] ?? '',
      expenseTitle: json['expenseTitle'] ?? '',
      expenseNote: json['expenseNote'] ?? '',
      expenseAmount: json['expenseAmount'] ?? 0.0,
      expenseSpendType: json['expenseSpendType'] ?? '',
      expenseDate: json['expenseDate'] ?? '',
      expensePaidTo: List<String>.from(json['expensePaidTo'] ?? []),
      expenseCategory: json['expenseCategory'] ?? '',
      expenseSubCategory: json['expenseSubCategory'] ?? '',
      expensePaidBy: json['expensePaidBy'] ?? '',
      expenseReceiptURL: json['expenseReceiptURL'] ?? '',
      expensePaymentMethod: json['expensePaymentMethod'] ?? '',
      expenseUserId: json['expenseUserId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'expenseTitle': expenseTitle,
      'expenseNote': expenseNote,
      'expenseAmount': expenseAmount,
      'expenseSpendType': expenseSpendType,
      'expenseDate': expenseDate,
      'expensePaidTo': expensePaidTo,
      'expenseCategory': expenseCategory,
      'expenseSubCategory': expenseSubCategory,
      'expensePaidBy': expensePaidBy,
      'expenseReceiptURL': expenseReceiptURL,
      'expensePaymentMethod': expensePaymentMethod,
      'expenseUserId': expenseUserId,
    };
  }

  set setExpenseId(String id) => expenseId = id;

  set setExpenseTitle(String title) => expenseTitle = title;

  set setExpenseNote(String note) => expenseNote = note;

  set setExpenseAmount(double amount) => expenseAmount = amount;

  set setExpensePaymentMethod(String method) => expensePaymentMethod = method;

  set setExpenseDate(String date) => expenseDate = date;

  set setExpensePaidTo(List<String> paidTo) => expensePaidTo = paidTo;

  set setExpenseCategory(String category) => expenseCategory = category;

  set setExpenseSubCategory(String subCategory) =>
      expenseSubCategory = subCategory;

  set setExpensePaidBy(String paidBy) => expensePaidBy = paidBy;

  set setExpenseReceiptURL(String url) => expenseReceiptURL = url;

  set setExpenseSpendType(String spendType) => expenseSpendType = spendType;

  set setExpenseUserId(String userId) => expenseUserId = userId;
}
