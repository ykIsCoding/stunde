import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:stunde/Classes/user.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:stunde/Widgets/appSnackBar.dart';
import 'package:stunde/Widgets/userRegistrationDialog.dart';

class SignatureDialog extends StatefulWidget {
  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> with DatabaseMixin {
  List<Point> savedSignedPoints = [];

  Widget build(context) {
    final pen = SignatureController(
        points: savedSignedPoints,
        penColor: Colors.black,
        penStrokeWidth: 4,
        exportBackgroundColor: Colors.transparent);

    var signaturePad = Signature(
      controller: pen,
      width: 400,
      height: 500,
      backgroundColor: Colors.white12,
    );

    pen.onDrawEnd = () {
      setState(() {
        savedSignedPoints = pen.points;
      });
    };

    return SimpleDialog(
      title: Text('My Signature'),
      children: [
        signaturePad,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    savedSignedPoints = [];
                  });
                  pen.clear();
                },
                child: Text("Clear")),
            ElevatedButton(
                onPressed: savedSignedPoints.isEmpty
                    ? null
                    : () async {
                        print('points sind ${pen.points}');

                        Uint8List? signature = await pen.toPngBytes();
                        Navigator.of(context).pop(signature);
                      },
                child: Text("Save"))
          ],
        )
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with DatabaseMixin {
  //TEMPORARY
  var currentSignature;
  var registeredUserid = '';
  var _bank,
      _bank_num,
      _email,
      _name,
      _signature,
      _payrate,
      _company,
      _position,
      _status;

  Future<Uint8List?> displaySignatureDialog(ctx) {
    return showDialog(
        context: ctx,
        builder: (BuildContext bc) {
          return SignatureDialog();
        });
  }

  Widget dataRow(name, detail, editFn) {
    if (detail == null) {
      detail = 'no data';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 12),
            ),
            Text(detail, style: TextStyle(fontSize: 20))
          ],
        ),
        IconButton(onPressed: editFn, icon: Icon(Icons.edit))
      ],
    );
  }

  Future<void> checkIfUserExists() async {
    Map r = await getRegisteredUser();
    print("HERE ${r[userTableKeys[userDatabaseKeys.ID]]}");
    if (r.isEmpty) {
      //print("HERE");

      return;
    } else {
      setState(() {
        registeredUserid = r[userTableKeys[userDatabaseKeys.ID]];
        _bank = r[userTableKeys[userDatabaseKeys.BANK]];
        _bank_num = r[userTableKeys[userDatabaseKeys.BANK_NUMBER]];
        _email = r[userTableKeys[userDatabaseKeys.EMAIL]];
        _name = r[userTableKeys[userDatabaseKeys.NAME]];
        currentSignature = r[userTableKeys[userDatabaseKeys.SIGNATURE]];
        _payrate = r[userTableKeys[userDatabaseKeys.PAY_RATE]];
        _company = r[userTableKeys[userDatabaseKeys.COMPANY]];
        _position = r[userTableKeys[userDatabaseKeys.POSITION]];
        _status = r[userTableKeys[userDatabaseKeys.STATUS]];
      });
    }
  }

  initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await checkIfUserExists();
      if (registeredUserid == '') {
        var newRegisteredUserid = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return UserRegistrationDialog();
          },
        );
        getRegisteredUser();
      }
    });
  }

  Widget build(BuildContext context) {
    var databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "",
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text("My details"),
              Divider(
                color: Colors.blueGrey,
                height: 5,
                thickness: 2,
              ),
              dataRow('Company', _company, null),
              dataRow('Email', _email, null),
              dataRow('Pay Rate', _payrate.toString(), null),
              dataRow('Bank Acc', _bank_num, null),
              dataRow('Bank', _bank, null),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Signature"),
                  (currentSignature != null)
                      ? Image.memory(currentSignature)
                      : TextButton(
                          onPressed: () async {
                            var returnedSignature =
                                await displaySignatureDialog(context);
                            setState(() {
                              currentSignature = returnedSignature;
                            });
                            User? cu = await databaseProvider.loadCurrentUser();
                            if (cu is User && returnedSignature is Uint8List) {
                              cu.setSignature(returnedSignature);
                              String res = await cu.update();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  AppSnackBar(
                                      res.isEmpty,
                                      Text("Signature Updated!"),
                                      Text("Error!")));
                              print("update $res");
                            }
                          },
                          child: Text("Add Signature")),
                  if (currentSignature != null)
                    TextButton(
                        onPressed: () {
                          setState(() {
                            currentSignature = null;
                          });
                        },
                        child: Text("Remove Signature"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
