import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/domain/entities/advert_model.dart';
import 'package:rewild/presentation/all_adverts_tools_screen/all_adverts_tools_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

class AllAdvertsToolsScreen extends StatelessWidget {
  const AllAdvertsToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsToolsViewModel>();
    final selectedType = model.selectedAdvertType;
    final autoAdverts = model.adverts;
    final autoAdvertsWithType =
        autoAdverts.where((advert) => advert.type == selectedType).toList();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _AppBar(),
                const _HorizontalMenu(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: autoAdvertsWithType
                        .map(
                          (advert) => GestureDetector(
                            onTap: () {
                              if (advert.type == AdvertTypeConstants.auto) {
                                Navigator.of(context).pushNamed(
                                    MainNavigationRouteNames
                                        .autoStatWordsScreen,
                                    arguments: advert.campaignId);
                                return;
                              } else if (advert.type ==
                                      AdvertTypeConstants.inSearch ||
                                  advert.type ==
                                      AdvertTypeConstants.searchPlusCatalog) {
                                Navigator.of(context).pushNamed(
                                    MainNavigationRouteNames
                                        .searchStatWordsScreen,
                                    arguments: advert.campaignId);
                                return;
                              }
                            },
                            child: _Card(
                              advert: advert,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Text(
            'Настройки',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.065,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.advert});

  final AdvertInfoModel advert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            )
          ],
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Название",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  advert.name,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: MediaQuery.of(context).size.width * 0.04,
            ),
          )
        ],
      ),
    );
  }
}

class _HorizontalMenu extends StatelessWidget {
  const _HorizontalMenu();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsToolsViewModel>();
    final selectedType = model.selectedAdvertType;
    final select = model.selectAdvertType;
    final existingTypes = model.existingAdvertsTypes();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: ListView(
        physics: const BouncingScrollPhysics(), //<--here

        scrollDirection: Axis.horizontal,
        children: AdvertTypeNameConstants.names.entries
            .where((element) => existingTypes.contains(element.value))
            .map((e) {
          final isSelected = e.value == selectedType;
          return GestureDetector(
            onTap: () => select(e.value),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                  spreadRadius: 0,
                  blurStyle: BlurStyle.outer,
                  blurRadius: 5,
                  offset: const Offset(0, 1), // changes position of shadow
                )
              ], borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(e.key,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.5),
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
