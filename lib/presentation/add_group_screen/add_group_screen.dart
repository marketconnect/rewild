import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddGroupScreenViewModel>();
    final addGroup = model.addGroup;
    final save = model.save;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: const Text(
              'Добавить в группы:',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF1f1f1f),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => save(),
                icon: const Icon(Icons.done),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    MainNavigationRouteNames.allCardsScreen,
                  );
                },
                icon: const Icon(Icons.close),
              ),
            ]),
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              String newGroupName = "";
              return AlertDialog(
                insetPadding: const EdgeInsets.all(10),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                buttonPadding: EdgeInsets.zero,
                title: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Название группы",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                content: TextField(
                  onChanged: (value) {
                    newGroupName = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        )),
                  ),
                  TextButton(
                    onPressed: () => addGroup(newGroupName),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onBackground,
                            )),
                        child: Text(
                          'Добавить',
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        )),
                  ),
                ],
              );
            },
          ),
          child: const Icon(Icons.add),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddGroupScreenViewModel>();
    final groups = model.groups;
    final selectedGroups = model.selectedGroupsNames;
    final selectGroup = model.selectGroup;
    return groups.isEmpty
        ? const Center(
            child: Text('У вас нет групп, пожалуйста, добавьте'),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: CheckboxListTile(
                      value: selectedGroups.contains(groups[index].name),
                      onChanged: (_) {
                        final name = groups[index].name;
                        selectGroup(name);
                      },
                      title: Text(groups[index].name),
                    ),
                  );
                }
                if (index == groups.length - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 70.0),
                    child: CheckboxListTile(
                      value: selectedGroups.contains(groups[index].name),
                      onChanged: (_) {
                        final name = groups[index].name;
                        selectGroup(name);
                      },
                      title: Text(groups[index].name),
                    ),
                  );
                }
                return CheckboxListTile(
                  value: selectedGroups.contains(groups[index].name),
                  onChanged: (_) {
                    final name = groups[index].name;
                    selectGroup(name);
                  },
                  title: Text(groups[index].name),
                );
              },
            ),
          );
  }
}
