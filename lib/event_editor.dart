import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_provider.dart';
import 'device_calendar_provider.dart';
import 'event_editor_logic.dart';
import 'models/calendar_event.dart';
import 'models/calendar_type.dart';
import 'models/enum_models.dart';
import 'models/event_editor_model.dart';
import 'models/event_editor_view_model.dart';
import 'models/zorastrian_date.dart';
import 'my_future_builder.dart';

class EventEditor extends StatefulWidget {
  final EditorMode editorTitle;
  final ZorastrianDate zorastrianDate;
  final CalendarEvent calendarEvent;

  EventEditor({this.editorTitle, this.zorastrianDate, this.calendarEvent});

  @override
  _EventEditorPageState createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditor> {
  final _formKey = GlobalKey<FormState>();
  final _logic = EventEditorLogic();

  showYearPicker(data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //1268-1470
        final numList = [for (var i = 1268; i <= 1470; i += 1) i];
        final _initialIndex = numList.indexOf(data.selectedYear);
        int _selectedYearIndex = _initialIndex;
        return AlertDialog(
          title: Text("Select Year"),
          content: CupertinoPicker(
            backgroundColor: Theme.of(context).backgroundColor,
            looping: true,
            itemExtent: 50,
            scrollController:
                FixedExtentScrollController(initialItem: _initialIndex),
            onSelectedItemChanged: (value) {
              _selectedYearIndex = value;
            },
            children: numList
                .map((x) => Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(x.toString())))
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL")),
            TextButton(
                onPressed: () async {
                  if (_selectedYearIndex != _initialIndex) {
                    final numListMap = numList.asMap();
                    final _selectedYear = numListMap[_selectedYearIndex];
                    await _logic.setEventEditorYear(_selectedYear);
                  }
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: Text("OK")),
          ],
        );
      },
    );
  }

  Future showCalendarPermissionsRequiredDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Calendar Permissions"),
            content: SingleChildScrollView(
                child: ListBody(
              children: [
                Text(
                    "App does not have calendar permissions granted to save to device calendar."),
                Text("Please grant permissions to continue."),
              ],
            )),
            actions: [
              TextButton(
                  onPressed: () {
                    AppSettings.openAppSettings();
                  },
                  child: Text("Go to settings"))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _logic.setEventEditorState(
        editorTitle: widget.editorTitle,
        calendarEvent: widget.calendarEvent,
        zorastrianDate: widget.zorastrianDate);
  }

  @override
  void dispose() {
    super.dispose();
    _logic.clearEventEditorState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceCalendarState = AppProvider.of(context).deviceCalendarState;

    return MyFutureBuilder<EventEditorViewModel>(
      future: _logic.getEventEditorData(),
      builder: (context, data) {
        return Scaffold(
          appBar: AppBar(
            title: Text(data.editorTitle),
            actions: <Widget>[
              if (widget.editorTitle == EditorMode.Edit)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _logic.deleteEvent(widget.calendarEvent);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: new ListView(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Enter Name', hintText: 'Name'),
                    initialValue: data.eventTitle,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _logic.setEventEditorEventTitle(value);
                      setState(() {});
                    },
                  ),
                  DropdownButtonFormField<CalendarType>(
                    decoration: InputDecoration(labelText: "Calendar Type"),
                    value: data.selectedCalendarType,
                    items: data.calendarTypes
                        .where((x) => x.id != 4)
                        .map((x) =>
                            DropdownMenuItem(value: x, child: Text(x.name)))
                        .toList(),
                    onChanged: (value) {
                      _logic.setEventEditorCalendarType(value);
                      setState(() {});
                    },
                    isExpanded: true,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Roj"),
                    value: data.selectedRoj,
                    items: data.rojCollection
                        .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                        .toList(),
                    onChanged: (value) async {
                      await _logic.setEventEditorRoj(value);
                      setState(() {});
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Mah"),
                    value: data.selectedMah,
                    items: data.mahCollection
                        .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                        .toList(),
                    onChanged: (value) async {
                      await _logic.setEventEditorMah(value);
                      setState(() {});
                    },
                  ),
                  GestureDetector(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: "Year"),
                      child: Text(data.selectedYear.toString()),
                    ),
                    onTap: () {
                      showYearPicker(data);
                    },
                  ),
                  GestureDetector(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: "Date"),
                      child: Text(DateFormat("EEEE dd/M/yyyy")
                          .format(data.selectedDate)),
                    ),
                    onTap: () async {
                      DateTime pickedDate = await showDatePicker(
                          context: context,
                          initialDate: data.selectedDate,
                          firstDate: DateTime(1900, 1, 1),
                          lastDate: DateTime(2100, 12, 31));

                      if (pickedDate != null &&
                          pickedDate != data.selectedDate) {
                        await _logic.setEventEditorDate(pickedDate);
                      }
                      setState(() {});
                    },
                  ),
                  ElevatedButton(
                    child: Text("Save"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        if (deviceCalendarState ==
                            DeviceCalendarState.Disabled) {
                          await _logic.saveEventEditorEvent();
                        } else {
                          if (await DeviceCalendarProvider
                              .isPermissionsGranted()) {
                            if (deviceCalendarState ==
                                DeviceCalendarState.NotInitialized) {
                              await _logic.initializeDeviceCalendar();
                              AppProvider.of(context).callSetState();
                            }
                            await _logic.saveEventToDeviceCalendar();
                            await _logic.saveEventEditorEvent();
                          } else {
                            await showCalendarPermissionsRequiredDialog();
                          }
                        }
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
