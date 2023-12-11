import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/image_constant.dart';
import 'package:rewild/core/utils/extensions/date_time.dart';

import 'package:rewild/presentation/all_products_reviews_screen/all_products_reviews_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class AllProductsReviewsScreen extends StatefulWidget {
  const AllProductsReviewsScreen({super.key});

  @override
  State<AllProductsReviewsScreen> createState() =>
      _AllProductsReviewsScreenState();
}

class _AllProductsReviewsScreenState extends State<AllProductsReviewsScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllProductsReviewsViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final apiKeyexists = model.apiKeyExists;
    final reviews = model.reviewsRatings;
    final getImages = model.getImage;
    final getNewQuestionsQty = model.newRewviewsQty;
    final getallQuestionsQty = model.allReviewsQty;
    final getSupplierArticle = model.getSupplierArticle;
    final beforeMonthAgoReviewsRatings = model.beforeMonthAgoReviewsRatings;
    final before3MonthAgoReviewsRatings = model.before3MonthAgoReviewsRatings;
    final beforeWeekAgoReviewsRatings = model.beforeWeekAgoReviewsRatings;
    final isLoading = model.loading;
    final reviewQty = model.reviewQty;
    final threeMonthsAgoDateString =
        DateTime.now().subtract(const Duration(days: 90)).formatDate(true);
    final monthAgoDateString =
        DateTime.now().subtract(const Duration(days: 30)).formatDate(true);
    final weekAgoDateString =
        DateTime.now().subtract(const Duration(days: 7)).formatDate(true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: !apiKeyexists
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                  ),
                  Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      }),
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  isSwitched
                      ? Text('Новые',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05))
                      : Text('Все',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05)),
                ],
              ),
      ),
      body: !apiKeyexists
          ? const EmptyWidget(
              text: 'Создайте API ключ, чтобы видеть вопросы',
            )
          : isLoading
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MyProgressIndicator(),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Text("Загружено $reviewQty отзывов")
                  ],
                ))
              : SingleChildScrollView(
                  child: Column(children: [
                    Column(
                      children: reviews.entries.map((e) {
                        if (isSwitched) {
                          return (getNewQuestionsQty(e.key) > 0)
                              ? _ProductCard(
                                  nmId: e.key,
                                  image: getImages(e.key),
                                  newQuetions: getNewQuestionsQty(e.key),
                                  reviewsRatings: e.value,
                                  monthAgoDateString: monthAgoDateString,
                                  weekAgoDateString: weekAgoDateString,
                                  threeMonthsAgoDateString:
                                      threeMonthsAgoDateString,
                                  ratingBeforeMonthAgo:
                                      beforeMonthAgoReviewsRatings(e.key),
                                  ratingBeforeWeekAgo:
                                      beforeWeekAgoReviewsRatings(e.key),
                                  ratingBefore3MonthAgo:
                                      before3MonthAgoReviewsRatings(e.key),
                                  supplierArticle: getSupplierArticle(e.key),
                                  oldQuetions: getallQuestionsQty(e.key),
                                )
                              : Container();
                        }
                        return _ProductCard(
                          nmId: e.key,
                          image: getImages(e.key),
                          newQuetions: getNewQuestionsQty(e.key),
                          reviewsRatings: e.value,
                          monthAgoDateString: monthAgoDateString,
                          weekAgoDateString: weekAgoDateString,
                          threeMonthsAgoDateString: threeMonthsAgoDateString,
                          ratingBeforeMonthAgo:
                              beforeMonthAgoReviewsRatings(e.key),
                          ratingBeforeWeekAgo:
                              beforeWeekAgoReviewsRatings(e.key),
                          ratingBefore3MonthAgo:
                              before3MonthAgoReviewsRatings(e.key),
                          supplierArticle: getSupplierArticle(e.key),
                          oldQuetions: getallQuestionsQty(e.key),
                        );
                      }).toList(),
                    )
                  ]),
                ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {required this.image,
      required this.newQuetions,
      required this.nmId,
      required this.reviewsRatings,
      required this.oldQuetions,
      required this.weekAgoDateString,
      required this.monthAgoDateString,
      required this.threeMonthsAgoDateString,
      required this.ratingBeforeMonthAgo,
      required this.ratingBefore3MonthAgo,
      required this.ratingBeforeWeekAgo,
      required this.supplierArticle});
  final int nmId;
  final String image;
  final String supplierArticle;
  final String threeMonthsAgoDateString;
  final String monthAgoDateString;
  final String weekAgoDateString;
  final int newQuetions;
  final int oldQuetions;
  final double ratingBeforeMonthAgo;
  final double ratingBefore3MonthAgo;
  final double ratingBeforeWeekAgo;
  final Map<int, int> reviewsRatings;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int averageRate = 0;
    int qty = 0;

    reviewsRatings.forEach((key, value) {
      averageRate += key * value;
      qty += value;
    });

    final rating = averageRate / qty;
    final averageRateString = rating.toStringAsFixed(2);

    // Week
    // final difWeek = rating - ratingBeforeWeekAgo;
    // final progressWeek = difWeek.toStringAsFixed(2);

    // Month
    // final difMonth = rating - ratingBeforeMonthAgo;
    // final progressMonth = difMonth.toStringAsFixed(2);

    // 3 Month
    // final dif3Month = rating - ratingBefore3MonthAgo;
    // final progress3Month = dif3Month.toStringAsFixed(2);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
          MainNavigationRouteNames.allQuestionsScreen,
          arguments: nmId),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.1),
            ),
          ),
          // borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            (image.isEmpty)
                ? Image.asset(ImageConstant.taken, fit: BoxFit.scaleDown)
                : ReWildNetworkImage(width: screenWidth * 0.2, image: image),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    supplierArticle,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Всего отзывов: $oldQuetions',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: newQuetions == 0
                        ? null
                        : EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.01,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                          ),
                    decoration: newQuetions == 0
                        ? null
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.01),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    child: Text(
                      'Новых: $newQuetions',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: newQuetions > 0
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.7),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(children: [
                          if (reviewsRatings[5] != null)
                            Row(
                              children: [
                                buildRate(screenWidth * 0.03, 5,
                                    Theme.of(context).colorScheme.primary),
                                Text(
                                  ' ${reviewsRatings[5]}',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (reviewsRatings[4] != null)
                            Row(
                              children: [
                                buildRate(screenWidth * 0.03, 4,
                                    Theme.of(context).colorScheme.primary),
                                Text(
                                  ' ${reviewsRatings[4]}',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (reviewsRatings[3] != null)
                            Row(
                              children: [
                                buildRate(screenWidth * 0.03, 3,
                                    Theme.of(context).colorScheme.primary),
                                Text(
                                  ' ${reviewsRatings[3]}',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (reviewsRatings[2] != null)
                            Row(
                              children: [
                                buildRate(screenWidth * 0.03, 2,
                                    Theme.of(context).colorScheme.primary),
                                Text(
                                  ' ${reviewsRatings[2]}',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (reviewsRatings[1] != null)
                            Row(children: [
                              buildRate(screenWidth * 0.03, 1,
                                  Theme.of(context).colorScheme.primary),
                              Text(
                                ' ${reviewsRatings[1]}',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.8),
                                    fontWeight: FontWeight.w500),
                              )
                            ]),
                        ]),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if ((ratingBeforeMonthAgo > 0) ||
                                (ratingBefore3MonthAgo > 0) ||
                                (ratingBeforeWeekAgo > 0))
                              _HistoryWidget(
                                screenWidth: screenWidth,
                                monthAgo: ratingBeforeMonthAgo,
                                threeMonthsAgo: ratingBefore3MonthAgo,
                                monthAgoDateString: monthAgoDateString,
                                threeMonthsAgoDateString:
                                    threeMonthsAgoDateString,
                                weekAgoDateString: weekAgoDateString,
                                weekAgo: ratingBeforeWeekAgo,
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0, right: 8.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.01,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.01),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(
                                  averageRateString,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRate(double size, int n, Color color) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: size,
          color: color,
        ),
        Icon(Icons.star, size: size, color: n > 1 ? color : Colors.transparent),
        Icon(Icons.star, size: size, color: n > 2 ? color : Colors.transparent),
        Icon(Icons.star, size: size, color: n > 3 ? color : Colors.transparent),
        Icon(Icons.star, size: size, color: n > 4 ? color : Colors.transparent),
      ],
    );
  }
}

class _HistoryWidget extends StatelessWidget {
  const _HistoryWidget({
    required this.screenWidth,
    required this.weekAgo,
    required this.monthAgo,
    required this.threeMonthsAgoDateString,
    required this.weekAgoDateString,
    required this.monthAgoDateString,
    required this.threeMonthsAgo,
  });

  final double screenWidth;
  final double weekAgo;
  final String weekAgoDateString;
  final double monthAgo;
  final String monthAgoDateString;
  final double threeMonthsAgo;
  final String threeMonthsAgoDateString;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'История',
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
          ),
          _HistoryWidgetRow(
              agoDateString: threeMonthsAgoDateString,
              agoValue: threeMonthsAgo),
          _HistoryWidgetRow(
              agoDateString: monthAgoDateString, agoValue: monthAgo),
          _HistoryWidgetRow(
              agoDateString: weekAgoDateString, agoValue: weekAgo),
        ],
      ),
    );
  }
}

class _HistoryWidgetRow extends StatelessWidget {
  const _HistoryWidgetRow({
    required this.agoDateString,
    required this.agoValue,
  });

  final String agoDateString;
  final double agoValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          agoDateString,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Text(
          agoValue.toStringAsFixed(2),
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
        ),
      ],
    );
  }
}
