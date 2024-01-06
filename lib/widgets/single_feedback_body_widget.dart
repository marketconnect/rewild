import 'package:flutter/material.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/domain/entities/review_model.dart';
import 'package:rewild/domain/entities/spell_result.dart';
import 'package:rewild/widgets/expandable_image.dart';
import 'package:rewild/widgets/rate_stars.dart';
import 'package:rewild/widgets/rewild_text_editing_controller.dart';

class SingleFeedbackBody extends StatefulWidget {
  final int? productValuation;
  final bool isAnswered;
  final DateTime createdDate;
  final String? userName;
  final String text;
  final String? content;
  final List<String> listOfTemplates;
  final List<PhotoLink> photos;
  final Function(String) setAnswer;
  final Future<List<SpellResult>> Function(String) checkSpell;
  final List<SpellResult> initSpellResults;

  const SingleFeedbackBody({
    super.key,
    this.productValuation,
    this.userName,
    this.content,
    this.isAnswered = false,
    required this.createdDate,
    required this.checkSpell,
    required this.text,
    this.photos = const [],
    this.listOfTemplates = const [],
    required this.setAnswer,
    required this.initSpellResults,
  });

  @override
  _SingleFeedbackBodyState createState() => _SingleFeedbackBodyState();
}

class _SingleFeedbackBodyState extends State<SingleFeedbackBody> {
  RewildTextEdittingController _controller = RewildTextEdittingController();
  final List<String> listErrorTexts = [];

  final List<String> listTexts = [];

  @override
  void initState() {
    _controller = RewildTextEdittingController(listErrorTexts: listErrorTexts);
    super.initState();
  }

  void _handleOnChange(String text) {
    widget.setAnswer(text);
    widget.checkSpell(text).then((value) {
      listErrorTexts.clear();
      listErrorTexts.addAll(value.map((e) => e.word));
    });
  }

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
                      if (widget.productValuation != null)
                        RateStars(valuation: widget.productValuation!),
                      Text(
                        formatReviewDate(widget.createdDate),
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
                  if (widget.userName != null)
                    Row(
                      children: [
                        Text(
                          widget.userName!,
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
                            widget.text,
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
                        children: widget.photos.map((e) {
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
                  !widget.isAnswered
                      ? Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus) {
                              _handleOnChange(_controller.text);
                            }
                          },
                          child: TextFormField(
                              controller: _controller,
                              onChanged: _handleOnChange,
                              minLines: 5,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)))),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.content ?? "",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: screenWidth * 0.15,
                  ),
                  if (widget.listOfTemplates.isNotEmpty)
                    Container(
                      width: screenWidth * 0.7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: GestureDetector(
                        onTap: () => _showTemplatesBottomSheet(context),
                        child: Text(
                          "Использвать шаблон",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: screenWidth * 0.05),
                        ),
                      ),
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          itemCount: widget.listOfTemplates.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(widget.listOfTemplates[index]),
              onTap: () {
                _controller.text = widget.listOfTemplates[index];
                _handleOnChange(widget.listOfTemplates[index]);
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }
}
