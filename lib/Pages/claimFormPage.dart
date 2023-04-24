import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stunde/Classes/claim.dart';
import 'package:stunde/Classes/photograph.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Pages/homePage.dart';
import 'package:stunde/Providers/deviceSettingsProvider.dart';
import 'package:stunde/Shared/databaseKeys.dart';
import 'package:stunde/Widgets/imageStack.dart';

class ClaimFormPage extends StatefulWidget {
  Map previousData = {};
  ClaimFormPage([previousData]) {
    print("pddd is $previousData");
    if (previousData != null) {
      this.previousData = previousData;
    }
  }
  @override
  _ClaimFormPageState createState() => _ClaimFormPageState();
}

class _ClaimFormPageState extends State<ClaimFormPage> with DatabaseMixin {
  final _claimFormKey = GlobalKey<FormState>();
  var _dateController = TextEditingController();
  String remarks = "";
  String receipt_number = '';
  double claim_amount = 0;
  bool editingMode = false;
  late DateTime claim_date;
  ImagePicker picker = ImagePicker();
  List<Photograph> receipt_photo = [];
  List<Map> photoList = [];
//  StreamController _photoListController = new StreamController();

  //List<Photograph> receipt_photo_photographs = [];

  Future<void> _uploadReceiptPhoto() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Pick an Option"),
            content: Text("You may add up to 2 images"),
            actions: [
              ElevatedButton.icon(
                  onPressed: () async {
                    var tempImg = await picker.pickImage(
                        source: ImageSource.camera) as XFile;
                    var tempArr = receipt_photo;
                    var photographClass = new Photograph(tempImg);
                    //var pf = await photographClass.getImageAsUInt8List();
                    tempArr.add(photographClass);
                    convertFromPhotographListToUint8ListList(tempArr);
                    Navigator.of(ctx).pop();
                  },
                  icon: Icon(Icons.camera),
                  label: Text("Camera")),
              ElevatedButton.icon(
                  onPressed: () async {
                    var tempImg = await picker.pickImage(
                        source: ImageSource.gallery) as XFile;
                    var tempArr = receipt_photo;
                    var photographClass = new Photograph(tempImg);
                    await photographClass.getImageAsUInt8List();
                    tempArr.add(photographClass);

                    setState(() {
                      receipt_photo = tempArr;
                    });
                    Navigator.of(ctx).pop();
                  },
                  icon: Icon(Icons.storage),
                  label: Text("Gallery")),
            ],
          );
        });
  }

  Future<List> convertFromPhotographListToUint8ListList(g) async {
    List<Map> t = [];
    // g ??= receipt_photo;
    if (g.length == 0) {
      t = [];
    } else {
      t = await Future.wait([
        ...g.map((Photograph element) async {
          var xd = await element.getImageAsUInt8List();
          return {'img': xd, 'imgId': element.id};
          // t.add({'img': xd, 'imgId': element.id});
          // photoList.add(xd);
        })
      ]);
      print('temp is $t');
    }
    // _photoListController.sink.add(t);
    setState(() {
      photoList = t;
      receipt_photo = g;
    });

    //return await temp.toList();
    return photoList;
  }

  Future<void> deleteImage(id) async {
    var t = receipt_photo;
    t.removeWhere((e) => e.id == id);
    print("deleting $receipt_photo");
    await convertFromPhotographListToUint8ListList(t);
  }

  void dispose() {
    _dateController.dispose();
    // _photoListController.close();
    super.dispose();
  }

  initState() {
    super.initState();
    Map? previousData = widget.previousData;

    if (previousData.isNotEmpty && previousData['action'] == 'edit') {
      print("pd is ${previousData['receipt_photo']}");
      setState(() {
        editingMode = true;
        remarks = previousData['remarks'].toString();
        claim_date = DateTime.parse(previousData['start_time']);
        receipt_number = previousData['remarks'].toString();
        claim_amount = previousData['claim_amount'] as double;
        receipt_photo = convertMapToPhotographList(previousData[
            userRecordsTableKeys[userRecordsDatabaseKeys.RECEIPT_IMAGE]]);
      });
      _dateController.value = TextEditingValue(text: claim_date.toString());
      convertFromPhotographListToUint8ListList(receipt_photo);
    }
  }

  Widget build(BuildContext context) {
    //final deviceSettingsProvider = Provider.of<DeviceSettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
              key: _claimFormKey,
              child: Column(
                children: [
                  editingMode ? Text("Edit a Claim") : Text("Add a Claim"),
                  Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: DateTimePicker(
                          type: DateTimePickerType.date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2023),
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: "Select Start Date and Time",
                            prefixIcon: IconButton(
                                onPressed: () => null,
                                icon: Icon(Icons.calendar_today_outlined)),
                          ),
                          dateLabelText: "Date",
                          initialDate: editingMode ? claim_date : null,
                          dateHintText: "Enter date",
                          onChanged: (val) => print(val),
                          validator: (val) {
                            print(val);
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              claim_date = DateTime.parse(val.toString());
                            });
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {
                              _dateController.clear();
                            },
                            icon: Icon(Icons.clear_all_sharp)),
                      )
                    ],
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    onEditingComplete: () => _claimFormKey.currentState?.save(),
                    onSaved: (value) {
                      setState(() {
                        receipt_number = value.toString();
                      });
                    },
                    initialValue: receipt_number,
                    decoration: InputDecoration(hintText: "Receipt Number"),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onEditingComplete: () => _claimFormKey.currentState?.save(),
                    onSaved: (value) {
                      setState(() {
                        claim_amount = double.parse(value.toString());
                      });
                    },
                    initialValue: claim_amount.toString(),
                    decoration: InputDecoration(hintText: "Claim Amount"),
                  ),
                  TextFormField(
                    initialValue: remarks,
                    onChanged: (value) {
                      print("vale is $value");
                      setState(() {
                        remarks = value.toString();
                      });
                    },
                    decoration: InputDecoration(
                        hintText: "Remarks",
                        counter: Text("${remarks.length}/200")),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                          onPressed: receipt_photo.length < 2
                              ? _uploadReceiptPhoto
                              : null,
                          child: Text("Upload Image")),
                      Text('Images: ${receipt_photo.length}/2')
                    ],
                  ),
                  if (photoList.length > 0)
                    Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ImageStack(photoList[0]['img'],
                            () => deleteImage(photoList[0]['imgId'])),
                        SizedBox(
                          height: 5,
                        ),
                        if (photoList.length > 1)
                          ImageStack(photoList[1]['img'],
                              () => deleteImage(photoList[1]['imgId']))
                      ],
                    )),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          _claimFormKey.currentState?.save();
                          print("het");

                          //TO FIX
                          Future<List> processReceiptPhoto() async {
                            //List<String> processedReceiptPhoto = [];
                            return Future.wait([
                              ...receipt_photo.map((element) async {
                                Uint8List tpm =
                                    await element.getImageAsUInt8List();
                                //processedReceiptPhoto.add(
                                return base64.normalize(
                                    Photograph.encodeBase64String(tpm));
                                //);
                                //  print("este ${await processedReceiptPhoto}");
                              }).toList()
                            ]);
                            //  return processedReceiptPhoto;
                          }

                          print("heyaaa ${await processReceiptPhoto()}");
                          Map<String, dynamic> receiptPhotoMapString = {
                            'lasted_updated': DateTime.now().toIso8601String(),
                            'photos': await processReceiptPhoto()
                          };
                          String uid = await getRegisteredUserId;
                          print(
                              "uid is $uid and ${await receiptPhotoMapString}");

                          Claim c = new Claim(
                              userid: uid == null ? '0' : uid,
                              claimAmount: claim_amount.toString(),
                              claimDate: claim_date.toIso8601String(),
                              receiptNumber: receipt_number,
                              receiptPhoto: receiptPhotoMapString);
                          var test = await c.add();
                          print("test is $test");

                          Navigator.popAndPushNamed(
                              context, HomePage.routeName);
                          final snackbar = SnackBar(
                              content:
                                  test ? Text("Success!") : Text("Error!"));
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        child: Text("Submit")),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
