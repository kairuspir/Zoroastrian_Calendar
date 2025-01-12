import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:zoroastriancalendar/app_provider.dart';
import 'package:zoroastriancalendar/home_tab.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';
import 'package:zoroastriancalendar/models/month_tab_model.dart';
import 'package:zoroastriancalendar/models/month_tab_view_model.dart';
import 'package:zoroastriancalendar/month_tab_logic.dart';
import 'package:zoroastriancalendar/month_tab_provider.dart';
import 'package:zoroastriancalendar/my_future_builder.dart';
import 'package:zoroastriancalendar/widgets.dart';

class MonthTab extends StatefulWidget {
  static const title = 'Month';
  static final androidIcon = Icon(MdiIcons.calendarMonth);
  static const iosIcon = Icon(CupertinoIcons.calendar);

  @override
  _MonthTabState createState() => _MonthTabState();
}

class _MonthTabState extends State<MonthTab> {
  final _logic = MonthTabLogic();
  late AppProvider appProvider;
  late Future<MonthTabViewModel> viewmodel;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = AppProvider.of(context)!;
    if (appProvider != this.appProvider) {
      final calendarType = appProvider.calendarType.name;
      final now = DateTime.now();
      _logic.setModel(MonthTabModel(
          mode: MonthTabCalendarMode.Zoroastrian,
          selectedDate: DateTime(now.year, now.month, now.day),
          calendarType: calendarType));
      setViewModel();
    }
  }

  void setViewModel() {
    setState(() {
      viewmodel = _logic.getMonthTabData();
    });
  }

  void goToPreviousYear() async {
    await _logic.setPreviousYear();
    setViewModel();
  }

  void goToNextYear() async {
    await _logic.setNextYear();
    setViewModel();
  }

  void goToYear(int year) async {
    await _logic.setYear(year);
    setViewModel();
  }

  void goToPreviousMonth() async {
    await _logic.setPreviousMonth();
    setViewModel();
  }

  void goToNextMonth() async {
    await _logic.setNextMonth();
    setViewModel();
  }

  void goToMonth(String month) async {
    await _logic.setMonth(month);
    setViewModel();
  }

  Widget _buildTab() {
    final borderColor = Theme.of(context).colorScheme.primary;
    return MonthTabProvider(
      mode: _logic.model.mode,
      child: MyFutureBuilder<MonthTabViewModel>(
        future: viewmodel,
        builder: (context, data) => Container(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    RotatedBox(
                      quarterTurns: 2,
                      child: IconButton(
                        icon: Icon(Icons.double_arrow),
                        onPressed: () => goToPreviousYear(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () => goToPreviousMonth(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              "${data.secondaryCalendarFromMonth} ${data.secondaryCalendarFromYear} - ${data.secondaryCalendarToMonth} ${data.secondaryCalendarToYear}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DropdownButton<String>(
                            items: data.monthCollection
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: data.primaryCalendarMonth,
                            onChanged: (String? value) => goToMonth(value!),
                          ),
                          DropdownButton<int>(
                            items: data.yearCollection
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            value: data.primaryCalendarYear,
                            onChanged: (int? value) => goToYear(value!),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () => goToNextMonth(),
                    ),
                    IconButton(
                      icon: Icon(Icons.double_arrow),
                      onPressed: () => goToNextYear(),
                    ),
                  ],
                ),
                Table(
                  border: TableBorder.all(
                      color: borderColor, width: 1, style: BorderStyle.solid),
                  children: [
                    ...data.tableData.map(
                      (tr) => TableRow(
                        children: [
                          ...tr.map(
                            (td) => TableCell(
                              child: DayCell(viewModel: td),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
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

class DayCell extends StatelessWidget {
  final DayInMonthTabViewModel viewModel;

  DayCell({required this.viewModel});
  @override
  Widget build(BuildContext context) {
    if (this.viewModel is HeaderCellInDayInMonthTabViewModel) {
      return HeaderCell(
          viewModel: viewModel as HeaderCellInDayInMonthTabViewModel);
    } else {
      return BodyCell(viewModel: viewModel as BodyCellInDayInMonthTabViewModel);
    }
  }
}

class HeaderCell extends StatelessWidget {
  final HeaderCellInDayInMonthTabViewModel viewModel;

  HeaderCell({required this.viewModel});
  @override
  Widget build(BuildContext context) {
    final nameOfDay =
        (MediaQuery.of(context).orientation == Orientation.portrait)
            ? this.viewModel.nameOfDayShort
            : this.viewModel.nameOfDay;
    return Center(child: Text(nameOfDay));
  }
}

class BodyCell extends StatelessWidget {
  final BodyCellInDayInMonthTabViewModel viewModel;

  BodyCell({required this.viewModel});
  @override
  Widget build(BuildContext context) {
    if (viewModel is PopulatedBodyCellInDayInMonthTabViewModel) {
      final pvm = viewModel as PopulatedBodyCellInDayInMonthTabViewModel;
      final mode = MonthTabProvider.of(context)!.mode;
      final backgroundColor = Theme.of(context).highlightColor;
      final primaryColor = Theme.of(context).colorScheme.primary;
      return InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeTab(selectedDate: pvm.gregorianDate)),
        ),
        child: Container(
          color: pvm.isToday ? backgroundColor : null,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (mode == MonthTabCalendarMode.Zoroastrian)
                ? [
                    Text("${pvm.dayOfMonth} ${pvm.gregorianMonthName}",
                        textAlign: TextAlign.center),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(pvm.rojName, textAlign: TextAlign.center),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...pvm.events.map((e) => Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: primaryColor)))
                      ],
                    ),
                  ]
                : [
                    Text(pvm.dayOfMonth.toString()),
                    Text(pvm.rojName),
                    Text(pvm.mahName),
                  ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
