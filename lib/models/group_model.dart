class GroupModel {
  String exGroupId;
  String exGroupName;
  String exGroupDesc;
  String exGroupImageURL;
  String exGroupType;
  bool exGroupShared;
  List<String> exGroupMembers;
  String exGroupCreatedOn;
  String exGroupOwnerId;
  List<dynamic> expenses;
  double exGroupIncome;
  double exGroupExpenses;

  GroupModel({
    required this.exGroupId,
    required this.exGroupName,
    required this.exGroupDesc,
    required this.exGroupImageURL,
    required this.exGroupType,
    required this.exGroupShared,
    required this.exGroupMembers,
    required this.exGroupCreatedOn,
    required this.exGroupOwnerId,
    required this.expenses,
    required this.exGroupIncome,
    required this.exGroupExpenses,
  });

  /// Create object from JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      exGroupId: json['exGroupId'] ?? '',
      exGroupName: json['exGroupName'] ?? '',
      exGroupDesc: json['exGroupDesc'] ?? '',
      exGroupImageURL: json['exGroupImageURL'] ?? '',
      exGroupType: json['exGroupType'] ?? '',
      exGroupShared: json['exGroupShared'] ?? false,
      exGroupMembers: List<String>.from(json['exGroupMembers'] ?? []),
      exGroupCreatedOn: json['exGroupCreatedOn'] ?? '',
      exGroupOwnerId: json['exGroupOwnerId'] ?? '',
      expenses: json['expenses'] ?? [],
      exGroupExpenses: json['exGroupExpenses'] ?? 0,
      exGroupIncome: json['exGroupIncome'] ?? 0,
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'exGroupId': exGroupId,
      'exGroupName': exGroupName,
      'exGroupDesc': exGroupDesc,
      'exGroupImageURL': exGroupImageURL,
      'exGroupType': exGroupType,
      'exGroupShared': exGroupShared,
      'exGroupMembers': exGroupMembers,
      'exGroupCreatedOn': exGroupCreatedOn,
      'exGroupOwnerId': exGroupOwnerId,
      'expenses': expenses,
      'exGroupIncome': exGroupIncome,
      'exGroupExpenses': exGroupExpenses,
    };
  }

  // 🔹 Setters
  set setExGroupId(String id) => exGroupId = id;

  set setExGroupName(String name) => exGroupName = name;

  set setExGroupDesc(String desc) => exGroupDesc = desc;

  set setExGroupImageURL(String url) => exGroupImageURL = url;

  set setExGroupType(String type) => exGroupType = type;

  set setExGroupShared(bool shared) => exGroupShared = shared;

  set setExGroupMembers(List<String> members) => exGroupMembers = members;

  set setExGroupCreatedOn(String createdOn) => exGroupCreatedOn = createdOn;

  set setExGroupOwnerId(String ownerId) => exGroupOwnerId = ownerId;

  setExpenses(List exp) {
    expenses = exp;
  }

  set setExGroupIncome(double income) => exGroupIncome = income;

  set setExGroupExpenses(double exps) => exGroupExpenses = exps;
}
