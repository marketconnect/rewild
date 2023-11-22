class NotificationContent {
  final int id;
  // final String title;
  // final String body;
  final int? condition;
  final String? newValue;

  NotificationContent(
      {required this.id,
      // required this.title,
      // required this.body,
      this.condition,
      this.newValue});
}
