class Question {
  String id;
  String text;
  DateTime createdDate;
  String state;
  Answer? answer;
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
    print("fromJson $json");
    return Question(
      id: json['id'] ?? "",
      text: json['text'] ?? "",
      createdDate: DateTime.tryParse(json['createdDate']) ?? DateTime.now(),
      state: json['state'] ?? "",
      answer: json['answer'] == null ? null : Answer.fromJson(json['answer']),
      productDetails: ProductDetails.fromJson(json['productDetails']),
      wasViewed: json['wasViewed'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
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

class Answer {
  final String text;

  final bool editable;

  final String createDate;

  Answer(
      {required this.text, required this.editable, required this.createDate});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'editable': editable,
      'createDate': createDate,
    };
  }

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      text: json['text'] ?? "",
      editable: json['editable'] ?? false,
      createDate: json['createDate'] ?? "",
    );
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
