class ReminderModel {
  String reminderId;
  String reminderName;
  String reminderDescription;
  String reminderDate;
  String reminderRecurrencePattern;
  String reminderRecurrenceEndDate;
  String reminderRecurrenceInterval;
  String reminderCreatedDate;
  String reminderAmount;
  String reminderAmountType;
  String reminderUserId;
  bool reminderIsRecurring;
  bool reminderIsActive;

  ReminderModel(
    this.reminderId,
    this.reminderName,
    this.reminderDescription,
    this.reminderDate,
    this.reminderRecurrencePattern,
    this.reminderRecurrenceEndDate,
    this.reminderRecurrenceInterval,
    this.reminderCreatedDate,
    this.reminderAmount,
    this.reminderAmountType,
    this.reminderUserId,
    this.reminderIsRecurring,
    this.reminderIsActive,
  );

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      (json['reminderId'] ?? '').toString(),
      (json['reminderName'] ?? '').toString(),
      (json['reminderDescription'] ?? '').toString(),
      (json['reminderDate'] ?? '').toString(),
      (json['reminderRecurrencePattern'] ?? '').toString(),
      (json['reminderRecurrenceEndDate'] ?? '').toString(),
      (json['reminderRecurrenceInterval'] ?? '').toString(),
      (json['reminderCreatedDate'] ?? '').toString(),
      (json['reminderAmount'] ?? '').toString(),
      (json['reminderAmountType'] ?? '').toString(),
      (json['reminderUserId'] ?? '').toString(),
      json['reminderIsRecurring'] == true || json['reminderIsRecurring'] == 1,
      json['reminderIsActive'] == true || json['reminderIsActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'reminderName': reminderName,
      'reminderDescription': reminderDescription,
      'reminderDate': reminderDate,
      'reminderRecurrencePattern': reminderRecurrencePattern,
      'reminderRecurrenceEndDate': reminderRecurrenceEndDate,
      'reminderRecurrenceInterval': reminderRecurrenceInterval,
      'reminderCreatedDate': reminderCreatedDate,
      'reminderAmount': reminderAmount,
      'reminderAmountType': reminderAmountType,
      'reminderUserId': reminderUserId,
      'reminderIsRecurring': reminderIsRecurring,
      'reminderIsActive': reminderIsActive,
    };
  }
}
