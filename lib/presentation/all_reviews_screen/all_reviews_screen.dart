import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';
import 'package:rewild/core/utils/date_time_utils.dart';
import 'package:rewild/domain/entities/review_model.dart';

import 'package:rewild/presentation/all_reviews_screen/all_reviews_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/expandable_image.dart';
import 'package:rewild/widgets/rate_stars.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllReviewsViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final reviews = model.reviews;

    // Search
    final setSearchQuery = model.setSearchQuery;
    final clearSearchQuery = model.clearSearchQuery;
    final searchQuery = model.searchQuery;

    final displayedReviews = reviews.where((q) {
      if (q.answer != null) {
        return q.text.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.answer!.text.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return q.text.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    clearSearchQuery();
                  }
                });
              },
            ),
          ],
          title: _isSearching
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setSearchQuery(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Поиск...',
                      border: InputBorder.none,
                    ),
                  ),
                )
              : null,
        ),
        body: Column(children: [
          SizedBox(height: screenWidth * 0.035),
          Expanded(
              child: ListView.builder(
                  itemCount: displayedReviews.length,
                  itemBuilder: (context, index) {
                    var review = displayedReviews[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.singleReviewScreen,
                          arguments: displayedReviews[index]),
                      child: _ReviewCard(
                        reviewText: review.text,
                        createdAt: review.createdDate,
                        valuation: review.productValuation,
                        photoLinks: review.photoLinks,
                        userName: review.userName,
                      ),
                    );
                  }))
        ]));
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(
      {required this.reviewText,
      required this.createdAt,
      required this.userName,
      this.photoLinks = const [],
      required this.valuation});
  final String reviewText;
  final DateTime createdAt;
  final String userName;
  final int valuation;
  final List<PhotoLink> photoLinks;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    final dateText = formatReviewDate(createdAt);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenWidth * 0.08),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.085,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        // borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
      child: Column(children: [
        Row(
          children: [
            const _Ava(),
            SizedBox(
              width: screenWidth * 0.04,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(userName,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.75),
                            )),
                      ),
                      SizedBox(
                        width: screenWidth * 0.2,
                        child: Text(
                          dateText,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RateStars(valuation: valuation)
              ],
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: screenWidth * 0.75,
              child: Text(reviewText),
            ),
          ],
        ),
        if (photoLinks.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: screenWidth * 0.05),
            width: screenWidth,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: photoLinks
                      .map((link) => ReWildExpandableImage(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            expandedImagePath: link.fullSize,
                            colapsedImagePath: link.miniSize,
                          ))
                      .toList(),
                )),
          ),
      ]),
    );
  }
}

class _Ava extends StatelessWidget {
  const _Ava();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
        color: const Color(0xFFd9d9d9),
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      alignment: Alignment.center,
      width: screenWidth * 0.15,
      height: screenWidth * 0.15,
      child: Image.asset(
        IconConstant.iconHappyMale,
      ),
    );
  }
}
