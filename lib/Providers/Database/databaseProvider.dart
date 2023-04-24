import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Classes/user.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Shared/databaseKeys.dart';

class DatabaseProvider extends ChangeNotifier with DatabaseMixin {
  List<Claim> existingClaims = [];
  List<Timesheet> existingTimesheets = [];
  //List res = []; //for any ad hoc data
  bool databaseQueryTimeout = false;

  Future<void> debugResetDatabase() async {
    await getDatabase();
    database.execute('DROP TABLE users');
    database.execute('DROP TABLE user_records');
  }

  Future<bool> tableIsEmpty(table_name) async {
    await getDatabase();
    if (database is Database) {
      final res = await database
          .rawQuery('SELECT * FROM $table_name')
          .catchError((e, st) {
        return [];
      });
      return res.isEmpty;
    }
    return false;
  }

  Future<bool> removeFromDatabase(table_name, id) async {
    await getDatabase();
    if (database is Database) {
      print("$id is IDD");
      final res = await database
          .delete(table_name, where: "record_id='${id.toString()}'")
          .catchError((e, st) {
        print("error $e");
        return 0;
      });
      return res > 0;
    }
    return false;
  }

  Future<List<Claim>> get getExistingClaims async {
    await this.getDatabase();
    await this.retrieveExistingClaimsAndTimesheets();
    return existingClaims;
  }

  Future<List<Timesheet>> get getExistingTimesheets async {
    await this.getDatabase();
    await this.retrieveExistingClaimsAndTimesheets();
    return existingTimesheets;
  }

  Map<String, Object> _checkIfHasToMap(Object x) {
    if (!(x is Map<String, Object>)) {
      if (x is User) {
        return x.toMap();
      } else if (x is Timesheet) {
        return x.toMap();
      } else if (x is Claim) {
        return x.toMap();
      } else {
        return {};
      }
    } else {
      return x;
    }
  }

  Future<void> retrieveExistingClaimsAndTimesheets() async {
    // debugResetDatabase();
    if (databaseQueryTimeout) return;
    List allRecords = await getFromTable('user_records');
    //print("allrecords is ${allRecords.first['id'].toString()}");
    if (allRecords.any((element) => element['type'] == Claim.className)) {
      existingClaims = allRecords
          .where((element) => element['type'] == Claim.className)
          .map((e) {
        return convertToClaimFromDatabase(e);
      }).toList();
      print("jii");
      if (existingClaims.length > 1) {
        existingClaims
            .sort((a, b) => b.getRecordDate.compareTo(a.getRecordDate));
      }
    }
    if (allRecords.any((element) => element['type'] == Timesheet.className)) {
      existingTimesheets = allRecords
          .where((element) => element['type'] == Timesheet.className)
          .map((e) => convertToTimeSheetFromDatabase(e))
          .toList();

      if (existingTimesheets.length > 1) {
        existingTimesheets
            .sort((a, b) => b.getRecordDate.compareTo(a.getRecordDate));
      }
    }
    notifyListeners();
    print("retrieve $existingClaims and $existingTimesheets");
    databaseQueryTimeout = true;
    new Future.delayed(const Duration(seconds: 10), () {
      databaseQueryTimeout = false;
    });
  }

  Future<User?> loadCurrentUser() async {
    await getDatabase();
    List userList = await getFromTable('users');
    if (userList.isNotEmpty) {
      Map firstUser = userList.first;
      return User(
        id:firstUser[userTableKeys[userDatabaseKeys.ID]],
          name: firstUser[userTableKeys[userDatabaseKeys.NAME]],
          company: firstUser[userTableKeys[userDatabaseKeys.COMPANY]],
          position: firstUser[userTableKeys[userDatabaseKeys.POSITION]],
          email: firstUser[userTableKeys[userDatabaseKeys.EMAIL]],
          payrate: firstUser[userTableKeys[userDatabaseKeys.PAY_RATE]],
          userSignature: firstUser[userTableKeys[userDatabaseKeys.SIGNATURE]],
          bank: firstUser[userTableKeys[userDatabaseKeys.BANK]],
          bank_num: firstUser[userTableKeys[userDatabaseKeys.BANK_NUMBER]]);
    } else {
      return User(
          name: '',
          company: '',
          position: '',
          email: '',
          payrate: 0,
          userSignature: Uint8List(0),
          bank: '',
          bank_num: '');
    }
  }

  Future<List> filterFromExistingClaims(filter) async {
    await this.retrieveExistingClaimsAndTimesheets();
    notifyListeners();
    return filter(existingClaims);
  }

  Future<List> getFromTable(String table_name,
      [Function? filterFunction]) async {
    //TO CONTINUE DEVELOPING
    Database db = await getDatabase();

    var res = await db
        .rawQuery('SELECT * FROM $table_name')
        .onError((error, stackTrace) async {
      return await db.rawQuery('SELECT * FROM $table_name');
    });
    if (filterFunction != null) {
      res = await filterFunction(res);
    }
    notifyListeners();
    return res;
  }

  Future<bool> updateInDatabase(
      String table_name, String id, Object new_val) async {
    Map<String, Object> nv = _checkIfHasToMap(new_val);

    String objectType =
        (new_val as Map).containsKey('signature') ? 'user' : 'non-user';
    // nv.removeWhere((key, value) => key == 'type');
    if (new_val is Map &&
        !nv.containsKey("${userTableKeys[userDatabaseKeys.ID]}")) {
      return false;
    }

    await this.getDatabase();
    if (database is Database) {
      print("AHHHOI $table_name");
      final res = await (database as Database).update(table_name, nv,
          where: objectType == 'user' ? 'id=?' : 'record_id=?',
          whereArgs: [id]).catchError((e, st) {
        print("ahh $e");
        return -1;
      });
      print("check $res");
      return res >= 0;
    }
    return false;
  }

  Future<bool> existsInDatabase(
      String table_name, String columnName, String uniqueValue) async {
    await database;
    if (database is Database) {
      final res = await database
          .rawQuery(
              'SELECT * FROM $table_name WHERE $columnName = $uniqueValue')
          .catchError((e, st) {
        return [];
      });
      return res.isNotEmpty;
    }
    return true;
  }

  Future<bool> insertIntoDatabase(String table_name, Object values) async {
    await getDatabase(); //review THIS
    Map<String, Object> nv = _checkIfHasToMap(values);
    if (values is Map &&
        (values["${userTableKeys[userDatabaseKeys.ID]}"]) == null) {
      return false;
    }
    await database;
    int res = 1;
    if (database is Database) {
      res = await database
          .insert(table_name, nv, conflictAlgorithm: ConflictAlgorithm.replace)
          .catchError((e, st) {
        print("eoorror is $e");
        return -1;
      }).whenComplete(() async {
        //JUST TESTING
        print(await getFromTable('user_records'));
      });
      print('res is ${await res}');
      return res != -1;
    } else {
      return false;
    }
  }
}
