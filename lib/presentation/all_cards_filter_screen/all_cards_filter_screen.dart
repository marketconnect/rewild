import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class AllCardsFilterScreen extends StatelessWidget {
  const AllCardsFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsFilterScreenViewModel>();
    final clear = model.clear;
    final save = model.save;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  MainNavigationRouteNames.allCardsScreen,
                );
              },
              icon: Icon(Icons.close,
                  size: model.screenWidth * 0.07,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => clear(),
                child: Text(
                  "Очистить",
                  style: TextStyle(
                      fontSize: model.screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () => save(),
                child: Text(
                  "Сохранить",
                  style: TextStyle(
                      fontSize: model.screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ]),
        resizeToAvoidBottomInset: false,
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsFilterScreenViewModel>();
    final completlyFilledfilter = model.completlyFilledfilter;
    final outputFilter = model.outputfilter;
    // subject
    final setAllSubjects = model.setAllSubjects;
    final setSubject = model.setSubject;
    final clearSubjects = model.clearSubjects;
    final unSetSubject = model.unSetSubject;
    // brand
    final setAllBrands = model.setAllBrands;
    final setBrand = model.setBrand;
    final clearBrands = model.clearBrands;
    final unSetBrand = model.unSetBrand;
    // promo
    final setAllPromos = model.setAllPromos;
    final setPromo = model.setPromo;
    final clearPromos = model.clearPromos;
    final unSetPromo = model.unSetPromo;
    // supplier
    final setAllSuppliers = model.setAllSuppliers;
    final setSupplier = model.setSupplier;
    final clearSuppliers = model.clearSuppliers;
    final unSetSupplier = model.unSetSupplier;

    final counter = model.counter;
    if (completlyFilledfilter == null) {
      return const MyProgressIndicator();
    }
    return SingleChildScrollView(
        child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 5),
            child: Text(
              "Фильтр($counter)",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      if (completlyFilledfilter.subjects != null &&
          completlyFilledfilter.subjects!.isNotEmpty)
        _Grid(
            title: "Предмет",
            items: completlyFilledfilter.subjects!,
            setCallBack: setSubject,
            activeIds: outputFilter!.subjects!.keys.toList(),
            clearCallBack: clearSubjects,
            setAllCallBack: setAllSubjects,
            unSetCallBack: unSetSubject),
      if (completlyFilledfilter.brands != null &&
          completlyFilledfilter.brands!.isNotEmpty)
        _Grid(
            title: "Бренд",
            items: completlyFilledfilter.brands!,
            setCallBack: setBrand,
            activeIds: outputFilter!.brands!.keys.toList(),
            clearCallBack: clearBrands,
            setAllCallBack: setAllBrands,
            unSetCallBack: unSetBrand),
      if (completlyFilledfilter.suppliers != null &&
          completlyFilledfilter.suppliers!.isNotEmpty)
        _Grid(
            title: "Продавец",
            items: completlyFilledfilter.suppliers!,
            setCallBack: setSupplier,
            activeIds: outputFilter!.suppliers!.keys.toList(),
            clearCallBack: clearSuppliers,
            setAllCallBack: setAllSuppliers,
            unSetCallBack: unSetSupplier),
      if (completlyFilledfilter.promos != null &&
          completlyFilledfilter.promos!.isNotEmpty)
        _Grid(
            title: "Акция",
            items: completlyFilledfilter.promos!,
            setCallBack: setPromo,
            activeIds: outputFilter!.promos!.keys.toList(),
            clearCallBack: clearPromos,
            setAllCallBack: setAllPromos,
            unSetCallBack: unSetPromo),
    ]));
  }
}

class _Grid extends StatelessWidget {
  const _Grid(
      {required this.title,
      required this.items,
      required this.activeIds,
      required this.setAllCallBack,
      required this.setCallBack,
      required this.clearCallBack,
      required this.unSetCallBack});
  final Map<int, String> items;
  final List<int> activeIds;
  final String title;

  final void Function(int id) setCallBack;
  final void Function(int id) unSetCallBack;
  final void Function() setAllCallBack;
  final void Function() clearCallBack;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsFilterScreenViewModel>();
    int oneRowLength = 0;
    const oneRowLengthMax = 31;
    List<Row> rows = [];
    List<Widget> content = [];
    final allSelected = activeIds.length == items.length;

    for (final id in items.keys) {
      final isActive = activeIds.contains(id);
      final item = items[id];
      if (item == null || item.isEmpty) {
        continue;
      }

      // if entire row`s length > oneRowLengthMax
      if ((oneRowLength + item.length) > oneRowLengthMax) {
        rows.add(Row(children: content));
        content = [];
        oneRowLength = 0;
      }

      oneRowLength += item.length;
      // append item into content
      content.add(GestureDetector(
          onTap: () => isActive ? unSetCallBack(id) : setCallBack(id),
          child: Container(
            margin: EdgeInsets.all(model.screenWidth * 0.015),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Padding(
                padding: EdgeInsets.all(model.screenWidth * 0.02),
                child: AutoSizeText(
                  item,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: model.screenWidth * 0.04,
                    color: isActive
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )),
          )));
    }
    rows.add(Row(children: content));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: model.screenWidth * 0.95,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: model.screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7)),
                      ),
                      GestureDetector(
                        onTap: () =>
                            allSelected ? clearCallBack() : setAllCallBack(),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            allSelected ? "Очистить" : "Выбрать все",
                            style: TextStyle(
                                fontSize: model.screenWidth * 0.03,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4)),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
            ...rows
          ],
        ),
      ),
    );
  }
}
