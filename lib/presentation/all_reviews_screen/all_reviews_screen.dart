import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/icons_constant.dart';

import 'package:rewild/presentation/all_reviews_screen/all_reviews_view_model.dart';

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
    // List<ReviewModel> unAnsweredReviews = [];
    // List<ReviewModel> answeredReviews = [];
    // for (final question in displayedReviews) {
    //   if (question.answer != null) {
    //     answeredReviews.add(question);
    //   } else {
    //     unAnsweredReviews.add(question);
    //   }
    // }

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenWidth * 0.035),
            ...displayedReviews.map((e) => _ReviewCard(
                  reviewText: e.text,
                  createdAt: e.createdDate,
                  valuation: e.productValuation,
                  userName: e.userName,
                )),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(
      {super.key,
      required this.reviewText,
      required this.createdAt,
      required this.userName,
      required this.valuation});
  final String reviewText;
  final DateTime createdAt;
  final String userName;
  final int valuation;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    final dateText = DateTime.now().difference(createdAt).inDays < 1
        ? '${createdAt.hour}:${createdAt.minute}'
        : '${createdAt.day}.${createdAt.month}.${createdAt.year}';
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
                SizedBox(
                  // width: screenWidth * 0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFf8d253),
                      ),
                      Icon(
                        Icons.star,
                        color: valuation > 1
                            ? const Color(0xFFf8d253)
                            : const Color(0xFFd9d9d9),
                      ),
                      Icon(
                        Icons.star,
                        color: valuation > 2
                            ? const Color(0xFFf8d253)
                            : const Color(0xFFd9d9d9),
                      ),
                      Icon(
                        Icons.star,
                        color: valuation > 3
                            ? const Color(0xFFf8d253)
                            : const Color(0xFFd9d9d9),
                      ),
                      Icon(
                        Icons.star,
                        color: valuation > 4
                            ? const Color(0xFFf8d253)
                            : const Color(0xFFd9d9d9),
                      ),
                    ],
                  ),
                ),
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
