import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stunde/Mixins/databaseMixin.dart';

class ImageStack extends StatelessWidget{
  Uint8List image;
  Function fn;
  ImageStack(this.image, this.fn);

  Widget build(BuildContext context) {

    
   // id = generateUniqueV1Id();
    return ClipRRect(borderRadius: BorderRadius.circular(15),
    child: Stack(children: [
      Image.memory(image),
      IconButton(onPressed: () => this.fn(), icon: Icon(Icons.delete))
    ]));
  }
}
