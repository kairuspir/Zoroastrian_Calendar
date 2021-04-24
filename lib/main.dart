import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'app_provider.dart';
import 'database.dart';
import 'events_list_tab.dart';
import 'home_tab.dart';
import 'models/my_app_view_model.dart';
import 'my_future_builder.dart';
import 'settings_tab.dart';
import 'widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyApp> {
  void callSetState() {
    setState(() {});
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyFutureBuilder<MyAppViewModel>(
        future: DBProvider.db.getMyAppData(),
        builder: (context, data) {
          return AppProvider(
            themeColor: data.themeColor,
            themeMode: data.themeMode,
            calendarType: data.calendarType,
            deviceCalendarState: data.deviceCalendarState,
            callSetState: callSetState,
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: data.themeColor,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: data.themeColor,
                toggleableActiveColor: data.themeColor[200],
                accentColor: data.themeColor[200],
                textSelectionTheme: TextSelectionThemeData(
                  selectionHandleColor: data.themeColor[400],
                ),
                buttonColor: data.themeColor[600],
              ),
              themeMode: data.themeMode,
              builder: (context, child) {
                return CupertinoTheme(
                  data: MaterialBasedCupertinoThemeData(
                      materialTheme: ThemeData(primarySwatch: data.themeColor)),
                  child: Material(child: child),
                );
              },
              home: MyHomePage(title: 'Zorastrian Calendar'),
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _activeTabTitle = HomeTab.title;
  Widget _activeTabWidget = HomeTab();
  void _setTab(Tabname tabname) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      switch (tabname) {
        case Tabname.Events:
          _activeTabTitle = EventsListTab.title;
          _activeTabWidget = EventsListTab();
          break;
        case Tabname.Settings:
          _activeTabTitle = SettingsTab.title;
          _activeTabWidget = SettingsTab();
          break;
        case Tabname.Home:
        default:
          _activeTabTitle = HomeTab.title;
          _activeTabWidget = HomeTab();
      }
    });
  }

  Widget _buildAndroidHomePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activeTabTitle),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(Icons.perm_identity,
                    color: Theme.of(context).secondaryHeaderColor, size: 96),
              ),
            ),
            ListTile(
              leading: HomeTab.androidIcon,
              title: Text(HomeTab.title),
              onTap: () {
                Navigator.pop(context);
                _setTab(Tabname.Home);
              },
            ),
            ListTile(
              leading: EventsListTab.androidIcon,
              title: Text(EventsListTab.title),
              onTap: () {
                Navigator.pop(context);
                _setTab(Tabname.Events);
              },
            ),
            // Long drawer contents are often segmented.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            ListTile(
              leading: SettingsTab.androidIcon,
              title: Text(SettingsTab.title),
              onTap: () {
                Navigator.pop(context);
                _setTab(Tabname.Settings);
              },
            )
          ],
        ),
      ),
      body: _activeTabWidget,
    );
  }

  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(label: HomeTab.title, icon: HomeTab.iosIcon),
          BottomNavigationBarItem(
              label: EventsListTab.title, icon: EventsListTab.iosIcon),
          BottomNavigationBarItem(
              label: SettingsTab.title, icon: SettingsTab.iosIcon),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              defaultTitle: HomeTab.title,
              builder: (context) => HomeTab(),
            );
          case 1:
            return CupertinoTabView(
              defaultTitle: EventsListTab.title,
              builder: (context) => EventsListTab(),
            );
          case 2:
            return CupertinoTabView(
              defaultTitle: SettingsTab.title,
              builder: (context) => SettingsTab(),
            );
          default:
            assert(false, 'Unexpected tab');
            return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }
}

enum Tabname { Home, Events, Settings }
