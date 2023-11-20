import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/presentation/card_notification_screen/card_notification_view_model.dart';
import 'package:rewild/widgets/numeric_step.dart';

class CardNotificationSettingsScreen extends StatelessWidget {
  const CardNotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CardNotificationViewModel>();
    final screenWidth = model.screenWidth;
    final save = model.save;
    final state = model.state;
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
      // FloatingActionButton(
      //   onPressed: () => save(),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   child: Icon(
      //     Icons.save,
      //     color: Theme.of(context).colorScheme.onPrimary,
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _UnmutableCard(
            condition: NotificationConditionConstants.nameChanged,
            currentValue: "",
            text: 'Изменение в назавании',
          ),
          const _UnmutableCard(
            condition: NotificationConditionConstants.promoChanged,
            currentValue: "",
            text: 'Изменение акции',
          ),
          _UnmutableCard(
            condition: NotificationConditionConstants.priceChanged,
            currentValue: (state.price ~/ 100).toString(),
            suffix: '₽',
            text: 'Изменение цены',
          ),
          _UnmutableCard(
            condition: NotificationConditionConstants.reviewRatingChanged,
            currentValue: state.reviewRating.toString(),
            text: 'Изменение рейтинга',
          ),
          _UnmutableCard(
            condition: NotificationConditionConstants.picsChanged,
            currentValue: state.pics.toString(),
            suffix: 'шт.',
            text: 'Изменение картинок',
          ),
          _MutableCard(
            condition: NotificationConditionConstants.stocksLessThan,
            currentValue: stocks,
            text: 'Остатки ${stocks > 50000 ? '<' : ' менее'}',
            suffix: 'шт.',
          ),
        ]),
      ),
    );
  }
}

class _MutableCard extends StatefulWidget {
  const _MutableCard({
    required this.condition,
    required this.text,
    this.currentValue,
    this.suffix,
    // required this.onpPress,
    // required this.onChanged
  });

  final int condition;

  final int? currentValue;
  final String? suffix;
  final String text;

  @override
  State<_MutableCard> createState() => _MutableCardState();
}

class _MutableCardState extends State<_MutableCard> {
  int? value;

  @override
  void initState() {
    super.initState();
    value = widget.currentValue ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CardNotificationViewModel>();
    final active = model.isInNotifications(widget.condition);
    final screenWidth = model.screenWidth;
    final screenHeight = model.screenHeight;
    final drop = model.dropNotification;
    final add = model.addNotification;
    return Container(
      width: screenWidth,
      height: screenHeight * 0.11,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.15,
            child: IconButton(
              onPressed: () => active
                  ? drop(widget.condition)
                  : add(widget.condition, value),
              icon: Icon(
                Icons.notifications,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                size: screenWidth * 0.07,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.8),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumericStepButton(
                onChanged: (value) => setState(() {
                  this.value = value;
                }),
                currentValue: value!,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _UnmutableCard extends StatelessWidget {
  const _UnmutableCard({
    required this.condition,
    required this.text,
    this.currentValue,
    this.suffix,
  });

  final int condition;

  final String? currentValue;
  final String? suffix;
  final String text;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CardNotificationViewModel>();
    final active = model.isInNotifications(condition);
    final screenWidth = model.screenWidth;
    final screenHeight = model.screenHeight;
    final drop = model.dropNotification;
    final add = model.addNotification;
    return Container(
      width: screenWidth,
      height: screenHeight * 0.11,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.15,
            child: IconButton(
              onPressed: () {
                if (active) {
                  drop(condition);
                  return;
                }

                currentValue == null
                    ? add(condition)
                    : add(condition, int.tryParse(currentValue!));
              },
              icon: Icon(
                Icons.notifications,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                size: screenWidth * 0.07,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.8),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "$currentValue${suffix ?? ""}",
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
