import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/presentation/card_notification_screen/card_notification_view_model.dart';
import 'package:rewild/widgets/mutable_notification_card.dart';
import 'package:rewild/widgets/unmutable_notification_card.dart';

class CardNotificationSettingsScreen extends StatelessWidget {
  const CardNotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CardNotificationViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final save = model.save;
    final state = model.state;
    final add = model.addNotification;
    final drop = model.dropNotification;
    final isActive = model.isInNotifications;
    int stocks = state.warehouses.entries
        .fold(0, (previousValue, element) => previousValue + element.value);
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
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.nameChanged,
            currentValue: "",
            text: 'Изменение в назавании',
            isActive: isActive(NotificationConditionConstants.nameChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.promoChanged,
            currentValue: "",
            text: 'Изменение акции',
            isActive: isActive(NotificationConditionConstants.promoChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.priceChanged,
            currentValue: (state.price ~/ 100).toString(),
            suffix: '₽',
            text: 'Изменение цены',
            isActive: isActive(NotificationConditionConstants.priceChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.reviewRatingChanged,
            currentValue: state.reviewRating.toString(),
            text: 'Изменение рейтинга',
            isActive:
                isActive(NotificationConditionConstants.reviewRatingChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.picsChanged,
            currentValue: state.pics.toString(),
            suffix: 'шт.',
            text: 'Изменение картинок',
            isActive: isActive(NotificationConditionConstants.picsChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          MutableNotificationCard(
            condition: NotificationConditionConstants.stocksLessThan,
            currentValue: stocks,
            text: 'Остатки ${stocks > 50000 ? '<' : ' менее'}',
            suffix: 'шт.',
            isActive: isActive(NotificationConditionConstants.stocksLessThan),
            addNotification: add,
            dropNotification: drop,
          ),
        ]),
      ),
    );
  }
}
