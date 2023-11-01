import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/all_cards_filter_screen/all_cards_filter_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

class AllCardsFilterScreen extends StatelessWidget {
  const AllCardsFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: const Text(
              'Фильтр()',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1f1f1f),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => print("aaa"),
                icon: const Icon(Icons.done),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    MainNavigationRouteNames.allCardsScreen,
                  );
                },
                icon: const Icon(Icons.close),
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
    final setSubject = model.setSubject;
    final unSetSubject = model.unSetSubject;
    final setPromo = model.setPromo;
    final unSetPromo = model.unSetPromo;
    final setBrand = model.setBrand;
    final unSetBrand = model.unSetBrand;
    final setSupplier = model.setSupplier;
    final unSetSupplier = model.unSetSupplier;
    print('subjects here ${completlyFilledfilter!.subjects}');
    if (completlyFilledfilter == null) {
      return const CircularProgressIndicator();
    }
    return SingleChildScrollView(
        child: Column(children: [
      if (completlyFilledfilter.subjects != null &&
          completlyFilledfilter.subjects!.isNotEmpty)
        _Grid(
            title: "Предмет",
            items: completlyFilledfilter.subjects!,
            setCallBack: setSubject,
            activeIds: outputFilter!.subjects!.keys.toList(),
            unSetCallBack: unSetSubject),
      if (completlyFilledfilter.brands != null &&
          completlyFilledfilter.brands!.isNotEmpty)
        _Grid(
            title: "Бренд",
            items: completlyFilledfilter.brands!,
            setCallBack: setBrand,
            activeIds: outputFilter!.brands!.keys.toList(),
            unSetCallBack: unSetBrand),
      if (completlyFilledfilter.suppliers != null &&
          completlyFilledfilter.suppliers!.isNotEmpty)
        _Grid(
            title: "Продавец",
            items: completlyFilledfilter.suppliers!,
            setCallBack: setSupplier,
            activeIds: outputFilter!.suppliers!.keys.toList(),
            unSetCallBack: unSetSupplier),
      if (completlyFilledfilter.promos != null &&
          completlyFilledfilter.promos!.isNotEmpty)
        _Grid(
            title: "Акция",
            items: completlyFilledfilter.promos!,
            setCallBack: setPromo,
            activeIds: outputFilter!.promos!.keys.toList(),
            unSetCallBack: unSetPromo),
    ]));
  }
}

class _Grid extends StatelessWidget {
  const _Grid(
      {required this.title,
      required this.items,
      required this.activeIds,
      required this.setCallBack,
      required this.unSetCallBack});
  final Map<int, String> items;
  final void Function(int id) setCallBack;
  final void Function(int id) unSetCallBack;
  final List<int> activeIds;
  final String title;
  @override
  Widget build(BuildContext context) {
    int oneRowLength = 0;
    const oneRowLengthMax = 31;
    List<Row> rows = [];
    List<Widget> content = [];

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
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.015),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                child: item.length > oneRowLengthMax
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: AutoSizeText(
                          item.substring(0, oneRowLengthMax),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: isActive
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      )
                    : AutoSizeText(
                        item,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: isActive
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )),
          )));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
              )
            ]),
          ),
          ...rows
        ],
      ),
    );
  }
}
