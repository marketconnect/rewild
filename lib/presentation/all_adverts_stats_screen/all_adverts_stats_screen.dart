import 'package:flutter/material.dart';
// import 'package:rewild/domain/services/background_service.dart';

class AllAdvertsStatsScreen extends StatelessWidget {
  const AllAdvertsStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await BackgroundService.fetchAll();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
