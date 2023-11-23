import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/background_notifications_screen/background_notifications_view_model.dart';

class MessageCard {
  final String header;
  final String description;
  final String dateTime;
  final int id;
  final String routeName;

  MessageCard(
      {required this.header,
      required this.id,
      required this.routeName,
      required this.description,
      required this.dateTime});
}

class BackgroundNotificationsScreen extends StatelessWidget {
  const BackgroundNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BackgroundNotificationsViewModel>();
    final messages = model.messages;
    // messages.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Уведомления',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1f1f1f),
              ),
              textScaleFactor: 1),
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
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                  context, messages[index].routeName,
                  arguments: messages[index].id),
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
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              messages[index].dateTime,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.5),
                              size: MediaQuery.of(context).size.width * 0.04,
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
                            fontSize: MediaQuery.of(context).size.width * 0.04,
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
