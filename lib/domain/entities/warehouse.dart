class Warehouse {
  final int id;
  final String name;

  Warehouse({required this.name, required this.id});

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['storeId'],
      name: json['storeName'].toString().trim(),
    );
  }
}
