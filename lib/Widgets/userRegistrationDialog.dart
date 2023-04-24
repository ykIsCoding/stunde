import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:stunde/Classes/user.dart';
import 'package:stunde/Pages/homePage.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/userStatusEnum.dart';

class UserRegistrationDialog extends StatefulWidget {
  @override
  _UserRegistrationDialogState createState() => _UserRegistrationDialogState();
}

final signatureKey = GlobalKey();

//add variables to assign values in onSaved
//combine values of signaturekey n formstatekey to become an object
//send to db

List<Widget> pageTwoFields(pen) {
  var signaturePad = Signature(
    controller: pen,
    width: 400,
    height: 500,
    backgroundColor: Colors.white12,
  );

  return [Text("Add Your Signature"), signaturePad];
}

class _UserRegistrationDialogState extends State<UserRegistrationDialog> {
  final _registrationFormState = GlobalKey<FormState>();
  var pageNumber = 1;
  String _name = '';
  String _email = '';
  String _company = '';
  String _bank = '';
  double _payrate = 0.0;
  String _bank_num = '';
  String _position = '';

  List<Widget> pageOneFields() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: "Name"),
        initialValue: _name,
        onSaved: (newValue) {
          setState(() {
            _name = newValue.toString();
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Email"),
        initialValue: _email,
        onSaved: (newValue) {
          setState(() {
            _email = newValue.toString();
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Company"),
        onSaved: (newValue) {
          setState(() {
            _company = newValue.toString();
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Position"),
        onSaved: (newValue) {
          setState(() {
            _position = newValue.toString();
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Pay Rate"),
        onSaved: (newValue) {
          setState(() {
            _payrate = double.parse(newValue.toString());
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Bank"),
        onSaved: (newValue) {
          setState(() {
            _bank = newValue.toString();
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(labelText: "Bank Account Number"),
        onSaved: (newValue) {
          setState(() {
            _bank_num = newValue.toString();
          });
        },
      ),
    ];
  }

  final pen = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 4,
      exportBackgroundColor: Colors.transparent);
  var signature;

  Widget build(BuildContext context) {
    void dispose() {
      pen.dispose();
      super.dispose();
    }

    return SimpleDialog(
      insetPadding: const EdgeInsets.all(10.0),
      title: Text("Registration"),
      children: [
        Container(
          width: 400,
          height: 500,
          child: Form(
            key: _registrationFormState,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: ListBody(
                  children:
                      pageNumber == 1 ? pageOneFields() : pageTwoFields(pen),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
                onPressed: () {
                  if (pageNumber == 1) {
                    Navigator.of(context).popAndPushNamed('/');
                  } else {
                    setState(() {
                      pageNumber = 1;
                    });
                  }
                },
                child: Text("Back")),
            ElevatedButton(
                onPressed: () async {
                  if (_registrationFormState.currentState!.validate() &&
                      pageNumber == 1) {
                    _registrationFormState.currentState!.save();
                    setState(() {
                      pageNumber = 2;
                    });
                  } else if (pageNumber == 2) {
                    if (pen.isNotEmpty) {
                      Uint8List? sign = await pen.toPngBytes();
                      _registrationFormState.currentState?.setState(() {
                        signature = sign;
                      });
                      String newUserId = await new User(
                              name: _name,
                              company: _company,
                              position: _position,
                              email: _email,
                              payrate: _payrate,
                              bank: _bank,
                              bank_num: _bank_num,
                              userSignature: signature)
                          .save();
                      print("userid is $newUserId");
                      if (newUserId.isNotEmpty) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            HomePage.routeName, (route) => false, arguments: newUserId);
                       // Navigator.of(context).pop(newUserId);
                      }
                    }
                  }
                },
                child: Text("Let's go!"))
          ],
        )
      ],
    );
  }
}
