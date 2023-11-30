class StreamAdvertEvent {
  final int campaignId;
  int? cpm;
  int? status;

  StreamAdvertEvent(
      {required this.campaignId, required this.cpm, required this.status});
}
