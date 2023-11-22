import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/background_notifications_sreen/background_notifications_view_model.dart';

class BackgroundNotificationsScreen extends StatelessWidget {
  const BackgroundNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BackgroundNotificationsViewModel>();
    final messages = model.backgroundMessages;
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
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index].condition.toString()),
            subtitle: Text(messages[index].id.toString()),
          );
        },
      ),
    );
  }
}
