import 'dart:ffi';

import 'package:flutter/scheduler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/timesheet.dart';
import 'package:stunde/Classes/user.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Pages/claimFormPage.dart';
import 'package:stunde/Pages/formPage.dart';
import 'package:stunde/Pages/profilePage.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:stunde/Widgets/pageLoadingWidget.dart';
import 'package:stunde/Widgets/userRegistrationDialog.dart';
import '../Shared/dataTypeEnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stunde/Widgets/dataCard.dart';
import 'package:stunde/Widgets/formattedDateText.dart';
import 'package:stunde/Widgets/navBar.dart';
import 'package:stunde/Providers/deviceSettingsProvider.dart';

class HomePage extends StatefulWidget with DatabaseMixin {
  static String routeName = '/';
  BuildContext ctx;
  HomePage(this.ctx);
  @override
  _HomePageState createState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await getDatabase();
    });
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  var databaseProvider;
  var latestTimesheet = null;
  var latestClaim = null;
  var currentUser = null;

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void initState() {
    super.initState();
  }

  Future<dynamic> loadDatabaseContent(DatabaseProvider dbp) async {
    var outcome = true;
    var u = await dbp.loadCurrentUser();
    await dbp.retrieveExistingClaimsAndTimesheets().catchError((e, st) {
      print("e is $e and $st");
      outcome = false;
    });
    setState(() {
      currentUser = u;
      latestClaim =
          dbp.existingClaims.isNotEmpty ? dbp.existingClaims.first : null;
      latestTimesheet = dbp.existingTimesheets.isNotEmpty
          ? dbp.existingTimesheets.first
          : null;
    });

    return outcome ? true : null;
  }

  Widget build(BuildContext context) {
    widget.ctx = context;
    final deviceSettingsProvider = Provider.of<DeviceSettingsProvider>(context);
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    Size mq = MediaQuery.of(context).size;
    
    return FutureBuilder(
        future: loadDatabaseContent(databaseProvider),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text("S T U N D E"),
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: mq.height * 0.3,
                      child: Card(
                        margin: EdgeInsets.all(mq.width * 0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormattedDateText(DateTime.now()),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton.icon(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              minimumSize:
                                  MaterialStateProperty.all(Size(160, 60)),
                              fixedSize:
                                  MaterialStateProperty.all(Size(160, 70)),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(mq.width * 0.05)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.orangeAccent)),
                          icon: Icon(Icons.money),
                          label: Text(
                            "Add Claim",
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClaimFormPage()));
                          },
                        ),
                        OutlinedButton.icon(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                                minimumSize:
                                    MaterialStateProperty.all(Size(160, 60)),
                                fixedSize:
                                    MaterialStateProperty.all(Size(160, 70)),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(mq.width * 0.05)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.orangeAccent)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FormPage()));
                            },
                            icon: Icon(Icons.timer_sharp),
                            label: Text("Add Timesheet",
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    SizedBox(height: mq.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Recent Time Log"),
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/all-timesheets');
                                  },
                                  child: Text("View All"),
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))))
                            ],
                          ),
                          DataCard(latestTimesheet),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Recent Claim"),
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/all-claims');
                                  },
                                  child: Text("View All"),
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))))
                            ],
                          ),
                          DataCard(latestClaim),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                height: deviceSettingsProvider.deviceSize.height * 0.08,
                child: BottomAppBar(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(currentUser.getUserName.length > 0
                                ? currentUser.getUserName
                                : 'You are not logged in')
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: !(currentUser is User &&
                                  currentUser.getUserName.length > 0)
                              ? [
                                  ElevatedButton(
                                      onPressed: () async {
                                        // var newRegisteredUserid =
                                        await showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) {
                                            return UserRegistrationDialog();
                                          },
                                        );
                                        var newRegisteredUserid =
                                            ModalRoute.of(context)
                                                !.settings
                                                .arguments;
                                        if (newRegisteredUserid != nullptr) {
                                          var user = await databaseProvider
                                              .loadCurrentUser();
                                          setState(() {
                                            currentUser = user;
                                          });
                                        }
                                      },
                                      child: Text("Log In"))
                                ]
                              : [
                                  IconButton(
                                      onPressed: null, icon: Icon(Icons.pages)),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(ProfilePage.routeName);
                                      },
                                      icon: Icon(Icons.person)),
                                ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return PageLoadingWidget();
          } else {
            return Text("error");
          }
        });
  }
}
