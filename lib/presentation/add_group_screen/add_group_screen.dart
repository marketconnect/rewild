import 'package:rewild/presentation/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/my_dialog_textfield_widget.dart';

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
              return MyDialogTextField(
                header: "Название группы",
                hint: "Введите название",
                addGroup: addGroup,
                btnText: "Добавить",
                description: "Будет отображаться для объединенных карточек",
                keyboardType: TextInputType.name,
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
        ? const EmptyWidget(text: 'У вас нет групп, пожалуйста, добавьте')
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
