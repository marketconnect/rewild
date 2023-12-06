import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild/presentation/all_products_questions_screen/all_products_questions_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';

class AllProductsQuestionsScreen extends StatefulWidget {
  const AllProductsQuestionsScreen({super.key});

  @override
  State<AllProductsQuestionsScreen> createState() =>
      _AllProductsQuestionsScreenState();
}

class _AllProductsQuestionsScreenState
    extends State<AllProductsQuestionsScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllProductsQuestionsViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final apiKeyexists = model.apiKeyExists;
    final questions = model.questions;
    final getImages = model.getImage;
    final getNewQuestionsQty = model.newQuestionsQty;
    final getallQuestionsQty = model.allQuestionsQty;
    final getSupplierArticle = model.getSupplierArticle;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: !apiKeyexists
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                  ),
                  Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      }),
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  isSwitched
                      ? Text('Новые',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05))
                      : Text('Все',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05)),
                ],
              ),
      ),
      body: !apiKeyexists
          ? const EmptyWidget(
              text: 'Создайте API ключ, чтобы видеть вопросы',
            )
          : SingleChildScrollView(
              child: Column(children: [
                Column(
                  children: questions.entries.map((e) {
                    if (isSwitched) {
                      return (getNewQuestionsQty(e.key) > 0)
                          ? _ProductCard(
                              image: getImages(e.key),
                              newQuetions: getNewQuestionsQty(e.key),
                              supplierArticle: getSupplierArticle(e.key),
                              oldQuetions: getallQuestionsQty(e.key),
                            )
                          : Container();
                    }
                    return _ProductCard(
                      image: getImages(e.key),
                      newQuetions: getNewQuestionsQty(e.key),
                      supplierArticle: getSupplierArticle(e.key),
                      oldQuetions: getallQuestionsQty(e.key),
                    );
                  }).toList(),
                )
              ]),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {required this.image,
      required this.newQuetions,
      required this.oldQuetions,
      required this.supplierArticle});
  final String image;
  final String supplierArticle;
  final int newQuetions;
  final int oldQuetions;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
        ),
        // borderRadius: BorderRadius.circular(10),
      ),
      child: AspectRatio(
        aspectRatio: 10 / 3,
        child: SizedBox(
          width: screenWidth,
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child:
                    ReWildNetworkImage(width: screenWidth * 0.33, image: image),
              ),
              SizedBox(
                width: screenWidth * 0.05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      supplierArticle,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Всего вопросов: $oldQuetions',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: newQuetions == 0
                        ? null
                        : EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.01,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                          ),
                    decoration: newQuetions == 0
                        ? null
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.01),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    child: Text(
                      'Новых: $newQuetions',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: newQuetions > 0
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.7),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
