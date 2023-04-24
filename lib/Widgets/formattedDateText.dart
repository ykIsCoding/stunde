import 'package:flutter/cupertino.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:intl/intl.dart';

class FormattedDateText extends StatelessWidget {
  DateTime inputDate;
  FormattedDateText(this.inputDate);

  List<Text> processDate(DateTime x) {
    DateTime present = new DateTime.now();
    DateFormat standardDateFormat = DateFormat("EEEE MMMM dd yyyy");

    DateTime presentDate =
        new DateTime(present.year, present.month, present.day);
    DateTime inputDate = new DateTime(x.year, x.month, x.day);

    inputDate = new DateTime(x.year, x.month, x.day);
    // 1 is yesterday
    //-1 is tomorrow

    List<Text> displayDate = [Text(standardDateFormat.format(inputDate))];

    if (presentDate == inputDate) {
      displayDate = [Text("Today,"), Text("${standardDateFormat.format(inputDate)}")];
    } else if (presentDate.difference(inputDate).inDays == 1) {
      displayDate = [Text("Yesterday,"), Text("${standardDateFormat.format(inputDate)}")];
    } else {
      displayDate = [Text(standardDateFormat.format(inputDate))];
    }

    return displayDate;
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: processDate(inputDate));
  }
}
