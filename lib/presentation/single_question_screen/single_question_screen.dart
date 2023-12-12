import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';

class SingleQuestionScreen extends StatefulWidget {
  const SingleQuestionScreen({Key? key}) : super(key: key);

  @override
  _SingleQuestionScreenState createState() => _SingleQuestionScreenState();
}

class _SingleQuestionScreenState extends State<SingleQuestionScreen> {
  late TextEditingController controller;
  late TextEditingController dropdownController;

  @override
  void initState() {
    super.initState();
    final model = context.read<SingleQuestionViewModel>();
    controller =
        TextEditingController(text: model.question.reusedAnswerText ?? '');
    dropdownController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleQuestionViewModel>();
    final questionText = model.question.text;
    final storedAnswers = model.storedAnswers;
    final screenWidth = MediaQuery.of(context).size.width;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    final publish = model.publish;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: keyboardIsOpened
          ? FloatingActionButtonLocation.miniEndTop
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: storedAnswers == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                _showDropdown(storedAnswers);
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.list,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          controller.text == ""
              ? Container()
              : GestureDetector(
                  onTap: () => publish(controller.text),
                  child: Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.035,
                        child: Image.asset(
                          IconConstant.iconDirect,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.025,
                      ),
                      const Text(
                        "ОТПРАВИТЬ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: screenWidth * 0.065,
                        height: 100,
                      ),
                    ],
                  ),
                ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenWidth * 0.4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: screenWidth,
                height: screenWidth * 0.4,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text(
                            "Ответ на вопрос:",
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        height: screenWidth * 0.3,
                        child: AutoSizeText(
                          questionText,
                          maxLines: 60,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.09),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,

                    maxLines: null, // Allows multiline input
                    controller: controller,
                    onChanged: (text) {
                      model.setReusedAnswerText(text);
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none, // Remove borders
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDropdown(List<String> storedAnswers) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text("Выберите шаблон",
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: storedAnswers.length,
              itemBuilder: (context, index) {
                final answer = storedAnswers[index];
                return GestureDetector(
                  onTap: () {
                    // Update the main controller text when an item is selected
                    controller.text = controller.text + "\n" + answer;

                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.03),
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                    decoration: BoxDecoration(
                      // border: Border.all(),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Text(answer),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
