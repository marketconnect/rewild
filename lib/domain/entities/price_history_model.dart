// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// class PriceHistoryModel {
//   final int nmId;
//   final int dt;
//   final int price;
//   final int updateAt;

//   PriceHistoryModel({
//     required this.nmId,
//     required this.dt,
//     required this.price,
//     required this.updateAt,
//   });

//   PriceHistoryModel copyWith({
//     int? id,
//     int? dt,
//     int? price,
//     int? updateAt,
//   }) {
//     return PriceHistoryModel(
//       nmId: id ?? nmId,
//       dt: dt ?? this.dt,
//       price: price ?? this.price,
//       updateAt: updateAt ?? this.updateAt,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': nmId,
//       'dt': dt,
//       'price': price,
//       'updateAt': updateAt,
//     };
//   }

//   factory PriceHistoryModel.fromMap(Map<String, dynamic> map) {
//     return PriceHistoryModel(
//       nmId: map['id'] as int,
//       dt: map['dt'] as int,
//       price: map['price'] as int,
//       updateAt: map['updateAt'] as int,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory PriceHistoryModel.fromJson(String source) =>
//       PriceHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() => 'PriceHistoryModel(id: $nmId, dt: $dt, price: $price)';

//   @override
//   bool operator ==(covariant PriceHistoryModel other) {
//     if (identical(this, other)) return true;

//     return other.nmId == nmId &&
//         other.dt == dt &&
//         other.updateAt == updateAt &&
//         other.price == price;
//   }

//   @override
//   int get hashCode => nmId.hashCode ^ dt.hashCode ^ price.hashCode;
// }
