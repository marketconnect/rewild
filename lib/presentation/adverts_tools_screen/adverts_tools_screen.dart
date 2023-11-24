import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/adverts_tools_screen/adverts_tools_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
// import 'package:rewild/domain/services/background_service.dart';

class AdvertsToolsScreen extends StatelessWidget {
  const AdvertsToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertsToolsViewModel>();
    final autoAdverts = model.adverts;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (model, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                    MainNavigationRouteNames.autoStatWordsScreen,
                    arguments: autoAdverts[index].advertId);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: const EdgeInsets.only(
                  bottom: 25,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).colorScheme.background),
                child: Row(
                  children: [
                    Text(autoAdverts[index].name),
                  ],
                ),
              ),
            );
          },
          itemCount: autoAdverts.length),
    );
  }
}
