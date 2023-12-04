class Question {
  String id;
  String text;
  DateTime createdDate;
  String state;
  String answer;
  ProductDetails productDetails;
  bool wasViewed;
  bool isOverdue;

  Question({
    required this.id,
    required this.text,
    required this.createdDate,
    required this.state,
    required this.answer,
    required this.productDetails,
    required this.wasViewed,
    required this.isOverdue,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      createdDate: DateTime.parse(json['createdDate']),
      state: json['state'],
      answer: json['answer'],
      productDetails: ProductDetails.fromJson(json['productDetails']),
      wasViewed: json['wasViewed'],
      isOverdue: json['isOverdue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdDate': createdDate.toIso8601String(),
      'state': state,
      'answer': answer,
      'productDetails': productDetails.toJson(),
      'wasViewed': wasViewed,
      'isOverdue': isOverdue,
    };
  }
}

class ProductDetails {
  int imtId;
  int nmId;
  String productName;
  String supplierArticle;
  String supplierName;
  String brandName;

  ProductDetails({
    required this.imtId,
    required this.nmId,
    required this.productName,
    required this.supplierArticle,
    required this.supplierName,
    required this.brandName,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      imtId: json['imtId'],
      nmId: json['nmId'],
      productName: json['productName'],
      supplierArticle: json['supplierArticle'],
      supplierName: json['supplierName'],
      brandName: json['brandName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imtId': imtId,
      'nmId': nmId,
      'productName': productName,
      'supplierArticle': supplierArticle,
      'supplierName': supplierName,
      'brandName': brandName,
    };
  }
}
