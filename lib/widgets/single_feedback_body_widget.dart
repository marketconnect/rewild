import 'package:flutter/material.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/widgets/expandable_image.dart';
import 'package:rewild/widgets/rate_stars.dart';

class SingleFeedbackBody extends StatelessWidget {
  final int? productValuation;
  final DateTime createdDate;
  final String? userName;
  final String text;
  final List<String> listOfTemplates;
  final List<PhotoLink> photos;
  final Function(String) setAnswer;

  const SingleFeedbackBody({
    super.key,
    this.productValuation,
    this.userName,
    required this.createdDate,
    required this.text,
    this.photos = const [],
    this.listOfTemplates = const [],
    required this.setAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTextStyle(
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - screenWidth * 0.30,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.05),
            child: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (productValuation != null)
                        RateStars(valuation: productValuation!),
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
                  if (userName != null)
                    Row(
                      children: [
                        Text(
                          userName!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
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
                            text,
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
                  TextField(
                    onChanged: (value) => setAnswer(value),
                    maxLines: null,
                    // expands: true,
                    decoration: const InputDecoration(
                      hintText: "Введите Ваш ответ на отзыв",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: screenWidth * 0.15,
                  ),
                  if (listOfTemplates.isNotEmpty)
                    ElevatedButton(
                      onPressed: () => _showTemplatesBottomSheet(context),
                      child: const Text("Шаблоны"),
                    ),
                  SizedBox(height: screenWidth * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTemplatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: listOfTemplates.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(listOfTemplates[index]),
              onTap: () {
                // Handle the template selection
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }
}
