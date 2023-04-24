import 'package:flutter/material.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';

class DatatypeImplements {
  String get getRecordId {
    return '';
  }

  DateTime get getDate {
    return DateTime.now();
  }

  String get getRemarks {
    return '';
  }

  datatype get getDatatype {
    return datatype.TIMESHEET;
  }

  DateTime get getRecordDate {
    return DateTime.now();
  }

  double get getRenumeration {
    return 0;
  }

  bool isValid() {
    return true;
  }
}
