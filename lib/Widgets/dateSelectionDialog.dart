import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stunde/Implements/datatypeImplements.dart';
import 'package:stunde/Mixins/databaseMixin.dart';
import 'package:stunde/Mixins/pdfReport.dart';
import 'package:stunde/Providers/Database/databaseProvider.dart';
import 'package:stunde/Shared/dataTypeEnum.dart';
import 'package:stunde/Widgets/dataCard.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

class DateSelectionDialog extends StatefulWidget {
  Function dateShowingSetter;
  BuildContext bctx;
  List details;
  DateTime dateShowing;
  DateSelectionDialog(
      this.bctx, this.details, this.dateShowingSetter, this.dateShowing);

  @override
  _DateSelectionDialogState createState() => _DateSelectionDialogState();
}

class _DateSelectionDialogState extends State<DateSelectionDialog> {
  int temp_year = DateTime.now().year;
  String temp_month = DateFormat("MMMM").format(DateTime.now());

  initState() {
    super.initState();
    setState(() {
      temp_year = widget.dateShowing.year;
      temp_month = DateFormat("MMMM").format(widget.dateShowing);
    });
  }

  Widget build(BuildContext bctx) {
    List years =
        widget.details.map((e) => e.getRecordDate.year).toSet().toList();
    List months = widget.details
        .where(
            (element) => element.getRecordDate.year == widget.dateShowing.year)
        .map((e) => DateFormat("MMMM").format(e.getRecordDate))
        .toSet()
        .toList();

    return SimpleDialog(
      title: Text("Choose Month"),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Year"),
            DropdownButton(
              disabledHint: years.length < 2
                  ? Text(widget.dateShowing.year.toString())
                  : null,
              value: temp_year,
              onChanged: (v) {
                var newDate = DateTime(temp_year);

                months = widget.details
                    .where((element) =>
                        element.getRecordDate.year == widget.dateShowing.year)
                    .toList();
                months
                    .sort((a, b) => a.getRecordDate.compareTo(b.getRecordDate));
                months
                    .map((e) => DateFormat("MMMM").format(e.getRecordDate))
                    .toSet()
                    .toList();
              },
              items: years.length < 2
                  ? null
                  : years
                      .map((e) => DropdownMenuItem(
                            onTap: () {
                              setState(() {
                                temp_year = e;
                              });
                            },
                            child: Text(e.toString()),
                            value: e,
                            key: Key(years.indexOf(e).toString()),
                          ))
                      .toList(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Month"),
            DropdownButton(
              disabledHint: months.length < 2?Text(months.first.toString()):null,
              value: temp_month,
              onChanged: (v) {
                setState(() {
                  temp_month = v.toString();
                });
                print("DATEH wa $v");
              },
              items: months.length < 2
                  ? null
                  : months
                      .map((e) => DropdownMenuItem(
                            onTap: () {},
                            value: e,
                            child: Text(e),
                            key: Key(months.indexOf(e).toString()),
                          ))
                      .toList(),
            ),
          ],
        ),
        Row(
          children: [
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(widget.bctx).pop();
              },
            ),
            SimpleDialogOption(
              child: Text("Filter"),
              onPressed: () {
                var monthNames = [
                  'january',
                  'february',
                  'march',
                  'april',
                  'may',
                  'june',
                  'july',
                  'august',
                  'september',
                  'october',
                  'november',
                  'december'
                ];
                DateTime newDate = DateTime(temp_year,
                    monthNames.indexOf(temp_month.toLowerCase()) + 1);
                widget.dateShowingSetter(newDate);
                Navigator.of(widget.bctx).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}
