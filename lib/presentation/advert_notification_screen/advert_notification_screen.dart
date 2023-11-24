import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants.dart';

import 'package:rewild/presentation/advert_notification_screen/advert_notification_view_model.dart';

import 'package:rewild/widgets/mutable_notification_card.dart';

class AdvertNotificationSettingsScreen extends StatelessWidget {
  const AdvertNotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertNotificationViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final save = model.save;
    final state = model.state;
    final add = model.addNotification;
    final drop = model.dropNotification;
    final isActive = model.isInNotifications;
    final notificationsBudget =
        model.notifications[NotificationConditionConstants.budgetLessThan];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Уведомления',
          style: TextStyle(
              fontSize: screenWidth * 0.06,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(3),
        width: model.screenWidth,
        child: FloatingActionButton(
          onPressed: () async {
            // print("SAVE ${model.notifications}");.
            await save();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text("Сохранить",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!model.loading)
            MutableNotificationCard(
              condition: NotificationConditionConstants.budgetLessThan,
              currentValue: notificationsBudget == null
                  ? state.budget
                  : int.tryParse(notificationsBudget.value) ?? 0,
              text: 'Бюджет  менее',
              suffix: 'шт.',
              isActive: isActive(NotificationConditionConstants.budgetLessThan),
              addNotification: add,
              dropNotification: drop,
            ),
        ]),
      ),
    );
  }
}
