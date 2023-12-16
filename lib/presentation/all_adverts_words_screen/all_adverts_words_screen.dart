import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/presentation/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/network_image.dart';

class AllAdvertsWordsScreen extends StatelessWidget {
  const AllAdvertsWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsWordsViewModel>();

    final adverts = model.adverts;
    final autoAdverts = adverts
        .where((advert) => advert.type == AdvertTypeConstants.auto)
        .toList();
    final searchAdverts = adverts
        .where((advert) => advert.type == AdvertTypeConstants.inSearch)
        .toList();
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
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      if (autoAdverts.isNotEmpty)
                        const _Title(text: 'Автоматические'),
                      Column(
                        children: autoAdverts
                            .map(
                              (advert) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      MainNavigationRouteNames
                                          .autoStatWordsScreen,
                                      arguments: advert.campaignId);
                                  return;
                                },
                                child: _Card(
                                  advert: advert,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      if (searchAdverts.isNotEmpty)
                        const _Title(text: 'В поиске'),
                      Column(
                        children: searchAdverts
                            .map(
                              (advert) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      MainNavigationRouteNames
                                          .searchStatWordsScreen,
                                      arguments: advert.campaignId);
                                  return;
                                },
                                child: _Card(
                                  advert: advert,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
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

class _Title extends StatelessWidget {
  const _Title({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          children: [
            Text(text,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.065,
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
      ],
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
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.advert});

  final Advert advert;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsWordsViewModel>();
    final image = model.image(advert.campaignId);
    final subjects = model.subjects[advert.campaignId];
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.14,
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
              blurRadius: 5,
              offset: const Offset(0, 1),
            )
          ],
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.15 / 2),
            ),
            width: screenWidth * 0.17,
            height: screenWidth * 0.17,
            child: ClipOval(
              child: Stack(
                children: [
                  Positioned(
                    child: ReWildNetworkImage(
                      image: image,
                      width: screenWidth * 0.17,
                      height: screenWidth * 0.17,
                    ),
                    // SizedBox(
                    //   width: screenWidth * 0.17,
                    //   height: screenWidth * 0.17,
                    //   child: CachedNetworkImage(
                    //     imageUrl: image,
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.05,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  advert.name,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: AutoSizeText(
                  subjects == null ? "" : subjects.join(', '),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.02,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
