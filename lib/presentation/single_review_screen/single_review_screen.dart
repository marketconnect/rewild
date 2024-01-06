import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';

import 'package:rewild/presentation/single_review_screen/single_review_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';

import 'package:rewild/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild/widgets/network_image.dart';

import 'package:rewild/widgets/single_feedback_body_widget.dart';

class SingleReviewScreen extends StatelessWidget {
  const SingleReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    if (review == null) return const EmptyWidget(text: "Что-то пошло не так.");
    final cardImage = model.cardImage;
    final brandName = review.productDetails.brandName;
    final publish = model.publish;
    final productValuation = review.productValuation;
    final createdDate = review.createdDate;
    final userName = review.userName;
    final reviewText = review.text;
    final setAnswer = model.setAnswer;
    final checkSpellText = model.checkSpellText;
    final photos = review.photoLinks;
    final storedAnswers = model.storedAnswers;
    final spellResults = model.spellResults;
    final isAnswered = model.isAnswered;
    final answerText = model.answer;
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
                  return MyDialogHeaderAndTwoBtnsWidget(
                    onNoPressed: () => Navigator.of(context).pop(),
                    onYesPressed: () async {
                      await publish();
                      Navigator.of(context).pop();
                    },
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
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
      body: SingleFeedbackBody(
        createdDate: createdDate,
        text: reviewText,
        listOfTemplates: storedAnswers ?? [],
        content: answerText,
        checkSpell: checkSpellText,
        isAnswered: isAnswered,
        setAnswer: setAnswer,
        photos: photos,
        productValuation: productValuation,
        userName: userName,
        initSpellResults: spellResults,
      ),
    );
  }
}
