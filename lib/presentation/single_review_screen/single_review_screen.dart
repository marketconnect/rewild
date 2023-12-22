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
        ),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Set the height
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReWildNetworkImage(
                  width: screenWidth * 0.2, // Adjust the size as needed
                  image: 'your_image_url', // Replace with your image URL
                ),
                const Text(
                  'Your Text Here', // Replace with your text
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: review == null
          ? const EmptyWidget(text: "Что-то пошло не так.")
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: photos.map((e) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Hero(
                              tag: 'imageHero${e.fullSize}',
                              child: Image.network(e.fullSize),
                            ),
                          );
                        },
                      );
                    },
                    child: Hero(
                      tag: 'imageHero${e.miniSize}',
                      child: ReWildNetworkImage(
                        width: screenWidth * 0.2,
                        image: e.fullSize,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
    ;
  }
}
