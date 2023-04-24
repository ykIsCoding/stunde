import 'package:flutter/material.dart';
import 'package:stunde/Pages/allClaimsPage.dart';
import 'package:stunde/Pages/allTimesheetsPage.dart';
import 'package:stunde/Pages/claimFormPage.dart';
import 'package:stunde/Pages/formPage.dart';
import 'package:stunde/Pages/homePage.dart';
import 'package:provider/provider.dart';
import 'package:stunde/Pages/pdfPreviewPage.dart';
import 'package:stunde/Pages/profilePage.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Providers/deviceSettingsProvider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (ctx) => DatabaseProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return 
    MaterialApp(
      title: 'STUNDE',
      theme: ThemeData(
        fontFamily: 'Blinker',
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          headline1: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyText2: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          button: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
        ),
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      home: MultiProvider(providers: [
        ChangeNotifierProvider(create: (ctx) => DeviceSettingsProvider(ctx))
      ], child: HomePage(context)),
      routes: {
        '/previewreport':(ctx)=>PdfPreviewPage(),
        '/profile':(ctx)=>ProfilePage(),
        '/all-claims':(ctx)=>ChangeNotifierProvider(create: (ctx) => DeviceSettingsProvider(ctx),child: AllClaimsPage(),),
         '/all-timesheets':(ctx)=>ChangeNotifierProvider(create: (ctx) => DeviceSettingsProvider(ctx),child: AllTimesheetsPage())
        },
    );
  }
}
