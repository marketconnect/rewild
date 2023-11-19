import 'package:flutter/material.dart';

class CardNotificationSettingsScreen extends StatelessWidget {
  const CardNotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Уведомления'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("aaa"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.save,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: []),
        ),
      ),
    );
  }
}
