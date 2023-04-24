
import 'package:flutter/material.dart';

class DeviceSettingsProvider extends ChangeNotifier {
  BuildContext currentContext;
  DeviceSettingsProvider(this.currentContext);

  Size get deviceSize {
    return MediaQuery.of(currentContext).size;
  }
}
