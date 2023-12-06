import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/constants.dart';

import 'package:rewild/presentation/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';

import 'package:rewild/widgets/progress_indicator.dart';

class AllAdvertsStatScreen extends StatelessWidget {
  const AllAdvertsStatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsStatScreenViewModel>();
    final loading = model.loading;

    final adverts = model.adverts;
    final apiKeyExists = model.apiKeyExists;
    final cpm = model.cpm;
    final images = model.images;
    final budget = model.budget;

    return SafeArea(
        child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Статистика",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.97),
      body: loading
          ? const MyProgressIndicator()
          : !apiKeyExists
              ? const EmptyWidget(text: "Вы не добавили ни одного токена")
              : Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: ListView.builder(
                      itemCount: adverts.length,
                      itemBuilder: (context, index) {
                        final advert = adverts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              MainNavigationRouteNames.singleAdvertStatsScreen,
                              arguments: advert.campaignId,
                            );
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10),
                              child: Column(
                                children: [
                                  Container(
                                    width: model.screenWidth,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.1),
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(2)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.007,
                                        ),
                                        _TopRow(
                                            images: images(advert.campaignId),
                                            name: advert.name,
                                            advType: advert.type),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.007,
                                        ),
                                        Divider(
                                          height: 0.5,
                                          thickness: 1.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.1),
                                        ),
                                        _BottomRow(
                                          budget: budget(advert.campaignId),
                                          cpm: cpm(advert.campaignId),
                                          status: advert.status,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        );
                      }),
                ),
    ));
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.advType,
    required this.name,
    required this.images,
  });

  final int advType;
  final String name;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: screenHeight * 0.015,
              ),
              SizedBox(
                width: screenWidth * 0.7,
                height: screenHeight * 0.03,
                child: AutoSizeText(
                  name,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.7,
                height: screenHeight * 0.03,
                child: AutoSizeText(
                  "Раздел: ${NumericConstants.advTypes[advType]}",
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5)),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.015,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.005),
            child: SizedBox(
              width: screenWidth * 0.2,
              height: screenWidth * 0.15,
              child: Stack(
                children: images
                    .map((e) => Positioned(
                          right: images.indexOf(e) * screenWidth * 0.06,
                          child: ReWildNetworkImage(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            fit: BoxFit.contain,
                            image: e,
                          ),
                          // SizedBox(
                          //     width: screenWidth * 0.15,
                          //     height: screenWidth * 0.15,
                          //     child: CachedNetworkImage(
                          //       imageUrl: e,
                          //       fit: BoxFit.contain,
                          //     )),
                        ))
                    .toList(),
                // [
                // SizedBox(
                //     width: screenWidth * 0.15,
                //     height: screenWidth * 0.15,
                //     child: CachedNetworkImage(
                //       imageUrl: image,
                //       fit: BoxFit.contain,
                //     ))
                // ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow(
      {required this.status, required this.cpm, required this.budget});

  final int status;
  final String cpm;
  final int? budget;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cpmText = 'Цена: $cpm';
    // final

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.007,
                ),
                Text(cpmText,
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5))),
                Text(budget == null ? '' : 'Бюджет: $budget',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5))),
                SizedBox(
                  height: screenHeight * 0.007,
                ),
              ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.005,
              ),
              child: Text(
                '${NumericConstants.advStatus[status]}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.015,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(
              width: screenWidth * 0.02,
            ),
          ],
        )
      ],
    );
  }
}
