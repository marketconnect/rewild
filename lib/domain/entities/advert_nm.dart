class AdvertNm {
  int nm;
  bool active;

  AdvertNm({
    required this.nm,
    required this.active,
  });

  factory AdvertNm.fromJson(Map<String, dynamic> json) {
    return AdvertNm(
      nm: json['nm'],
      active: json['active'],
    );
  }
}
