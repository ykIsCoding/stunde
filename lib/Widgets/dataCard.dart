import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Providers/deviceSettingsProvider.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import '../Shared/dataTypeEnum.dart';

class DataCard extends StatelessWidget {
  var dataObject;
  datatype type = datatype.UNDEFINED;
  late BuildContext bctx;
  DateTime date = DateTime.now();

  double hours = 0;

  double claimAmount = 0;

  double payPerHour = 10;

  DataCard(dataObject) {
    if (dataObject != null) {
      this.dataObject = dataObject;
      this.type = dataObject?.getDatatype;
      this.date = dataObject?.getRecordDate;
      this.hours = dataObject.getDatatype==datatype.TIMESHEET?dataObject.workDuration:0;
      this.claimAmount = dataObject?.getRenumeration;
    }
  }

  double get incomeIncrement {
    if (type == datatype.CLAIM) {
      return claimAmount;
    } else {
      return hours * payPerHour;
    }
  }

  String processedDate(DateTime x) {
    DateFormat df = new DateFormat("dd/MM/yyyy");
    return df.format(x);
  }

  Widget build(BuildContext context) {
    final deviceSettingsProvider = Provider.of<DeviceSettingsProvider>(context);
    return this.dataObject == null
        ? Card(
            child: Center(
              child: Text("No data available"),
            ),
          )
        : Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(40))),
          child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${processedDate(date)}"),
                          ],
                        ),
                        SizedBox(
                            height:
                                deviceSettingsProvider.deviceSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (type == datatype.TIMESHEET)
                              Text("Hours: ${hours}"),
                            if (type == datatype.CLAIM)
                              Text("Claim Amount: \$${claimAmount}"),
                          ],
                        )
                      ],
                    ),
                    Text("+${incomeIncrement}")
                  ],
                ),
              ),
            ),
        );
  }
}
