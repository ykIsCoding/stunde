import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sql.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/photograph.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Mixins/pdfReport.dart';
import 'package:stunde/Pages/claimFormPage.dart';
import 'package:stunde/Pages/formPage.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Widgets/appSnackBar.dart';
import 'package:stunde/Widgets/dataCard.dart';
import 'package:stunde/Widgets/dateSelectionDialog.dart';

class AllClaimsPage extends StatefulWidget with DatabaseMixin {
  @override
  _AllClaimsPageState createState() => _AllClaimsPageState();
}

class _AllClaimsPageState extends State<AllClaimsPage> {
  String? currentExpanded = null;
  DateTime dateShowing = DateTime.now();
  List<Claim> ls = [];

  void setDateShowing(nd) {
    setState(() {
      dateShowing = nd;
    });
  }



    Future<List> getClaimsOnly(x) async {
    print('xxxx is $x');
    if (x is List<Claim>) {
      List<Claim> g = await x;
      return g
          .where((element) => element.getDatatype == datatype.CLAIM)
          .where(
              (element) => (element.getRecordDate).month == dateShowing.month)
          .toList();
    } else {
      print("elemet is $x");
      return x
          .where((element) => element['type'] == 'claim')
          .where((element) =>
              (DateTime.parse(element['end_time'])).month == dateShowing.month)
          .toList();
    }
  }

  void retrieveClaims() async {
    var dbp = Provider.of<DatabaseProvider>(context, listen: false);

    List<Claim> lc = await (dbp.getExistingClaims) as List<Claim>;
    print("yaa $lc");
    var list =await getClaimsOnly(lc) as List<Claim>;

    print("yaazzz");

    setState(() {
      ls = list;
    });
  }

  initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      retrieveClaims();
    });
  }

  didUpdateWidget(old) {
    super.didUpdateWidget(old);
  }

  Widget build(BuildContext context) {
    var dbp = Provider.of<DatabaseProvider>(context, listen: false);
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      onPressed: () async {
                        var claimReport = new PdfReport(
                            datatype.CLAIM,
                            await dbp.getFromTable(
                                'user_records', getClaimsOnly));
                        print("pdf");
                        await claimReport.createReport();
                        Navigator.of(context).pushNamed('/previewreport',
                            arguments: claimReport);
                      },
                    )
                )
              ],
              floating: true,
              forceElevated: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("My Claims"),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Showing ${DateFormat("MMMM").format(dateShowing)}"),
                  OutlinedButton(
                      onPressed: () async {
                        List allCs = await dbp.getExistingClaims;
                        showDialog(
                          context: context,
                          builder: (bctx) {
                            return DateSelectionDialog(
                                bctx, allCs, setDateShowing, dateShowing);
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
                      .map((Claim g) => ExpansionPanel(
                          isExpanded: g.getRecordId == currentExpanded,
                          headerBuilder: (BuildContext bctx, bool expd) {
                            return DataCard(g);
                          },
                          body: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (g.getReceiptImage.length > 0)
                                        Row(
                                            children:
                                                g.getReceiptImage.map((img) {
                                          final image = img;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              height: 200,
                                              width: 150,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: image.isNotEmpty
                                                    ? Image.memory(image)
                                                    : Text("no picture"),
                                              ),
                                            ),
                                          );
                                        }).toList()),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClaimFormPage({
                                                        'action': 'edit',
                                                        ...g.toMap()
                                                      })));
                                        },
                                        icon: Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () async {
                                          bool removeSuccess = await g.remove();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(AppSnackBar(removeSuccess, Text("Claim not removed"), Text("Claim deleted")));
                                        },
                                        icon: Icon(Icons.delete_forever))
                                  ],
                                )
                              ],
                            ),
                          )))
                      .toList()),
            ],
          ),
        ),
      ),
    ));
  }
}
