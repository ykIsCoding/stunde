import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';

class Photograph extends DatabaseProvider {
  late XFile photo;
  late String id;
  //late Uint8List photo_encoded;
  Photograph(XFile pic) {
    this.photo = pic;
    this.id = generateUniqueV1Id();
    // getImageAsUInt8List();
  }

  static Uint8List decodeBase64String(String strng) {
    return base64.decode(normalize(strng));
  }

  //Uint8List get getPhotoEncoded async {
  //  return this.getImageAsUInt8List();
  //}

  XFile get getPhoto {
    return this.photo;
  }

  static Photograph photographFromUint8List(Uint8List l) {
    return new Photograph(XFile.fromData(l));
  }

  Future<String> convertToStringFromXFile() async {
    var x = await this.photo.readAsBytes();
    return encodeBase64String(x);
  }

  

  Future<Uint8List> getImageAsUInt8List() async {
    var x = await this.photo.readAsBytes();
    // this.photo_encoded = x;
    return x;
  }

  static XFile convertToXFileFromString(String b) {
    return XFile.fromData(decodeBase64String(b));
  }

  static String encodeBase64String(Uint8List bytes) {
    return base64.encode(bytes);
  }

  //add a save method
}
