import 'package:flutter/material.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:intl/intl.dart';

class Timesheet extends DatabaseProvider implements DatatypeImplements {
  static String className = 'timesheet';
  late DateTime start_time;
  late DateTime end_time;
  late String userid;
  late String remarks;
  late double break_time;
  late String timesheetId;

  Timesheet({
    required String userid,
    required String start_time,
    required String end_time,
    required String break_time,
    this.remarks = '',
    String timesheetId = ''
  }) {
    this.userid = userid;
    this.start_time = DateTime.parse(start_time);
    this.end_time = DateTime.parse(end_time);
    this.break_time = double.parse(break_time);
    if (isValid() && timesheetId.isEmpty) {
      this.timesheetId = generateUniqueV1Id();
    } else {
      this.timesheetId = timesheetId;
    }
  }

  String get getRecordId {
    return timesheetId;
  }

  String get getRemarks {
    return remarks;
  }

   Future<bool> remove() async {
    var r = await super.removeFromDatabase('user_records', this.timesheetId);
    return r;
  }

  bool isValid() {
    return true;
  }

  datatype get getDatatype {
    return datatype.TIMESHEET;
  }

  DateTime get getRecordDate {
    return start_time;
  }

  DateTime get getEndDateTime {
    return end_time;
  }

  DateTime get getStartDateTime {
    return start_time;
  }

  DateTime get getDate {
    return this.start_time;
  }

  double get workDuration {
    return ((end_time.difference(start_time).inMinutes - (break_time * 60)) /
        60);
  }

  void debugPrintProperties() {
    print('*****timesheet props******');
    print('break_time: $break_time');
    print('end_time: $end_time');
    print('start_time: $start_time');
    print('workDuration: $workDuration');
    print('userid: $userid');
    print('remarks: $remarks');
    print("************end***********");
  }

  double get getRenumeration {
    return workDuration * 10;
  }

  Map<String, Object> toMap() {
    return convertAllDateTimeToString({
      userRecordsTableKeys[userRecordsDatabaseKeys.TYPE] as String: className,
      userRecordsTableKeys[userRecordsDatabaseKeys.START_TIME] as String:
          start_time,
      userRecordsTableKeys[userRecordsDatabaseKeys.END_TIME] as String:
          end_time,
      userRecordsTableKeys[userRecordsDatabaseKeys.ID] as String: userid,
      userRecordsTableKeys[userRecordsDatabaseKeys.REMARKS] as String: remarks,
      userRecordsTableKeys[userRecordsDatabaseKeys.BREAK_HOURS] as String:
          break_time,
      userRecordsTableKeys[userRecordsDatabaseKeys.HOURS] as String:
          this.workDuration,
      'record_id': this.timesheetId
    });
  }

  List convertToPdfReportList(double payrate) {
    //start time endtime breakhours final hours remarks
    return [
      DateFormat('dd/MM/y HHmm').format(start_time),
      DateFormat('dd/MM/y HHmm').format(end_time),
      "${break_time.toString()}",
      this.workDuration.toString(),
      "${(this.workDuration * payrate).toStringAsFixed(2)}",
      remarks.isEmpty ? '-' : remarks.toString()
    ];
  }

  Future<bool> add() async {
    var r = await super.insertIntoDatabase('user_records', this);
    return r;
  }

  Future<bool> update(id) async {
    var r = await super.updateInDatabase('user_records', id, this);
    return r;
  }
}
