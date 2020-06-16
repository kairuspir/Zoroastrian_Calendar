import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'database.dart';
import 'models/calendar_event.dart';
import 'models/calendar_type.dart';
import 'models/event_editor_model.dart';
import 'models/event_editor_view_model.dart';
import 'models/zorastrian_date.dart';
import 'my_future_builder.dart';
import 'utilities.dart';

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
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL")),
            FlatButton(
                onPressed: () async {
                  if (_selectedYearIndex != _initialIndex) {
                    final numListMap = numList.asMap();
                    final _selectedYear = numListMap[_selectedYearIndex];
                    await DBProvider.db.setEventEditorYear(_selectedYear);
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

  @override
  void initState() {
    super.initState();
    DBProvider.db.setEventEditorState(
        editorTitle: widget.editorTitle,
        calendarEvent: widget.calendarEvent,
        zorastrianDate: widget.zorastrianDate);
  }

  @override
  void dispose() {
    super.dispose();
    DBProvider.db.clearEventEditorState();
  }

  @override
  Widget build(BuildContext context) {
    return MyFutureBuilder<EventEditorViewModel>(
      future: DBProvider.db.getEventEditorData(),
      builder: (context, data) {
        return Scaffold(
          appBar: AppBar(
            title: Text(data.editorTitle),
            actions: <Widget>[
              if (widget.editorTitle == EditorMode.Edit)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await DBProvider.db.deleteEvent(widget.calendarEvent);
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
                      DBProvider.db.setEventEditorEventTitle(value);
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
                      DBProvider.db.setEventEditorCalendarType(value);
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
                      await DBProvider.db.setEventEditorRoj(value);
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
                      await DBProvider.db.setEventEditorMah(value);
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
                        await DBProvider.db.setEventEditorDate(pickedDate);
                      }
                      setState(() {});
                    },
                  ),
                  DropdownButtonFormField<Frequency>(
                    decoration: InputDecoration(labelText: "Frequency"),
                    value: data.selectedFrequency,
                    items: data.frequencyCollection
                        .map((x) => DropdownMenuItem(
                            value: x, child: Text(x.toShortString())))
                        .toList(),
                    onChanged: (value) {
                      DBProvider.db.setEventEditorFrequency(value);
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    child: Text("Save"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        await DBProvider.db.saveEventEditorEvent();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  RaisedButton(
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
