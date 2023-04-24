import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Pages/homePage.dart';
import 'package:stunde/Widgets/appSnackBar.dart';

class FormPage extends StatefulWidget {
  Map previousData = {};
  FormPage([previousData]) {
    if (previousData != null) {
      this.previousData = previousData;
    }
  }
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _timesheetFormKey = GlobalKey<FormState>();
  var _dateController = TextEditingController();
  String _remarks = "";
  double break_hours = 0;
  double work_duration = 0;
  late DateTime start_time;
  late DateTime end_time;
  bool editingMode = false;

  initState() {
    super.initState();
    Map? previousData = widget.previousData;
    if (previousData.isNotEmpty && previousData['action'] == 'edit') {
      setState(() {
        editingMode = true;
        _remarks = previousData['remarks'];
        start_time = DateTime.parse(previousData['start_time']);
        end_time = DateTime.parse(previousData['end_time']);
        break_hours = previousData['break_hours'];
        work_duration = this.work_duration;
      });
    }
  }

  Widget build(BuildContext context) {
    //  _dateController.value = new DateTime.now().toString() as TextEditingValue;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
              key: _timesheetFormKey,
              child: Column(
                children: [
                  Text("Add a timesheet"),
                  Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: DateTimePicker(
                          type: DateTimePickerType.dateTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2023),
                          controller: editingMode ? null : _dateController,
                          decoration: InputDecoration(
                            hintText: "Select Start Date and Time",
                            prefixIcon: IconButton(
                                onPressed: () => null,
                                icon: Icon(Icons.calendar_today_outlined)),
                          ),
                          dateLabelText: "Start Date",
                          timeLabelText: "Start Time",
                          initialValue:
                              editingMode ? start_time.toString() : null,
                          dateHintText: "Enter date",
                          timeHintText: "Enter time",
                          onChanged: (val) => print(val),
                          validator: (val) {
                            print(val);
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              start_time = DateTime.parse(val.toString());
                            });
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {
                              _dateController.clear();
                            },
                            icon: Icon(Icons.clear_all_sharp)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: DateTimePicker(
                          type: DateTimePickerType.dateTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2023),
                          decoration: InputDecoration(
                            hintText: "Select End Date",
                            prefixIcon: IconButton(
                                onPressed: () => null,
                                icon: Icon(Icons.calendar_today_outlined)),
                          ),
                          dateLabelText: "End Date",
                          timeLabelText: "End Time",
                          initialValue:
                              editingMode ? end_time.toString() : null,
                          initialDate: editingMode ? end_time : null,
                          dateHintText: "Enter date",
                          timeHintText: "Enter time",
                          onChanged: (val) => print(val),
                          validator: (val) {
                            print(val);
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              end_time = DateTime.parse(val.toString());
                            });
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {
                              _dateController.clear();
                            },
                            icon: Icon(Icons.clear_all_sharp)),
                      )
                    ],
                  ),
                  TextFormField(
                    onEditingComplete: () =>
                        _timesheetFormKey.currentState?.save(),
                    onSaved: (value) {
                      setState(() {
                        break_hours = double.parse(value.toString());
                      });
                    },
                    initialValue: editingMode ? break_hours.toString() : '',
                    decoration: InputDecoration(hintText: "Break Hour(s)"),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _remarks = value;
                      });
                    },
                    initialValue: editingMode ? _remarks : '',
                    decoration: InputDecoration(
                        hintText: "Remarks",
                        counter: Text("${_remarks.length}/200")),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        _timesheetFormKey.currentState?.save();
                        print("het");
                        Timesheet ts = new Timesheet(
                            userid: '0',
                            timesheetId: '',
                            remarks: _remarks,
                            start_time: start_time.toIso8601String(),
                            end_time: end_time.toIso8601String(),
                            break_time: break_hours.toString());
                        setState(() {
                          work_duration = ts.workDuration;
                        });

                        var test = false;
                        if (!editingMode) {
                          test = await ts.add();
                          Navigator.popUntil(
                              context, ModalRoute.withName(HomePage.routeName));
                        } else {
                          ts.timesheetId = widget.previousData['record_id'];
                          test =
                              await ts.update(widget.previousData['record_id']);
                          Navigator.pop(context);
                        }

                        // Navigator.popAndPushNamed(context, HomePage.routeName);
                        final SnackBar snackbar = AppSnackBar(test ,Text("Success!"),Text("Error!"));
                        
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      },
                      child: Text("Submit")),
                  Text("I worked $work_duration today")
                ],
              )),
        ),
      ),
    );
  }
}


