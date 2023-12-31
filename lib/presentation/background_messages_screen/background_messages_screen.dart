import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/background_messages_screen/background_messages_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';

class MessageCard {
  final String header;
  final String description;
  final String dateTime;
  final int subject;
  final int id;
  final String routeName;
  final int condition;

  MessageCard(
      {required this.header,
      required this.id,
      required this.routeName,
      required this.subject,
      required this.description,
      required this.condition,
      required this.dateTime});
}

class BackgroundMessagesScreen extends StatelessWidget {
  const BackgroundMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BackgroundMessagesViewModel>();
    final messages = model.messages;
    final pressed = model.pressed;
    // messages.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Уведомления',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1f1f1f),
            ),
            // textScaleFactor: 1
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.clear,
                color: Color(0xFF1f1f1f),
              ),
            ),
          ],
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent),
      body: Container(
        width: model.screenWidth * 0.9,
        margin: EdgeInsets.only(left: model.screenWidth * 0.05),
        child: messages.isEmpty
            ? const EmptyWidget(
                text: 'Нет уведомлений',
              )
            : ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => pressed(
                        routeName: messages[index].routeName,
                        subject: messages[index].subject,
                        id: messages[index].id,
                        condition: messages[index].condition),
                    child: Container(
                      width: model.screenWidth * 0.9,
                      height: model.screenHeight * 0.12,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.1),
                                width: 1)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                messages[index].header,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    messages[index].dateTime,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.5),
                                    size: MediaQuery.of(context).size.width *
                                        0.04,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                messages[index].description,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
