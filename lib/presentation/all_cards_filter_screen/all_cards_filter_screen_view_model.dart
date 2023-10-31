import 'package:flutter/material.dart';
import 'package:rewild/core/utils/resource.dart';
import 'package:rewild/domain/entities/filter_model.dart';

// filter
abstract class AllCardsFilterAllCardsFilterService {
  Future<Resource<FilterModel>> getCompletlyFilledFilter();
  Future<Resource<void>> setFilter(FilterModel filter);
}

class AllCardsFilterScreenViewModel extends ChangeNotifier {
  final AllCardsFilterAllCardsFilterService allCardsFilterService;
  final BuildContext context;
  AllCardsFilterScreenViewModel(
      {required this.context, required this.allCardsFilterService}) {
    _asyncInit();
  }

  FilterModel? _filter;
  FilterModel? get filter => _filter;

  void _asyncInit() async {
    final filter =
        await _fetch(() => allCardsFilterService.getCompletlyFilledFilter());
    if (filter == null) {
      return;
    }

    _filter = filter;
    notifyListeners();
  }

  // Define a method for fetch data and handling errors
  Future<T?> _fetch<T>(Future<Resource<T>> Function() callBack) async {
    final resource = await callBack();
    if (resource is Error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(resource.message!),
      ));
      return null;
    }
    return resource.data;
  }
}
