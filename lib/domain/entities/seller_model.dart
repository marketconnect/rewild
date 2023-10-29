import 'dart:convert';

import 'package:rewild/domain/entities/card_of_product_model.dart';

class SellerModel {
  final int supplierId;
  String name;
  String? fineName;
  String? ogrn;
  String? trademark;
  String? legalAddress;

  final List<CardOfProductModel> productsCards;

  SellerModel({
    required this.supplierId,
    required this.name,
    this.fineName = "",
    this.ogrn = "",
    this.trademark = "",
    this.legalAddress = "",
    this.productsCards = const [],
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      supplierId: json['id'] as int,
      name: json['name'] as String,
      fineName: json['fineName'] ?? "",
      ogrn: json['ogrn'] ?? "",
      trademark: json['trademark'] ?? "",
      legalAddress: json['legalAddress'] ?? "",
    );
  }

  SellerModel copyWith({
    int? id,
    int? sellerId,
    String? name,
    String? fineName,
    String? ogrn,
    String? trademark,
    String? legalAddress,
  }) {
    return SellerModel(
      supplierId: sellerId ?? supplierId,
      name: name ?? this.name,
      fineName: fineName ?? this.fineName,
      ogrn: ogrn ?? this.ogrn,
      trademark: trademark ?? this.trademark,
      legalAddress: legalAddress ?? this.legalAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'supplierId': supplierId,
      'name': name,
      'fineName': fineName,
      'ogrn': ogrn,
      'trademark': trademark,
      'legalAddress': legalAddress,
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      supplierId: map['supplierId'] as int,
      name: map['name'] as String,
      fineName: map['fineName'] != null ? map['fineName'] as String : null,
      ogrn: map['ogrn'] != null ? map['ogrn'] as String : null,
      trademark: map['trademark'] != null ? map['trademark'] as String : null,
      legalAddress:
          map['legalAddress'] != null ? map['legalAddress'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'SellerModel(supplierId: $supplierId, name: $name, fineName: $fineName, ogrn: $ogrn, trademark: $trademark, legalAddress: $legalAddress)';
  }

  @override
  bool operator ==(covariant SellerModel other) {
    if (identical(this, other)) return true;

    return other.supplierId == supplierId &&
        other.name == name &&
        other.fineName == fineName &&
        other.ogrn == ogrn &&
        other.trademark == trademark &&
        other.legalAddress == legalAddress;
  }

  @override
  int get hashCode {
    return supplierId.hashCode ^
        name.hashCode ^
        fineName.hashCode ^
        ogrn.hashCode ^
        trademark.hashCode ^
        legalAddress.hashCode;
  }
}
