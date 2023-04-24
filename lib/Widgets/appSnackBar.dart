import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

SnackBar AppSnackBar(conditionIsNegative, positive, negative){
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        //  margin:EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: conditionIsNegative ? negative : positive);
}