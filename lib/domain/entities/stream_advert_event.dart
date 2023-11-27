class StreamAdvertEvent {
  final int advertId;
  int? cpm;
  int? status;

  StreamAdvertEvent(
      {required this.advertId, required this.cpm, required this.status});
}
