import 'package:rewild/domain/entities/stocks_model.dart';

class SizeModel {
  int optionId;
  List<StocksModel> stocks;

  SizeModel({
    this.optionId = 0,
    required this.stocks,
  });
}
