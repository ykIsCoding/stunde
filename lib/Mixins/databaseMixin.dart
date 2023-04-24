import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/photograph.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Classes/user.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:uuid/uuid.dart';

mixin DatabaseMixin {
  bool hasToMapMethod = true;
  var database;

  Future<Database> getDatabase() async {
    if (!(database is Database)) {
      await _setUpDatabase();
    }

    return database;
  }

  List<Photograph> convertMapToPhotographList(Map x) {
    print("ket $x");
    return (x['photos'] as List)
        .map((e) => Photograph.photographFromUint8List(e))
        .toList();
  }

  Map<String, dynamic> convertStringToMap(String x) {
    print("heyre");
    var locateData = RegExp(r"{lasted_updated=(.*),\s*photos=\[(.*)\]}",
        caseSensitive: false);
    var matched = locateData.firstMatch(x.trim());
    print('HEY  HEY ${matched?.group(2)}');

    return matched != null
        ? {
            'timestamp': DateTime.parse(matched.group(1).toString()),
            'photos': matched?.group(2) != null
                ? matched
                    ?.group(2)
                    ?.split(',')
                    .where((element) => element.isNotEmpty)
                    .map((e) =>base64.normalize(e.trim()))
                    .map((e) => base64Decode(e))
                    .toList()
                : []
          }
        : {'timestamp': null, 'photos': null};
  }

  Timesheet convertToTimeSheetFromDatabase(e) {
    return new Timesheet(
        userid: e['id'].toString(),
        start_time: e['start_time'].toString(),
        end_time: e['end_time'].toString(),
        break_time: e['break_hours'].toString(),
        timesheetId: e['record_id'].toString(),
        remarks: e['remarks'].toString());
  }

  Claim convertToClaimFromDatabase(x) {
    final receiptPhotoRegExp =
        new RegExp(r"{lasted_updated=(.*),\s*photos=\[(.*)\]}");

    return new Claim(
        userid: x['id'].toString(),
        claimAmount: x['claim_amount'].toString(),
        claimDate: x['end_time'].toString(),
        receiptNumber: x['id'].toString(),
        receiptPhoto: convertStringToMap(x['receipt_image'].toString()),
        claimId: x['record_id'].toString());
  }

  Future<bool> _setUpDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    bool setUpOkay = false;
    database = await openDatabase(join(await getDatabasesPath(), 'stundedb.db'),
            onCreate: (db, version) async {
      // When creating the db, create the table
    }, onOpen: (db) async {
      setUpOkay = db is Database;
      await db.execute(
          'CREATE TABLE IF NOT EXISTS users (${userTableKeys[userDatabaseKeys.ID]} TEXT PRIMARY KEY, ${userTableKeys[userDatabaseKeys.NAME]} TEXT,${userTableKeys[userDatabaseKeys.POSITION]} TEXT, ${userTableKeys[userDatabaseKeys.EMAIL]} TEXT, ${userTableKeys[userDatabaseKeys.COMPANY]} TEXT,${userTableKeys[userDatabaseKeys.PAY_RATE]} REAL,${userTableKeys[userDatabaseKeys.BANK]} TEXT, ${userTableKeys[userDatabaseKeys.BANK_NUMBER]} TEXT,${userTableKeys[userDatabaseKeys.STATUS]} TEXT,${userTableKeys[userDatabaseKeys.SIGNATURE]} BLOB)');

      await db.execute(
          'CREATE TABLE IF NOT EXISTS user_records (${userRecordsTableKeys[userRecordsDatabaseKeys.ID]} TEXT ,record_id TEXT PRIMARY KEY, ${userRecordsTableKeys[userRecordsDatabaseKeys.TYPE]} TEXT, ${userRecordsTableKeys[userRecordsDatabaseKeys.HOURS]} REAL, ${userRecordsTableKeys[userRecordsDatabaseKeys.CLAIM_AMOUNT]} REAL, ${userRecordsTableKeys[userRecordsDatabaseKeys.START_TIME]} TEXT,${userRecordsTableKeys[userRecordsDatabaseKeys.END_TIME]} TEXT,${userRecordsTableKeys[userRecordsDatabaseKeys.RECEIPT_IMAGE]} BLOB,${userRecordsTableKeys[userRecordsDatabaseKeys.BREAK_HOURS]} REAL,${userRecordsTableKeys[userRecordsDatabaseKeys.REMARKS]} TEXT, FOREIGN KEY(id) REFERENCES users(id) )');
    }, version: 1)
        .catchError((e, st) {
      print(e);
    });

    return setUpOkay;
  }

  List<String> getAcceptableClasses() {
    return [User.className, Timesheet.className, Claim.className];
  }

  Future<Map> getRegisteredUser() async {
    Database? db = await getDatabase();
    var res = await db.rawQuery('SELECT * FROM users');
    //TO WORK ON ERROR HANDLING
    print("resq $res");
    return res.isNotEmpty ? res.first : {};
  }

  Future<String> get getRegisteredUserId async {
    Map m = await this.getRegisteredUser();
    return m.isNotEmpty ? m['id'] : '';
  }

  String generateUniqueV1Id() {
    return Uuid().v1();
  }

  Map<String, Object> convertAllDateTimeToString(Map<String, Object> obj) {
    obj.forEach((key, value) {
      if (obj[key] is DateTime) {
        obj[key] = (obj[key] as DateTime).toIso8601String();
      }
    });
    return obj;
  }
}
