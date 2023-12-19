import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild/core/constants/image_constant.dart';

import 'package:rewild/presentation/all_products_feedback_screen/all_products_feedback_view_model.dart';

import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';
import 'package:rewild/widgets/popum_menu_item.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class AllProductsFeedbackScreen extends StatefulWidget {
  const AllProductsFeedbackScreen({super.key});

  @override
  State<AllProductsFeedbackScreen> createState() =>
      _AllProductsFeedbackScreenState();
}

class _AllProductsFeedbackScreenState extends State<AllProductsFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllProductsFeedbackViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final apiKeyexists = model.apiKeyExists;
    final isReviewsLoading = model.isReviewsLoading;
    final isQuestionsLoading = model.isQuestionsLoading;
    final reviewQty = model.reviewQty;
    final questionsQty = model.questionsQty;
    final onClose = model.onClose;
    Set<int> itemsIdsList = {};
    final setIsReview = model.setIsReviews;
    final isReviews = model.isReviews;
    if (isReviews) {
      itemsIdsList = model.reviews;
    } else {
      itemsIdsList = model.questions;
    }

    final getImages = model.getImage;
    final getNewQuestionsQty = model.unansweredQuestionsQty;
    final getNewReviewsQty = model.unansweredReviewsQty;
    final prevUnansweredReviewsQty = model.prevUnansweredReviewsQty;
    final getallQuestionsQty = model.allQuestionsQty;
    final getallReviewsQty = model.allReviewsQty;
    final getSupplierArticle = model.getSupplierArticle;
    final goTo = model.goTo;

    // filter by period
    final setPeriod = model.setPeriod;
    final period = model.period;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await onClose();
          },
        ),
        // centerTitle: true,
        // title:
        actions: [
          if (apiKeyexists)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isReviews
                    ? Text('Отзывы',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05))
                    : Text('Вопросы',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.05)),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                Switch(
                    value: isReviews,
                    onChanged: (value) {
                      // setState(() {
                      //   isReviews = value;
                      // });
                      setIsReview(value);
                    }),
                SizedBox(
                  width: screenWidth * 0.15,
                ),
              ],
            ),
          PopupMenuButton(
            // Menu ============================================ Menu
            onSelected: (value) => setPeriod(context, value),
            icon: Icon(
              Icons.menu,
              size: MediaQuery.of(context).size.width * 0.1,
              color: isReviews
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'w',
                  child: ReWildPopumMenuItemChild(
                    text: "За неделю",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'w' ? const Icon(Icons.check) : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'm',
                  child: ReWildPopumMenuItemChild(
                    text: "За месяц",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'm' ? const Icon(Icons.check) : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'a',
                  child: ReWildPopumMenuItemChild(
                    text: "За все время",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'a' ? const Icon(Icons.check) : null,
                    ),
                  ),
                )
              ];
            },
          ),
        ],
      ),
      body: !apiKeyexists
          ? const EmptyWidget(
              text: 'Создайте API ключ, чтобы видеть вопросы',
            )
          : (isReviewsLoading && isReviews) ||
                  (isQuestionsLoading && !isReviews)
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MyProgressIndicator(),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Text(
                        "Загружено ${isReviews ? reviewQty : questionsQty} ${isReviews ? "отзыва" : "вопроса"}")
                  ],
                ))
              : SingleChildScrollView(
                  child: Column(children: [
                    Column(
                      children: itemsIdsList.toList().map((e) {
                        return _ProductCard(
                          nmId: e,
                          image: getImages(e),
                          goTo: goTo,
                          newItemsQty: isReviews
                              ? getNewReviewsQty(e)
                              : getNewQuestionsQty(e),
                          supplierArticle: getSupplierArticle(e),
                          isReview: isReviews,
                          prevUnansweredQty: prevUnansweredReviewsQty(e),
                          oldItemsQty: isReviews
                              ? getallReviewsQty(e)
                              : getallQuestionsQty(e),
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
      required this.newItemsQty,
      required this.nmId,
      required this.oldItemsQty,
      required this.goTo,
      required this.supplierArticle,
      required this.prevUnansweredQty,
      this.isReview = false});
  final int nmId;
  final String image;
  final String supplierArticle;
  final int newItemsQty;
  final int prevUnansweredQty;
  final int oldItemsQty;
  final bool isReview;
  final Function(int nmId) goTo;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => goTo(nmId),
      child: Container(
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
        child: AspectRatio(
          aspectRatio: 10 / 3,
          child: SizedBox(
            width: screenWidth,
            child: Stack(
              children: [
                Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: (image.isEmpty)
                          ? Image.asset(ImageConstant.taken,
                              fit: BoxFit.scaleDown)
                          : ReWildNetworkImage(
                              width: screenWidth * 0.33, image: image),
                    ),
                    SizedBox(
                      width: screenWidth * 0.05,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Text(
                            supplierArticle,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Всего ${isReview ? "отзывов" : "вопросов"}: $oldItemsQty',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: newItemsQty == 0
                              ? null
                              : EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                          decoration: newItemsQty == 0
                              ? null
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width * 0.01),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          child: Text(
                            'Без ответа: $newItemsQty',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: newItemsQty > 0
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.7),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(right: 0, child: Text('$prevUnansweredQty'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
