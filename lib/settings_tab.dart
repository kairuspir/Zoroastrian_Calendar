import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_provider.dart';
import 'database.dart';
import 'models/calendar_type.dart';
import 'my_future_builder.dart';
import 'utilities.dart';
import 'widgets.dart';

class SettingsTab extends StatefulWidget {
  static const title = 'Settings';
  static const androidIcon = Icon(Icons.settings);
  static const iosIcon = Icon(CupertinoIcons.gear);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  var switch3 = true;

  final availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.grey,
  ];

  static Widget colorPickerItem(
      MaterialColor color, bool isCurrentColor, Function onChangeColor) {
    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            offset: Offset(1.0, 2.0),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await DBProvider.db.setThemeColorPreference(color);
            onChangeColor();
          },
          borderRadius: BorderRadius.circular(50.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1.0 : 0.0,
            child: Icon(
              Icons.done,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  showPicker() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Orientation orientation = MediaQuery.of(context).orientation;
          final themeColor = AppProvider.of(context).themeColor;
          final callSetState = AppProvider.of(context).callSetState;

          return AlertDialog(
            title: Text("Select a color"),
            content: SingleChildScrollView(
              child: Container(
                width: orientation == Orientation.portrait ? 300.0 : 300.0,
                height: orientation == Orientation.portrait ? 360.0 : 200.0,
                child: GridView.count(
                  crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  children: availableColors
                      .map((MaterialColor color) => colorPickerItem(
                          color, color == themeColor, callSetState))
                      .toList(),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildList() {
    final themeColor = AppProvider.of(context).themeColor;
    final themes = AppProvider.of(context).themeMode;
    final callSetState = AppProvider.of(context).callSetState;
    final calendarType = AppProvider.of(context).calendarType;

    return MyFutureBuilder<List<CalendarType>>(
      future: DBProvider.db.calendarTypes,
      builder: (context, data) {
        return ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Theme color",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                InkResponse(
                  onTap: showPicker,
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeColor,
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.8),
                          offset: Offset(1.0, 2.0),
                          blurRadius: 3.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text('Theme'),
              // The Material switch has a platform adaptive constructor.
              trailing: DropdownButton<ThemeMode>(
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(
                        "Light",
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(
                        "Dark",
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(
                        "System",
                      ),
                    ),
                  ],
                  value: themes,
                  onChanged: (value) async {
                    await DBProvider.db.setTheme(value);
                    callSetState();
                  }),
            ),
            ListTile(
              title: Text("Default Calendar"),
              trailing: DropdownButton<CalendarType>(
                items: data
                    .where((x) => x.id != 4)
                    .map((x) => DropdownMenuItem(value: x, child: Text(x.name)))
                    .toList(),
                value: calendarType,
                onChanged: (value) async {
                  await DBProvider.db.setPreferredCalendar(value);
                  callSetState();
                },
              ),
            ),
            ListTile(
              title: Text('Remind me to rate this app'),
              trailing: Switch.adaptive(
                value: switch3,
                onChanged: (value) => setState(() => switch3 = value),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Non-shared code below because this tab uses different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return _buildList();
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: _buildList(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
