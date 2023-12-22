import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/presentation/single_review_screen/single_review_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/expandable_image.dart';
import 'package:rewild/widgets/my_dialog_save_widget.dart';
import 'package:rewild/widgets/my_dialog_textfield_widget.dart';
import 'package:rewild/widgets/network_image.dart';
import 'package:rewild/widgets/rate_stars.dart';

class SingleReviewScreen extends StatelessWidget {
  const SingleReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    final cardImage = model.cardImage;
    final brandName = review != null ? review.productDetails.brandName : null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MyDialogSaveWidget(
                    onNoPressed: () => print('No'),
                    onYesPressed: () => print('yeas'),
                    title: 'Отправить ответ?',
                  );
                },
              );
            },
            child: SizedBox(
              width: screenWidth * 0.07,
              child: Image.asset(
                IconConstant.iconRedo,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.05,
          ),
          SizedBox(
              width: screenWidth * 0.075,
              child: const Icon(
                Icons.star_outline,
              )),
          SizedBox(
            width: screenWidth * 0.05,
          ),
        ],
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenWidth * 0.30),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05, 0, screenWidth * 0.05, screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (cardImage != null)
                  ReWildNetworkImage(
                    height: screenWidth * 0.25,
                    image: cardImage,
                  ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                if (review != null)
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.productDetails.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        if (brandName != null)
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.01),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.05),
                              ),
                              child: Text(
                                brandName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ))
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: review == null
          ? const EmptyWidget(text: "Что-то пошло не так.")
          : const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    if (review == null) return const SizedBox.shrink();
    final productValuation = review.productValuation;
    final createdDate = review.createdDate;
    final userName = review.userName;
    final reviewText = review.text;

    final photos = review.photoLinks;
    return DefaultTextStyle(
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - screenWidth * 0.30,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.05,
            ),
            child: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RateStars(valuation: productValuation),
                      Text(
                        formatReviewDate(createdDate),
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.3)),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Row(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: screenWidth * 0.7,
                          child: Text(
                            reviewText,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  SizedBox(
                    width: screenWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: photos.map((e) {
                          return Padding(
                            padding: EdgeInsets.only(right: screenWidth * 0.02),
                            child: ReWildExpandableImage(
                              width: screenWidth * 0.2,
                              expandedImagePath: e.fullSize,
                              colapsedImagePath: e.miniSize,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.1),
                  ),
                  SizedBox(
                    height: screenWidth * 0.03,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      "Ответ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  const TextField(
                    maxLines: null,
                    // expands: true,
                    decoration: InputDecoration(
                      hintText: "Введите Ваш ответ на отзыв",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: screenWidth * 0.15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
