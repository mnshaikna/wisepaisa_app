import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupType {
  late String name;
  late IconData icon;

  GroupType(this.name, this.icon);
}

class CategoryModel {
  late String cat;
  late IconData icon;
  late List<String> subCat;

  CategoryModel(this.cat, this.icon, this.subCat);
}

class PaymentMethodModel {
  late String payMethod;
  late IconData icon;

  PaymentMethodModel(this.payMethod, this.icon);
}

List<GroupType> typeList = [
  GroupType('Home', Icons.home),
  GroupType('Self', Icons.person),
  GroupType('Trip', Icons.flight_takeoff),
  GroupType('Family', Icons.people),
  GroupType('Savings', Icons.savings),
  GroupType('Others', Icons.currency_rupee),
];

Map<String, List<CategoryModel>> catList = {
  "expense": [
    CategoryModel('Entertainment', Icons.videogame_asset_outlined, [
      'Games',
      'Movies',
      'Music',
      'Sports',
      'Events',
      'Others',
    ]),
    CategoryModel('Food & Drink', Icons.fastfood, [
      'Dine Out',
      'Take Away',
      'Tea / Coffee',
      'Snacks',
      'Groceries',
      'Others',
    ]),
    CategoryModel('Home', Icons.house_rounded, [
      'Electronics',
      'Furniture',
      'Household Supplies',
      'Maintenance',
      'Mortgage',
      'Rent',
      'Services',
      'Pets',
      'Others',
    ]),
    CategoryModel('Lifestyle', FontAwesomeIcons.spa, [
      'Childcare',
      'Clothing',
      'Education',
      'Gifts',
      'Insurance',
      'Medical Expenses',
      'Taxes',
      'Fines',
      'Others',
    ]),
    CategoryModel('Transportation', Icons.directions_car, [
      'Bicycle',
      'Bus / Train',
      'Car',
      'Fuel',
      'Flight',
      'Taxi',
      'Hotel',
      'Parking',
      'Others',
    ]),
    CategoryModel('General', Icons.category, [
      'General',
      'Miscellaneous',
    ]),
    CategoryModel('Utilities', FontAwesomeIcons.wifi, [
      'Electricity',
      'Water',
      'Heater / Gas',
      'Trash',
      'Phone / WiFi',
      'Cleaning',
      'Others',
    ]),
    CategoryModel('Health & Fitness', FontAwesomeIcons.heartbeat, [
      'Gym',
      'Yoga',
      'Doctor',
      'Pharmacy',
      'Sports / Fitness',
      'Others',
    ]),
    CategoryModel('Travel', FontAwesomeIcons.plane, [
      'Tickets',
      'Accommodation',
      'Food & Drink',
      'Shopping',
      'Sightseeing',
      'Others',
    ]),
    CategoryModel('Debt & Loans', FontAwesomeIcons.creditCard, [
      'Loan Payment',
      'Credit Card Bill',
      'EMI',
      'Interest Payment',
      'Others',
    ]),
    CategoryModel('Shopping', FontAwesomeIcons.shoppingBag, [
      'Clothes',
      'Electronics',
      'Accessories',
      'Online Shopping',
      'Others',
    ]),
  ],
  "income": [
    CategoryModel('Salary', Icons.money, [
      'Base Salary',
      'Bonus',
      'Overtime',
      'Commission',
      'Allowances',
    ]),
    CategoryModel('Business / Self-Employment', FontAwesomeIcons.businessTime, [
      'Business Profits',
      'Freelance / Consulting',
      'Side Hustle',
      'Contract Work',
      'Tips',
    ]),
    CategoryModel('Investments', FontAwesomeIcons.chartLine, [
      'Dividends',
      'Interest Income',
      'Stock Trading Gains',
      'Mutual Fund Returns',
      'Bonds / Fixed Deposits',
    ]),
    CategoryModel('Property / Assets', FontAwesomeIcons.building, [
      'Rental Income',
      'Lease Income',
      'Sale of Property / Land',
      'Sale of Assets',
    ]),
    CategoryModel('Gifts / Donations', FontAwesomeIcons.gift, [
      'Cash Gift',
      'Family Support',
      'Inheritance',
      'Festival / Occasional Gift',
    ]),
    CategoryModel('Refunds & Reimbursements', FontAwesomeIcons.receipt, [
      'Tax Refund',
      'Expense Reimbursement',
      'Insurance Claim Payout',
      'Cashback',
    ]),
    CategoryModel('Grants & Benefits', FontAwesomeIcons.handsHelping, [
      'Scholarship / Stipend',
      'Pension',
      'Social Security / Government Aid',
      'Unemployment Benefits',
    ]),
    CategoryModel('Other Income', FontAwesomeIcons.coins, [
      'Lottery / Prize Money',
      'Royalties',
      'Licensing Fees',
      'Cryptocurrency / Digital Assets',
      'Miscellaneous',
    ]),
  ]
};


List<PaymentMethodModel> payMethodList = [
  PaymentMethodModel('Cash', FontAwesomeIcons.moneyBill1),
  PaymentMethodModel('Credit Card', FontAwesomeIcons.creditCard),
  PaymentMethodModel('Bank Transfer', FontAwesomeIcons.buildingColumns),
  PaymentMethodModel('UPI', FontAwesomeIcons.googlePay),
  PaymentMethodModel('Others', Icons.menu),
];
