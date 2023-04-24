import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stunde/Classes/photograph.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Shared/databaseKeys.dart';

class Claim extends DatabaseProvider implements DatatypeImplements {
  static String className = 'claim';
  late String userid;
  late double claimAmount;
  late String remark;
  late DateTime claimDate;
  late String receiptNumber;
  late String claimId;
  Map receiptPhoto = {'timestamp': null, 'photos': null};

  String get getRecordId {
    return claimId;
  }

  String get getRemarks {
    return remark;
  }

  //can i do submit claim will change notifier work?
  bool isValid() {
    return true;
  }

  datatype get getDatatype {
    return datatype.CLAIM;
  }

  double get getRenumeration {
    return claimAmount;
  }

  List<Uint8List> get getReceiptImage {
    print("Hey $receiptPhoto['photos']");
    return receiptPhoto['photos']==null?[]:receiptPhoto['photos'] as List<Uint8List>;
  }

  double get getClaimAmount {
    return claimAmount;
  }

  DateTime get getRecordDate {
    return claimDate;
  }

  List convertToPdfReportList() {
    //date receiptnumber claimamount image remarks
    return [
      claimDate.toIso8601String(),
      claimAmount.toString(),
      remark.toString(),
      receiptPhoto['photos']
    ];
  }

  DateTime get getDate {
    return this.claimDate;
  }

  Map<String, Object> toMap() {
    print("rp is $receiptPhoto");
    return convertAllDateTimeToString({
      userRecordsTableKeys[userRecordsDatabaseKeys.ID] as String: userid,
      userRecordsTableKeys[userRecordsDatabaseKeys.TYPE] as String: className,
      userRecordsTableKeys[userRecordsDatabaseKeys.CLAIM_AMOUNT] as String:
          claimAmount,
      userRecordsTableKeys[userRecordsDatabaseKeys.REMARKS] as String:
          '[RECEIPT NO: $receiptNumber]\n$remark',
      userRecordsTableKeys[userRecordsDatabaseKeys.START_TIME] as String:
          claimDate,
      userRecordsTableKeys[userRecordsDatabaseKeys.END_TIME] as String:
          claimDate,
      userRecordsTableKeys[userRecordsDatabaseKeys.RECEIPT_IMAGE] as String:
          receiptPhoto,
      'record_id': this.claimId
    });
  }

  Future<bool> add() async {
    var r = await super.insertIntoDatabase('user_records', this);
    return r;
  }

  Future<bool> remove() async {
    var r = await super.removeFromDatabase('user_records', this.claimId);
    return r;
  }

  Claim(
      {required String userid,
      required String claimAmount,
      required String claimDate,
      required String receiptNumber,
      required Map<String, dynamic> receiptPhoto,
      String remark = '',
      String claimId = ''}) {
    this.userid = userid;
    this.claimAmount = double.parse(claimAmount);
    this.claimDate = DateTime.parse(claimDate);
    this.receiptNumber = receiptNumber.toString();
    this.receiptPhoto = receiptPhoto;
    this.remark = remark;
    if (claimId.isEmpty && isValid()) {
      this.claimId = generateUniqueV1Id();
    } else {
      this.claimId = claimId;
    }
  }
}
