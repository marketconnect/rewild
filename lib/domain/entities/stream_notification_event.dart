enum ParentType { card, advert }

class StreamNotificationEvent {
  final int parentId;
  final ParentType parentType;
  final bool exists;

  StreamNotificationEvent(
      {required this.parentId, required this.parentType, required this.exists});
}
