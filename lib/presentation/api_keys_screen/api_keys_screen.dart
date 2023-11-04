import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/api_keys_screen/api_keys_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/progress_indicator.dart';
import 'package:flutter/services.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String _value = '1';
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ApiKeysScreenViewModel>();
    final apiKeys = model.apiKeys;
    final add = model.add;
    final types = model.types;
    final typesNum = types.length;
    final loading = model.loading;
    final select = model.select;
    final delete = model.delete;
    final selectionInProgress =
        apiKeys.where((apiKey) => apiKey.isSelected).isNotEmpty;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: const [
              TextSpan(
                text: 'Доступ к ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'API',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(3),
        width: MediaQuery.of(context).size.width,
        child: FloatingActionButton(
          onPressed: () async {
            if (selectionInProgress) {
              await delete();
              return;
            }
            _showModalBottomSheet(context, types, add)
                .whenComplete(() => _textEditingController.clear());
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(selectionInProgress ? "Удалить" : "Добавить токен",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: loading
          ? const MyProgressIndicator()
          : apiKeys.isEmpty
              ? const EmptyWidget(text: 'Вы еще не добавили ни одного токена')
              : Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Ваши токены',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)),
                          ),
                        ],
                      ),
                      Expanded(
                        child: GridView.builder(
                            itemCount: apiKeys.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (context, index) => GestureDetector(
                                  onTap: () => select(index),
                                  child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: apiKeys[index].isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.12,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    child: AutoSizeText(
                                                      apiKeys[index].type,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                        color: apiKeys[index]
                                                                .isSelected
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                  ),
                                                  Text(
                                                    '${index + 1}/$typesNum',
                                                    style: TextStyle(
                                                      color: apiKeys[index]
                                                              .isSelected
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ]),
                                            if (selectionInProgress)
                                              Positioned(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.07,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.07,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: apiKeys[index]
                                                            .isSelected
                                                        ? null
                                                        : Border.all(
                                                            width: 2,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                  ),
                                                  child: apiKeys[index]
                                                          .isSelected
                                                      ? Icon(
                                                          Icons.check,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        )
                                                      : Container(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                                )),
                      ),
                    ],
                  ),
                ),
    ));
  }

  Future<dynamic> _showModalBottomSheet(BuildContext context,
      List<String> types, Future<void> Function(String key, String type) add) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder:
          (BuildContext context, void Function(void Function()) setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.08,
                  ),
                  Text(
                    'Токен',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                child: TextField(
                  showCursor: true,
                  readOnly: true,
                  obscureText: true,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 15,
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 30,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    suffixIcon: _textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _textEditingController.clear();
                              setState(() {});
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.paste_rounded),
                            onPressed: () async {
                              ClipboardData? cdata =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (cdata == null) {
                                return;
                              }
                              _textEditingController.text = cdata.text!;
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.08,
                  ),
                  Text(
                    'Категория',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                child: DropdownButtonFormField<String>(
                  value: _value,
                  decoration: InputDecoration(
                    // labelText: 'Category',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  items: types
                      .map((e) => DropdownMenuItem(
                          value: "${types.indexOf(e)}", child: Text(e)))
                      .toList()
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _value = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: () async {
                  final apiKey = _textEditingController.text;
                  if (apiKey.length < 10) {
                    return;
                  }

                  final valueToAdd = types[int.parse(_value)];
                  await add(apiKey, valueToAdd);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
