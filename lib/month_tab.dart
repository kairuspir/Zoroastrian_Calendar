import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:zoroastriancalendar/app_provider.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';
import 'package:zoroastriancalendar/models/month_tab_view_model.dart';
import 'package:zoroastriancalendar/month_tab_logic.dart';
import 'package:zoroastriancalendar/month_tab_provider.dart';
import 'package:zoroastriancalendar/my_future_builder.dart';
import 'package:zoroastriancalendar/widgets.dart';

class MonthTab extends StatefulWidget {
  static const title = 'Month';
  static const androidIcon = Icon(MdiIcons.calendarMonth);
  static const iosIcon = Icon(CupertinoIcons.calendar);

  @override
  _MonthTabState createState() => _MonthTabState();
}

class _MonthTabState extends State<MonthTab> {
  final _logic = MonthTabLogic();
  Widget _buildTab() {
    return MonthTabProvider(
        mode: _logic.mode,
        child: MyFutureBuilder<MonthTabViewModel>(
          future: _logic.getMonthTabData(),
          builder: (context, data) => Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(),
                  Table(
                    border: TableBorder.all(
                        color: Colors.black26,
                        width: 1,
                        style: BorderStyle.none),
                    children: [
                      ...data.tableData.map((tr) => TableRow(children: [
                            ...tr.map((td) => TableCell(
                                  child: DayCell(viewModel: td),
                                ))
                          ]))
                    ],
                  )
                ],
              )),
        ));
  }

  @override
  void initState() {
    super.initState();
    final calendarType = AppProvider.of(context).calendarType.name;
    _logic.initState(
        mode: MonthTabCalendarMode.Zoroastrian,
        selectedDate: DateTime.now(),
        calendarType: calendarType);
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

  DayCell({this.viewModel});
  @override
  Widget build(BuildContext context) {
    if (this.viewModel is HeaderCellInDayInMonthTabViewModel) {
      return HeaderCell(viewModel: viewModel);
    } else {
      return BodyCell(viewModel: viewModel);
    }
  }
}

class HeaderCell extends StatelessWidget {
  final HeaderCellInDayInMonthTabViewModel viewModel;

  HeaderCell({this.viewModel});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(this.viewModel.nameOfDay));
  }
}

class BodyCell extends StatelessWidget {
  final BodyCellInDayInMonthTabViewModel viewModel;

  BodyCell({this.viewModel});
  @override
  Widget build(BuildContext context) {
    if (viewModel is PopulatedBodyCellInDayInMonthTabViewModel) {
      final pvm = viewModel as PopulatedBodyCellInDayInMonthTabViewModel;
      final mode = MonthTabProvider.of(context).mode;
      final backgroundColor = Theme.of(context).highlightColor;
      return Container(
        color: pvm.isToday ? backgroundColor : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (mode == MonthTabCalendarMode.Zoroastrian)
              ? [
                  Text(
                      pvm.dayOfMonth.toString() + " " + pvm.gregorianMonthName),
                  Text(pvm.rojName),
                ]
              : [
                  Text(pvm.dayOfMonth.toString()),
                  Text(pvm.rojName),
                  Text(pvm.mahName),
                ],
        ),
      );
    } else {
      return Container();
    }
  }
}
