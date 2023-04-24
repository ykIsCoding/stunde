import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Mixins/pdfReport.dart';
import 'package:stunde/Pages/formPage.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Widgets/appSnackBar.dart';
import 'package:stunde/Widgets/dataCard.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:stunde/Widgets/dateSelectionDialog.dart';

class AllTimesheetsPage extends StatefulWidget with DatabaseMixin {
  @override
  _AllTimesheetsPageState createState() => _AllTimesheetsPageState();
}

class _AllTimesheetsPageState extends State<AllTimesheetsPage> {
  String? currentExpanded = null;
  DateTime dateShowing = DateTime.now();

  void setDateShowing(nd) {
    setState(() {
      dateShowing = nd;
    });
  }

//getfrm table doesnt give a list of timehseets
  Future<List> getTimesheetsOnly(x) async {
    print('xxxx is $x');
    if (x is Future<List<Timesheet>>) {
      List<Timesheet> g = await x;
      return g
          .where((element) => element.getDatatype == datatype.TIMESHEET)
          .where(
              (element) => (element.getEndDateTime).month == dateShowing.month)
          .toList();
    } else {
      print("elemet is $x");
      return x
          .where((element) => element['type'] == 'timesheet')
          .where((element) =>
              (DateTime.parse(element['end_time'])).month == dateShowing.month)
          .toList();
    }
  }

  Widget build(BuildContext context) {
    var dbp = Provider.of<DatabaseProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (ctx, topBoxscrolled) {
              return [
                SliverAppBar(
                  brightness: Brightness.light,
                  pinned: true,
                  title: Text(""),
                  expandedHeight: 150,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      onPressed: () async {
                        var timesheetReport = new PdfReport(
                            datatype.TIMESHEET,
                            await dbp.getFromTable(
                                'user_records', getTimesheetsOnly));
                        print("pdf");
                        await timesheetReport.createReport();
                        Navigator.of(context).pushNamed('/previewreport',
                            arguments: timesheetReport);
                      },
                    )
                  ],
                  floating: true,
                  forceElevated: false,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("My Timesheets"),
                  ),
                ),
              ];
            },
            body: FutureBuilder(
                future: getTimesheetsOnly(dbp.getExistingTimesheets),
                builder: (context, snapshot) {
                  print("qtal ${snapshot.data}");
                  if (snapshot.hasData) {
                    print('snapshot is $snapshot');
                    List<Timesheet> ls = snapshot.data as List<Timesheet>;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                "Showing for ${DateFormat("MMMM yyyy").format(dateShowing)}"),
                            OutlinedButton(
                                onPressed: () async {
                                  List allTs = await dbp.getExistingTimesheets;
                                  showDialog(
                                    context: context,
                                    builder: (bctx) {
                                      return DateSelectionDialog(bctx, allTs,
                                          setDateShowing, dateShowing);
                                    },
                                    barrierDismissible: true,
                                  );
                                },
                                child: Text("Change"))
                          ],
                        ),
                        ExpansionPanelList(
                            expansionCallback: (int idx, bool expded) {
                              if (expded) {
                                setState(() {
                                  currentExpanded = null;
                                });
                              } else {
                                setState(() {
                                  currentExpanded = ls
                                      .firstWhere((element) =>
                                          element.getRecordId ==
                                          ls.elementAt(idx).getRecordId)
                                      .getRecordId;
                                });
                              }
                            },
                            children: ls
                                .map((g) => ExpansionPanel(
                                    isExpanded:
                                        g.getRecordId == currentExpanded,
                                    headerBuilder:
                                        (BuildContext bctx, bool expd) {
                                      return DataCard(g);
                                    },
                                    body: ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FormPage({
                                                              'action': 'edit',
                                                              ...g.toMap()
                                                            })));
                                              },
                                              icon: Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: () async {
                                                bool removeSuccess =
                                                    await g.remove();
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(AppSnackBar(
                                                        removeSuccess,
                                                        Text(
                                                            "Timesheet not removed"),
                                                        Text(
                                                            "Timesheet deleted")));
                                              },
                                              icon: Icon(Icons.delete_forever))
                                        ],
                                      ),
                                    )))
                                .toList()),
                      ],
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Text('loading');
                  } else {
                    return Text("error");
                  }
                })),
      ),
    );
  }
}
