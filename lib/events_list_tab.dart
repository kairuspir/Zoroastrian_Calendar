import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database.dart';
import 'models/event_list_tab_view_model.dart';
import 'my_future_builder.dart';
import 'widgets.dart';

class EventsListTab extends StatefulWidget {
  static const title = 'Events';
  static const androidIcon = Icon(Icons.reorder);
  static const iosIcon = Icon(CupertinoIcons.text_justify);

  const EventsListTab({super.key});

  @override
  State<EventsListTab> createState() => _EventsListTabState();
}

class _EventsListTabState extends State<EventsListTab> {
  Widget _buildTab() {
    return MyFutureBuilder<List<EventListTabViewModel>>(
        future: DBProvider.db.getEventListTabData(),
        builder: (context, data) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, index) {
                  return Text(
                      "${data[index].title}Next occurance: ${DateFormat("EEEE dd/M/yyyy").format(data[index].gregorianDate)}");
                }),
          );
        });
  }

  // ===========================================================================
  // Non-shared code below because this tab uses different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return _buildTab();
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: _buildTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
