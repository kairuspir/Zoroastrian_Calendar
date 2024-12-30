import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_provider.dart';
import 'database.dart';
import 'event_editor.dart';
import 'models/calendar_event.dart';
import 'models/calendar_type.dart';
import 'models/event_editor_model.dart';
import 'models/home_tab_view_model.dart';
import 'my_future_builder.dart';
import 'widgets.dart';

class HomeTab extends StatefulWidget {
  static const title = 'Home';
  static const androidIcon = Icon(Icons.home);
  static const iosIcon = Icon(CupertinoIcons.home);
  final DateTime selectedDate;
  HomeTab({required this.selectedDate});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;
  late CalendarType calendarType;

  _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future _setDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900, 1, 1),
        lastDate: DateTime(2100, 12, 31));

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(_selectedDate));

      setState(() {
        if (pickedTime != null) {
          _selectedDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
        } else {
          _selectedDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, _selectedDate.hour, _selectedDate.minute);
        }
      });
    }
  }

  Widget _buildZCalTab(String roj, String mah, int year, String geh,
      List<CalendarEvent> events, HomeTabViewModel data) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 25)),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Roj: $roj',
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'Year: $year',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: <Widget>[
                  Text(
                    'Mah: $mah',
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'Geh: $geh',
                    textAlign: TextAlign.left,
                  ),
                ]),
              ),
            ),
          ],
        ),
        if (events.length != 0) Divider(color: Theme.of(context).dividerColor),
        if (events.length != 0)
          Row(
            children: <Widget>[
              Text("Today's Events"),
            ],
          ),
        ...events
            .map((x) => Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Text(x.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventEditor(
                                editorTitle: EditorMode.Edit,
                                zorastrianDate: data.zorastrianDate,
                                calendarEvent: x,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.delete,
                            color: Theme.of(context).primaryColor),
                      ),
                      onTap: () async {
                        await DBProvider.db.deleteEvent(x);
                        setState(() {});
                      },
                    ),
                  ],
                ))
            .toList(),
      ],
    );
  }

  Widget _buildTab() {
    return MyFutureBuilder<HomeTabViewModel>(
      future: DBProvider.db.getHomeTabData(_selectedDate),
      builder: (context, data) {
        return Container(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${DateFormat("dd/M/yyyy").format(data.zorastrianDate.gregorianDate)}',
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '${DateFormat.jms().format(data.zorastrianDate.gregorianDate)}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${DateFormat.EEEE().format(data.zorastrianDate.gregorianDate)}',
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Chog: ${data.chog}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _setToday,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.restore,
                                color: Theme.of(context).primaryColor),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _setDate,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.event,
                                color: Theme.of(context).primaryColor),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Set Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 5,
                          indicatorColor:
                              Theme.of(context).secondaryHeaderColor,
                          tabs: <Widget>[
                            Tab(text: DBProvider.calendar_key_shahenshai),
                            Tab(text: DBProvider.calendar_key_kadmi),
                            Tab(text: DBProvider.calendar_key_fasli)
                          ],
                        ),
                      ),
                      Center(
                        child: [
                          _buildZCalTab(
                            data.zorastrianDate.shahanshahiRojName,
                            data.zorastrianDate.shahanshahiMahName,
                            data.zorastrianDate.shahanshahiYear,
                            data.shahanshahiGeh,
                            data.shahanshahiEvents,
                            data,
                          ),
                          _buildZCalTab(
                            data.zorastrianDate.kadmiRojName,
                            data.zorastrianDate.kadmiMahName,
                            data.zorastrianDate.kadmiYear,
                            data.kadmiGeh,
                            data.kadmiEvents,
                            data,
                          ),
                          _buildZCalTab(
                            data.zorastrianDate.fasliRojName,
                            data.zorastrianDate.fasliMahName,
                            data.zorastrianDate.fasliYear,
                            data.fasliGeh,
                            data.fasliEvents,
                            data,
                          ),
                        ][_tabController.index],
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      ElevatedButton(
                        onPressed: () {
                          final calendarTypeId = _tabController.index + 1;
                          final calendarDayLookupId = (calendarTypeId == 1)
                              ? data.zorastrianDate.shahanshahiDayId
                              : (calendarTypeId == 2)
                                  ? data.zorastrianDate.kadmiDayId
                                  : data.zorastrianDate.fasliDayId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventEditor(
                                editorTitle: EditorMode.Add,
                                zorastrianDate: data.zorastrianDate,
                                calendarEvent: CalendarEvent(
                                  id: 0,
                                  calendarMasterLookupId: 0,
                                  calendarTypeId: calendarTypeId,
                                  calendarDayLookupId: calendarDayLookupId,
                                  title: "",
                                  description: "",
                                  deviceCalendarEventId: "",
                                  isDeleted: 0,
                                ),
                              ),
                            ),
                          );
                        },
                        child: new Text("Add Event"),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.addListener(_handleTabSelection);
    _selectedDate = widget.selectedDate;
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    final calendarType = AppProvider.of(context)!.calendarType;

    if (calendarType != this.calendarType) {
      this.calendarType = calendarType;
      _tabController.index = calendarType.id - 1;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
