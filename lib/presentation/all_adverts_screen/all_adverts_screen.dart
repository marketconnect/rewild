import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/presentation/all_adverts_screen/all_adverts_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class AllAdvertsScreen extends StatelessWidget {
  const AllAdvertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsScreenViewModel>();
    final loading = model.loading;
    final adverts = model.adverts;
    final apiKeyExists = model.apiKeyExists;
    final image = model.image;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: const Text("Кампании")),
      body: loading
          ? const MyProgressIndicator()
          : !apiKeyExists
              ? const EmptyWidget(text: "Вы не добавили ни одного токена")
              : ListView.builder(
                  itemCount: adverts.length,
                  itemBuilder: (context, index) {
                    final advert = adverts[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        MainNavigationRouteNames.singleCardScreen,
                        arguments: advert.advertId,
                      ),
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
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(2)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _TopRow(
                                        image: image(advert.advertId),
                                        name: advert.name,
                                        advType: advert.type),
                                    Divider(
                                      height: 0.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.1),
                                    ),
                                    _BottomRow(
                                      startTime: advert.startTime,
                                      endTime: advert.changeTime,
                                      status: advert.status,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )),
                    );
                  }),
    ));
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.advType,
    required this.name,
    required this.image,
  });

  // final List<SellerModel> sellers;
  final int advType;
  final String name;
  final String image;

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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          SizedBox(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.contain,
              )),
          // SizedBox(
          //   height: screenHeight * 0.015,
          // ),
        ],
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow(
      {required this.startTime, required this.endTime, required this.status});
  final DateTime startTime;
  final DateTime endTime;
  final int status;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    Color textColor = Theme.of(context).colorScheme.error;

    if (status == 4) {
      textColor = Theme.of(context).colorScheme.outline;
    } else if (status == 9) {
      textColor = const Color(0xFF00dd61);
    } else if (status == 11) {
      textColor = Theme.of(context).colorScheme.primary;
    }

    final startOrFinishedAt = status == 11 ? endTime : startTime;
    final startedOrFinishedAt = isIntraday(startOrFinishedAt)
        ? '${startOrFinishedAt.hour}:${startOrFinishedAt.minute}'
        : "${startOrFinishedAt.day > 9 ? startOrFinishedAt.day : "0${startOrFinishedAt.day}"}.${startOrFinishedAt.month > 9 ? startOrFinishedAt.month : "0${startOrFinishedAt.month}"}.${startOrFinishedAt.year}";
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
                Text('',
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5))),
                Text(startedOrFinishedAt,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
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
                    color: textColor),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.015,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: textColor,
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
