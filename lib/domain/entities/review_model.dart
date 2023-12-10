// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class ReviewModel {
  String id;
  String userName;
  String matchingSize;
  String text;
  int productValuation;
  DateTime createdDate;
  String state;
  ReviewAnswer? answer;
  ReviewProductDetails productDetails;
  // List<Photo> photoLinks;
  // Video video;
  bool wasViewed;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.matchingSize,
    required this.text,
    required this.productValuation,
    required this.createdDate,
    required this.state,
    this.answer,
    required this.productDetails,
    required this.wasViewed,
  });

  ReviewModel copyWith({
    String? id,
    String? userName,
    String? matchingSize,
    String? text,
    int? productValuation,
    DateTime? createdDate,
    String? state,
    ReviewAnswer? answer,
    ReviewProductDetails? productDetails,
    bool? wasViewed,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      matchingSize: matchingSize ?? this.matchingSize,
      text: text ?? this.text,
      productValuation: productValuation ?? this.productValuation,
      createdDate: createdDate ?? this.createdDate,
      state: state ?? this.state,
      answer: answer ?? this.answer,
      productDetails: productDetails ?? this.productDetails,
      wasViewed: wasViewed ?? this.wasViewed,
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      userName: map['userName'] as String,
      matchingSize: map['matchingSize'] as String,
      text: map['text'] as String,
      productValuation: map['productValuation'] as int,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      state: map['state'] as String,
      answer: ReviewAnswer.fromMap(map['answer'] as Map<String, dynamic>),
      productDetails: ReviewProductDetails.fromMap(
          map['productDetails'] as Map<String, dynamic>),
      wasViewed: map['wasViewed'] as bool,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? "",
      userName: json['userName'] ?? "",
      matchingSize: json['matchingSize'] ?? "",
      productValuation: json['productValuation'] ?? 0,
      text: json['text'] ?? "",
      createdDate: DateTime.tryParse(json['createdDate']) ?? DateTime.now(),
      state: json['state'] ?? "",
      answer:
          json['answer'] == null ? null : ReviewAnswer.fromJson(json['answer']),
      productDetails: ReviewProductDetails.fromJson(json['productDetails']),
      wasViewed: json['wasViewed'] ?? false,
    );
  }
  // @override
  // String toString() {
  //   return 'ReviewModel(id: $id, userName: $userName, matchingSize: $matchingSize, text: $text, productValuation: $productValuation, createdDate: $createdDate, state: $state, answer: $answer, productDetails: $productDetails, wasViewed: $wasViewed)';
  // }
}

class ReviewAnswer {
  String text;
  String state;
  ReviewAnswer({
    required this.text,
    required this.state,
  });

  ReviewAnswer copyWith({
    String? text,
    String? state,
  }) {
    return ReviewAnswer(
      text: text ?? this.text,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'state': state,
    };
  }

  factory ReviewAnswer.fromMap(Map<String, dynamic> map) {
    return ReviewAnswer(
      text: map['text'] as String,
      state: map['state'] as String,
    );
  }

  String toJson() => json.encode(toMap());
//  factory QuestionProductDetails.fromJson(Map<String, dynamic> json) {
//     return QuestionProductDetails(
//       imtId: json['imtId'],
//       nmId: json['nmId'],
//       productName: json['productName'],
//       supplierArticle: json['supplierArticle'],
//       supplierName: json['supplierName'],
//       brandName: json['brandName'],
//     );
//   }
  factory ReviewAnswer.fromJson(Map<String, dynamic> json) {
    return ReviewAnswer(
      text: json['text'] ?? "",
      state: json['state'] ?? "",
    );
  }

  @override
  String toString() => 'ReviewAnswer(text: $text, state: $state)';

  @override
  bool operator ==(covariant ReviewAnswer other) {
    if (identical(this, other)) return true;

    return other.text == text && other.state == state;
  }

  @override
  int get hashCode => text.hashCode ^ state.hashCode;
}

class ReviewProductDetails {
  int nmId;
  int imtId;
  String productName;
  String supplierArticle;
  String supplierName;
  String brandName;
  String size;

  ReviewProductDetails({
    required this.nmId,
    required this.imtId,
    required this.productName,
    required this.supplierArticle,
    required this.supplierName,
    required this.brandName,
    required this.size,
  });

  ReviewProductDetails copyWith({
    int? nmId,
    int? imtId,
    String? productName,
    String? supplierArticle,
    String? supplierName,
    String? brandName,
    String? size,
  }) {
    return ReviewProductDetails(
      nmId: nmId ?? this.nmId,
      imtId: imtId ?? this.imtId,
      productName: productName ?? this.productName,
      supplierArticle: supplierArticle ?? this.supplierArticle,
      supplierName: supplierName ?? this.supplierName,
      brandName: brandName ?? this.brandName,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nmId': nmId,
      'imtId': imtId,
      'productName': productName,
      'supplierArticle': supplierArticle,
      'supplierName': supplierName,
      'brandName': brandName,
      'size': size,
    };
  }

  factory ReviewProductDetails.fromMap(Map<String, dynamic> map) {
    return ReviewProductDetails(
      nmId: map['nmId'] as int,
      imtId: map['imtId'] as int,
      productName: map['productName'] as String,
      supplierArticle: map['supplierArticle'] as String,
      supplierName: map['supplierName'] as String,
      brandName: map['brandName'] as String,
      size: map['size'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewProductDetails.fromJson(Map<String, dynamic> json) {
    return ReviewProductDetails(
      imtId: json['imtId'],
      nmId: json['nmId'],
      productName: json['productName'],
      supplierArticle: json['supplierArticle'],
      supplierName: json['supplierName'],
      brandName: json['brandName'],
      size: json['size'],
    );
  }

  @override
  String toString() {
    return 'ReviewProductDetails(nmId: $nmId, imtId: $imtId, productName: $productName, supplierArticle: $supplierArticle, supplierName: $supplierName, brandName: $brandName, size: $size)';
  }

  @override
  bool operator ==(covariant ReviewProductDetails other) {
    if (identical(this, other)) return true;

    return other.nmId == nmId &&
        other.imtId == imtId &&
        other.productName == productName &&
        other.supplierArticle == supplierArticle &&
        other.supplierName == supplierName &&
        other.brandName == brandName &&
        other.size == size;
  }

  @override
  int get hashCode {
    return nmId.hashCode ^
        imtId.hashCode ^
        productName.hashCode ^
        supplierArticle.hashCode ^
        supplierName.hashCode ^
        brandName.hashCode ^
        size.hashCode;
  }
}
