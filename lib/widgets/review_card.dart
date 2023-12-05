import 'package:flutter/material.dart';
import 'package:rewild/core/constants/icons_constant.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text("Имя пользователя",
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
                          "05.11.2023",
                          textAlign: TextAlign.end,
                          style: TextStyle(
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
                const SizedBox(
                  // width: screenWidth * 0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.star),
                      Icon(Icons.star),
                      Icon(Icons.star),
                      Icon(Icons.star),
                      Icon(Icons.star),
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
              child: const Text(
                  "lorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet llorem ipsum dolor sit amet lorem ipsum dolor sit amet l"),
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
