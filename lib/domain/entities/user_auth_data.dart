class UserAuthData {
  final String token;
  final int expiredAt;
  final bool freebie;
  const UserAuthData({
    required this.token,
    required this.freebie,
    required this.expiredAt,
  });
}
