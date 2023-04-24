import 'dart:async' as a;
import 'dart:io' as dio;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pdfw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Shared/databaseKeys.dart';

class PdfReport with DatabaseMixin {
  final pdf = pdfw.Document();
  final datatype reportType;
  String filePath = '';
  List details = [];
  PdfReport(this.reportType, this.details) {
    if (!(this.details is DatatypeImplements)) {
      if (this.reportType == datatype.TIMESHEET) {
        this.details =
            details.map((e) => convertToTimeSheetFromDatabase(e)).toList();
      } else {
        this.details =
            details.map((e) => convertToClaimFromDatabase(e)).toList();
      }
    }
  }
  static const List claimsHeaders = [
    'Date',
    'Receipt No.',
    'Claim Amount',
    'Receipt Images',
    'Remarks'
  ];

  static pdfw.Widget header(dt, userData) {
    return pdfw.Column(
        crossAxisAlignment: pdfw.CrossAxisAlignment.start,
        children: [
          dt == datatype.TIMESHEET
              ? pdfw.Text("Timesheet Report",
                  style: pdfw.TextStyle(
                      fontSize: 20, fontWeight: pdfw.FontWeight.bold))
              : pdfw.Text("Claims Report"),
          pdfw.SizedBox(height: PdfPageFormat.cm * 1),
          pdfw.Text(userData[userTableKeys[userDatabaseKeys.NAME]]
              .toString()
              .toUpperCase()),
          pdfw.Text(userData[userTableKeys[userDatabaseKeys.POSITION]]
              .toString()
              .toUpperCase()),
          pdfw.Text(userData[userTableKeys[userDatabaseKeys.COMPANY]]
              .toString()
              .toUpperCase()),
          pdfw.Text(
              "${userData[userTableKeys[userDatabaseKeys.BANK]]} ${userData[userTableKeys[userDatabaseKeys.BANK_NUMBER]]}"),
          pdfw.SizedBox(height: PdfPageFormat.cm * 2)
        ]);
  }

  static a.Future openReport(dio.File file) async {
    final link = file.path;
    await OpenFile.open(link);
  }

  a.Future<dio.File> saveProgress({required name}) async {
    final bytes = await pdf.save();
    final currentDirectory = await getApplicationDocumentsDirectory();
    final filePath = dio.File('${currentDirectory.path}/$name');
    await filePath.writeAsBytes(bytes);
    return filePath;
  }

  static pdfw.Widget tableSummary(details, userdata) {
    return pdfw.Container(
        margin: pdfw.EdgeInsets.only(
            left: PdfPageFormat.cm * 3, right: PdfPageFormat.cm * 3),
        alignment: pdfw.Alignment.centerRight,
        child: pdfw
            .Row(mainAxisAlignment: pdfw.MainAxisAlignment.start, children: [
          pdfw.Spacer(flex: 7),
          pdfw.Expanded(
              flex: 3,
              child: pdfw.Column(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                  children: [
                    pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfw.Text("Total Hours",
                              style: pdfw.TextStyle(
                                  fontWeight: pdfw.FontWeight.bold)),
                          pdfw.SizedBox(width: PdfPageFormat.cm * 2),
                          pdfw.Text(
                              "${details.map((x) => x.workDuration).reduce((value, element) => value + element)} hours",
                              style: pdfw.TextStyle(
                                  fontWeight: pdfw.FontWeight.bold))
                        ]),
                    pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfw.Text("Total Earnings",
                              style: pdfw.TextStyle(
                                  fontWeight: pdfw.FontWeight.bold)),
                          pdfw.SizedBox(width: PdfPageFormat.cm * 2),
                          pdfw.Text(
                              "\$${details.map((x) => x.workDuration).reduce((value, element) => value + element) * userdata[userTableKeys[userDatabaseKeys.PAY_RATE]]}",
                              style: pdfw.TextStyle(
                                  fontWeight: pdfw.FontWeight.bold))
                        ])
                  ]))
        ]));
  }

  static pdfw.Widget reportDetails(List<DatatypeImplements> data) {
    data.sort((DatatypeImplements a, DatatypeImplements b) {
      return a.getRecordDate.compareTo(b.getDate);
    });
    var earliest = DateFormat("dd/MM/yyyy").format(data.first.getDate);
    var latest = DateFormat("dd/MM/yyyy").format(data.last.getDate);
    return pdfw.Column(
        crossAxisAlignment: pdfw.CrossAxisAlignment.start,
        children: [
          pdfw.Row(children: [
            pdfw.Text("Date Range: $earliest - $latest",
                style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold))
          ]),
          pdfw.Text(
              "Report generated on\n${DateFormat("dd/MM/yyyy H:m:s").format(DateTime.now())}\nAll dates are in DD/MM/YYYY.")
        ]);
  }

  _countByDataType(datatype type, td) {
    return td
        .where((DatatypeImplements element) => element.getDatatype == type)
        .toList()
        .length;
  }

  Future<void> createReport() async {
    Map userDetails = await getRegisteredUser();
    var tempDetails = details;
    var i = 0;
    
      final fp = pdfw.MultiPage(
          margin: pdfw.EdgeInsets.all(PdfPageFormat.cm * 2),
          pageFormat: PdfPageFormat.a4,
          build: (pdfw.Context context) {
            return reportType == datatype.TIMESHEET
                ? [
                    pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                        children: [
                          header(reportType, userDetails),
                          reportDetails(tempDetails as List<DatatypeImplements>)
                        ]),
                    createTimesheetsReport(tempDetails, userDetails),
                    pdfw.Divider(),
                    pdfw.SizedBox(height: PdfPageFormat.cm * 0.5),
                    tableSummary(tempDetails, userDetails),
                    pdfw.Spacer(flex: 4),
                    pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.center,
                        children: [
                          pdfw.Expanded(
                              flex: 4,
                              child: analysisSection(
                                  details as List<DatatypeImplements>)),
                          pdfw.Spacer(flex: 1),
                          pdfw.Expanded(
                              flex: 4, child: signatureSection(userDetails))
                        ])
                  ]
                : [
                    pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                        children: [
                          header(reportType, userDetails),
                          reportDetails(tempDetails as List<DatatypeImplements>)
                        ]),
                    createClaimReport(tempDetails, userDetails),
                   pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.center,
                        children: [
                          pdfw.Spacer(flex: 2),
                          pdfw.Expanded(
                              flex: 1, child: signatureSection(userDetails))
                        ])
                  ];
          });
      pdf.addPage(fp);
      print("add page");
   
    

    var fpath = await saveProgress(name: 'timesheet');
    this.filePath = fpath.path;
    //await openReport(fpath);
  }

  pdfw.Widget analysisSection(List<DatatypeImplements> data) {
    int clash = 0;
    int invalidWorkDuration = 0;
    data.sort((DatatypeImplements a, DatatypeImplements b) {
      return a.getRecordDate.compareTo(b.getDate);
    });
    if (data.every((element) => element is Timesheet)) {
      var listOfEndDateTimes =
          data.map((e) => (e as Timesheet).getEndDateTime).toList();
      var listOfStartDateTimes =
          data.map((e) => (e as Timesheet).getStartDateTime).toList();
      for (var x = 0; x < listOfEndDateTimes.length - 1; x++) {
        if (listOfEndDateTimes[x].isAfter(listOfStartDateTimes[x + 1])) {
          clash += 1;
        }
      }
      invalidWorkDuration = data
          .where((element) => (element as Timesheet).workDuration < 0)
          .length;
    }

    String validateReport() {
      String initial = '';
      if (clash == 0) {
        initial += "There are no clashes in time logs.\n";
      } else {
        initial +=
            "There ${invalidWorkDuration > 1 ? 'are' : 'is'} $clash ${clash > 1 ? 'clashes' : 'clash'} in time logs.\n";
      }

      if (invalidWorkDuration == 0) {
        initial += "All work durations are valid.";
      } else {
        initial +=
            "There ${invalidWorkDuration > 1 ? 'are' : 'is'} $invalidWorkDuration invalid work ${invalidWorkDuration > 1 ? 'durations' : 'duration'}.";
      }
      return initial;
    }

    return pdfw.Column(
        crossAxisAlignment: pdfw.CrossAxisAlignment.start,
        children: [
          pdfw.Row(children: [pdfw.Text(validateReport())])
        ]);
  }

  pdfw.Widget signatureSection(user) {
    return pdfw.Container(
        width: PdfPageFormat.cm * 5,
        child: pdfw.Column(children: [
          pdfw.Row(children: [
            pdfw.Container(
                height: PdfPageFormat.cm * 4,
                width: PdfPageFormat.cm * 4,
                child: pdfw.Column(children: [
                  pdfw.Image(pdfw.MemoryImage(
                      user[userTableKeys[userDatabaseKeys.SIGNATURE]]
                          as Uint8List)),
                ])),
            pdfw.SizedBox(width: PdfPageFormat.cm * 0.5),
            pdfw.Container(
                height: PdfPageFormat.cm * 3,
                width: PdfPageFormat.cm * 3,
                child: pdfw.BarcodeWidget(
                    barcode: pdfw.Barcode.qrCode(),
                    data: user[userTableKeys[userDatabaseKeys.ID]]))
          ]),
          pdfw.Divider(),
          pdfw.Text(
              "Acknowledged by ${user[userTableKeys[userDatabaseKeys.NAME]]} on \n${DateFormat("dd/MM/yyyy H:m:s").format(DateTime.now())}.\nFor Signer, scan QR code to verify signature.")
        ]));
  }

  createClaimReport(details, userData) {
    //data will be taken from retrieveexistingtimesheet method from dbp, passed into as this.details
    const List timesheetHeaders = [
      'Claim Date',
      'Claim Amount (\$)',
      'Remarks',
      'Proof(s)'
    ];
    print("que pasa $details");
    return pdfw.Table(
      
        border: pdfw.TableBorder.all(),
        tableWidth: pdfw.TableWidth.max,
        columnWidths: {
          0: pdfw.FlexColumnWidth(4),
          1: pdfw.FlexColumnWidth(4),
          2: pdfw.FlexColumnWidth(4),
          3: pdfw.FlexColumnWidth(8),
        },
        children: [
          pdfw.TableRow(
              children: timesheetHeaders.map((e) {
            print("ts $details");
            return pdfw.Center(child: pdfw.Text(e));
          }).toList()),
          ...details.map((Claim x) {
            print("${x.getRemarks} hola");
            return pdfw.TableRow(
                children: (x.convertToPdfReportList())
                    .map((e) => e is List
                        ? pdfw.Padding(
                            padding: pdfw.EdgeInsets.all(5),
                            child: pdfw.Column(children: [
                              ...e.map((n) => pdfw.Padding(
                                  padding: pdfw.EdgeInsets.all(2),
                                  child: pdfw.Image(pdfw.MemoryImage(n),
                                      height: PdfPageFormat.cm * 10,
                                      width: PdfPageFormat.cm * 5)))
                            ]))
                        : pdfw.Center(
                            child: pdfw.Text(e.length == 0 ? ' - ' : e)))
                    .toList());
          })
        ]);
  }

  createTimesheetsReport(details, userData) {
    //data will be taken from retrieveexistingtimesheet method from dbp, passed into as this.details
    const List timesheetHeaders = [
      'Start Time',
      'End Time',
      'Break (h)',
      'Final (h)',
      'Earnings (\$)',
      'Remarks',
    ];
    return pdfw.Table.fromTextArray(
        headers: timesheetHeaders,
        data: [
          ...details
              .map((e) => e.convertToPdfReportList(
                  userData[userTableKeys[userDatabaseKeys.PAY_RATE]]) as List)
              .toList()
        ],
        border: null,
        headerStyle: pdfw.TextStyle(
          fontWeight: pdfw.FontWeight.bold,
          fontSize: 12,
        ),
        cellHeight: 25,
        cellAlignment: pdfw.Alignment.center,
        headerDecoration: pdfw.BoxDecoration(color: PdfColors.blue50));
  }
}
