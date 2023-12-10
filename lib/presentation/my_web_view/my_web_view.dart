import 'package:rewild/core/utils/extensions/strings.dart';
import 'package:rewild/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:rewild/widgets/progress_indicator.dart';

import 'package:webview_flutter/webview_flutter.dart';

class MyWebViewScreen extends StatefulWidget {
  const MyWebViewScreen({super.key});

  @override
  State<MyWebViewScreen> createState() => _MyWebViewScreenState();
}

class _MyWebViewScreenState extends State<MyWebViewScreen> {
  String currentUrl = "";
  String mes = "";
  final _controller = WebViewController();

  void _setUrl(String url) {
    setState(() {
      currentUrl = url;
    });
  }

  @override
  void initState() {
    super.initState();
    // Create a webview controller
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _setUrl(url);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("Got: ${message.message}");
          mes = message.message;
        },
      )
      ..loadRequest(Uri.parse("https://www.wildberries.ru"));
  }

  // // javascript channel - received a message then display in a snackbar
  Future<void> _onAddTap() async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.

    return _controller.runJavaScript(
      '''
      function fetch(){
          let result = [];
          let slider = document.querySelector(".slider-color");
          let nmIds = Array.from( slider.getElementsByClassName("img-plug") ).map(function(el) { 
              let id = el.href.split("/")[4];
              let img_src = el.getElementsByTagName("img")[0].src;
              result.push({'id':parseInt(id), 'img':img_src});
          });
          let res = JSON.stringify(result);
          return res;
      }
      Toaster.postMessage(fetch());''',
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyWebViewScreenViewModel>();
    final save = model.saveSiblingCards;
    final isLoading = model.isLoading;
    final errorMessage = model.errorMessage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pushReplacementNamed(
              context, MainNavigationRouteNames.allCardsScreen),
        ),
        actions: [
          currentUrl.isWildberriesDetailUrl()
              ? IconButton(
                  onPressed: () async {
                    await _onAddTap();
                    final n = await save(mes);
                    final message = errorMessage ??
                        (n == 0
                            ? "Эти карточки уже добавлены"
                            : "Добавлено карточек: $n шт.");
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      message,
                    )));
                  },
                  icon: const Icon(Icons.add))
              : Container()
        ],
        backgroundColor: const Color(0xFFfafafa),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: model.screenWidth * 0.15),
              child: Text(
                currentUrl.isWildberriesDetailUrl()
                    ? "Добавить"
                    : "Выберите карточку",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1f1f1f),
                ),
              ),
            )
          ],
        ),
      ),
      body: Stack(children: [
        SizedBox(
            width: double.infinity,
            // the most important part of this example
            child: WebViewWidget(
              controller: _controller,
            )),
        if (isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (isLoading)
          const Center(
            child: MyProgressIndicator(),
          ),
      ]),
    );
  }
}
