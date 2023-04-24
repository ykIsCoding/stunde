import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:signature/signature.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:stunde/Shared/userStatusEnum.dart';

class User extends DatabaseProvider {
  static String className = 'user';
  final String name;
  final String company;
  final String position;
  late String bank;
  late String bank_num;
  final String email;
  String status = 'available';
  Uint8List userSignature;
  final double payrate;
  late String id;
  static const stringStatuses = {
    userStatus.AVAILABLE: 'available',
    userStatus.SUSPENDED: 'suspended',
    userStatus.UNAVAILABLE: 'unavailable'
  };

  Future<bool> alreadyExists() async {
    var r = await super.existsInDatabase('users', 'email', email);
    return r;
  }

  Map<String, Object> toMap() {
    return {
      userTableKeys[userDatabaseKeys.NAME] as String: name,
      userTableKeys[userDatabaseKeys.COMPANY] as String: company,
      userTableKeys[userDatabaseKeys.POSITION] as String: position,
      userTableKeys[userDatabaseKeys.EMAIL] as String: email,
      userTableKeys[userDatabaseKeys.STATUS] as String: status,
      userTableKeys[userDatabaseKeys.SIGNATURE] as String: userSignature,
      userTableKeys[userDatabaseKeys.PAY_RATE] as String: payrate.toDouble(),
      userTableKeys[userDatabaseKeys.BANK] as String: bank,
      userTableKeys[userDatabaseKeys.BANK_NUMBER] as String: bank_num,
      userTableKeys[userDatabaseKeys.ID] as String: id,
    };
  }

  void setSignature(Uint8List ns) {
    this.userSignature = ns;
  }

  String get getUserName {
    return this.name;
  }

  Future<String> update() async {
    //save signature as uint8list
    bool outcome = await super.updateInDatabase('users', this.id, this.toMap());
    if (outcome) {
      return this.id;
    } else {
      return '';
    }
  }

  Future<String> save() async {
    //save signature as uint8list
    bool outcome = await super.insertIntoDatabase('users', this.toMap());
    if (outcome) {
      return this.id;
    } else {
      return '';
    }
  }

  User(
      {required this.name,
      required this.company,
      required this.position,
      required this.email,
      required this.payrate,
      required this.userSignature,
      required this.bank,
      required this.bank_num,
      this.id='',
      status = userStatus.AVAILABLE}) {
    this.status = (stringStatuses[status]).toString();
    if (this.id.isEmpty) {
      this.id = generateUniqueV1Id();
    }
  }
}
