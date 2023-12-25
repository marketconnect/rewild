import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

import 'package:rewild/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild/widgets/network_image.dart';
import 'package:rewild/widgets/single_feedback_body_widget.dart';

class SingleQuestionScreen extends StatelessWidget {
  const SingleQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleQuestionViewModel>();
    final question = model.question;

    final cardImage = model.cardImage;
    final brandName = question.productDetails.brandName;
    final publish = model.publish;
    // final productValuation = question.productValuation;
    final createdDate = question.createdDate;
    // final userName = question.userName;
    final storedAnswers = model.storedAnswers;
    final reviewText = question.text;
    final setAnswer = model.setAnswer;

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
                    onYesPressed: () => publish(),
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
                        question.productDetails.productName,
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
        setAnswer: setAnswer,
      ),
    );
  }
}


// class SingleQuestionScreen extends StatefulWidget {
//   const SingleQuestionScreen({Key? key}) : super(key: key);

//   @override
//   _SingleQuestionScreenState createState() => _SingleQuestionScreenState();
// }

// class _SingleQuestionScreenState extends State<SingleQuestionScreen> {
//   late TextEditingController controller;
//   late TextEditingController dropdownController;

//   @override
//   void initState() {
//     super.initState();
//     final model = context.read<SingleQuestionViewModel>();
//     controller =
//         TextEditingController(text: model.question.reusedAnswerText ?? '');
//     dropdownController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     dropdownController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<SingleQuestionViewModel>();
//     final questionText = model.question.text;
//     final storedAnswers = model.storedAnswers;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//     final publish = model.publish;

//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         floatingActionButtonLocation: keyboardIsOpened
//             ? FloatingActionButtonLocation.miniEndTop
//             : FloatingActionButtonLocation.endFloat,
//         floatingActionButton: storedAnswers == null
//             ? null
//             : FloatingActionButton(
//                 onPressed: () {
//                   _showDropdown(storedAnswers);
//                 },
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 child: Icon(
//                   Icons.list,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                 ),
//               ),
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           surfaceTintColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Theme.of(context).colorScheme.onPrimary,
//           actions: [
//             controller.text == ""
//                 ? Container()
//                 : GestureDetector(
//                     onTap: () => publish(controller.text),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: screenWidth * 0.035,
//                           child: Image.asset(
//                             IconConstant.iconDirect,
//                             color: Theme.of(context).colorScheme.onPrimary,
//                           ),
//                         ),
//                         SizedBox(
//                           width: screenWidth * 0.025,
//                         ),
//                         const Text(
//                           "ОТПРАВИТЬ",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(
//                           width: screenWidth * 0.065,
//                           height: 100,
//                         ),
//                       ],
//                     ),
//                   ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(screenWidth * 0.4),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Container(
//                   width: screenWidth,
//                   height: screenWidth * 0.4,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.1,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Row(
//                           children: [
//                             Text(
//                               "Ответ на вопрос:",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.03,
//                                 color: Theme.of(context).colorScheme.onPrimary,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       Center(
//                         child: SizedBox(
//                           width: screenWidth * 0.8,
//                           height: screenWidth * 0.3,
//                           child: AutoSizeText(
//                             questionText,
//                             maxLines: 60,
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.05,
//                               color: Theme.of(context).colorScheme.onPrimary,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.09),
//                 child: TextField(
//                   autofocus: true,
//                   maxLines: null, // Allows multiline input
//                   // enableInteractiveSelection: false,
//                   // showCursor: false,
//                   enableSuggestions: false,

//                   controller: controller,
//                   onChanged: (text) {
//                     model.setReusedAnswerText(text);
//                     // setState(() {}); // No need to call setState here
//                   },
//                   decoration: const InputDecoration(
//                     border: InputBorder.none, // Remove borders
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: keyboardHeight,
//               )
//             ],
//           ),
//         ));
//   }

//   void _showDropdown(List<String> storedAnswers) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.background,
//           title: Text("Выберите шаблон",
//               style: TextStyle(
//                   fontSize: MediaQuery.of(context).size.width * 0.06)),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               itemCount: storedAnswers.length,
//               itemBuilder: (context, index) {
//                 final answer = storedAnswers[index];
//                 return GestureDetector(
//                   onTap: () {
//                     // Update the main controller text when an item is selected
//                     controller.text = controller.text + "\n" + answer;

//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     margin: EdgeInsets.only(
//                         bottom: MediaQuery.of(context).size.width * 0.03),
//                     padding: EdgeInsets.all(
//                         MediaQuery.of(context).size.width * 0.03),
//                     decoration: BoxDecoration(
//                       // border: Border.all(),
//                       borderRadius: BorderRadius.circular(5.0),
//                       color: Theme.of(context).colorScheme.secondaryContainer,
//                     ),
//                     child: Text(answer),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
