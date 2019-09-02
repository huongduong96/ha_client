part of '../main.dart';

class Panel {

  static const iconsByComponent = {
    "config": "mdi:settings",
    "history": "mdi:poll-box",
    "map": "mdi:tooltip-account",
    "logbook": "mdi:format-list-bulleted-type",
    "custom": "mdi:home-assistant"
  };

  final String id;
  final String type;
  final String title;
  final String urlPath;
  final Map config;
  String icon;
  bool isHidden = true;

  Panel({this.id, this.type, this.title, this.urlPath, this.icon, this.config}) {
    if (icon == null || !icon.startsWith("mdi:")) {
      icon = Panel.iconsByComponent[type];
    }
    Logger.d("New panel '$title'. type=$type, icon=$icon, urlPath=$urlPath");
    isHidden = (type == 'lovelace' || type == 'kiosk' || type == 'states');
  }

  void handleOpen(BuildContext context) {
    if (type == "config") {
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PanelPage(title: "$title", panel: this),
          )
      );
    } else {
      String url = "${ConnectionManager().httpWebHost}/$urlPath?external_auth=1";
      final flutterWebViewPlugin = new FlutterWebviewPlugin();
      flutterWebViewPlugin.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.startLoad) {
          Logger.d("[WebView] Injecting external auth JS");
          rootBundle.loadString('assets/js/externalAuth.js').then((js){
            flutterWebViewPlugin.evalJavascript(js.replaceFirst("[token]", ConnectionManager()._token));
          });
        }
      });
      Navigator.of(context).pushNamed(
          "/webview",
          arguments: {
            "url": "$url",
            "title": "${this.title}"
          }
      );
    }
  }

  Widget getWidget() {
    switch (type) {
      case "config": {
        return ConfigPanelWidget();
      }

      default: {
        return Text("Unsupported panel component: $type");
      }
    }
  }

}