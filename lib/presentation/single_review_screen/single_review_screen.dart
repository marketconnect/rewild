import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/single_review_screen/single_review_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/network_image.dart';

class SingleReviewScreen extends StatelessWidget {
  const SingleReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    final photos = review?.photoLinks ?? [];

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Группы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1f1f1f),
            ),
            // textScaler: TextScaler()
          ),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent),
      body: review == null
          ? const EmptyWidget(text: "Что-то пошло не так.")
          : SingleChildScrollView(
              child: Column(
              children:
                  // photos
                  //     .map((e) => ReWildNetworkImage(
                  //         width: screenWidth * 0.9, image: e.fullSize))
                  //     .toList(),
                  const [],
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: photos
              //         .map(
              //           (e) => Padding(
              //             padding: const EdgeInsets.all(8.0),
              //             child: ReWildNetworkImage(
              //               width: screenWidth * 0.9,
              //               image: e.fullSize,
              //             ),
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
            )),
    );
  }
}
