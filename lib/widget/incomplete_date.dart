import 'package:flutter/material.dart';

class IncompleteDateWidget extends StatefulWidget {

  @override
  IncompleteDateWidgetState createState() {
    return IncompleteDateWidgetState();
  }

  final ValueChanged<IncompleteDate> onChanged;

  final String labelText;
  final IncompleteDate defaultValue;

  const IncompleteDateWidget({
    super.key,
    required this.labelText,
    required this.defaultValue,
    required this.onChanged,
});
}

class IncompleteDateWidgetState extends State<IncompleteDateWidget> {

  final dateKey = GlobalKey<FormFieldState>();
  late FocusNode dateFocus;
  late TextEditingController dateController;
  IncompleteDate _value = IncompleteDate(onlyDate: true);

  @override
  void initState() {
     super.initState();
     dateController = TextEditingController();
     dateFocus = FocusNode();
     dateFocus.addListener(() {
       if (!dateFocus.hasFocus) {
         dateKey.currentState?.validate();
       }
     });
  }
  
  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    dateFocus.dispose();
  }

  @override
   Widget build(BuildContext context) {
    return TextFormField(
      key: dateKey,
      controller: dateController,
      validator: (String? value) {
        if (value != null) {
          try {
            _value = IncompleteDate.parse(widget.defaultValue.onlyDate, value);
            widget.onChanged(_value);
            dateController.text = _value.format();
          } on FormatException catch (e) {
            return e.message;
          }
        }
        return null;
      },
      focusNode: dateFocus,
      decoration: InputDecoration(labelText: widget.labelText),
    );
  }

}

final List<int> _datesOfMonth = [31,28,31,30,31,30,31,31,30,31,30,31];
class IncompleteDate implements Comparable<IncompleteDate> {

  final String _defaultYear = '----';
  final String _default = '--';

  bool onlyDate;
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minute;
  IncompleteDate({
    required this.onlyDate,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
  });

  factory IncompleteDate.parse(bool onlyDate, String input) {
    if (input.isEmpty) {
      return IncompleteDate(onlyDate: onlyDate);
    }
    List<String> fullParts = input.split(' ');
    int year;
    int? month;
    int? day;
    int? hour;
    int? minute;
    List<String> dateParts = input.split('.');
    switch(dateParts.length) {
      case 1:
        year = IncompleteDateUtil.parseYear(dateParts[0]);
        break;
      case 2:
        year = IncompleteDateUtil.parseYear(dateParts[1]);
        month = IncompleteDateUtil.parsePartOfDate(dateParts[0], 1, 12);
        break;
      default:
        year = IncompleteDateUtil.parseYear(dateParts[2]);
        month = IncompleteDateUtil.parsePartOfDate(dateParts[1], 1, 12);
        day = IncompleteDateUtil.parsePartOfDate(dateParts[0], 1, IncompleteDateUtil.dateOfMonth(month ?? 0, year));
        break;
    }
    if (month == null && day != null) {
      throw const FormatException('Tagesangabe ohne Monatsangabe nicht möglich');
    }
    if (onlyDate) {
      return IncompleteDate(onlyDate: true, year: year, month: month, day: day);
    } else {
      if (fullParts.length > 1) {
        List<String> timeParts = fullParts[1].split(":");
        switch(timeParts.length) {
          case 1:
            hour = IncompleteDateUtil.parsePartOfDate(timeParts[0], 0, 23);
            break;
          default:
            hour = IncompleteDateUtil.parsePartOfDate(timeParts[0], 0, 23);
            minute = IncompleteDateUtil.parsePartOfDate(timeParts[1], 0, 59);
        }
      }
      if (day == null && hour != null) {
        throw const FormatException('Stundenangabe ohne Tagesangabe nicht möglich');
      }
      if (hour == null && minute != null) {
        throw const FormatException('Minutenangabe ohne Stundenangabe nicht möglich');
      }
      return IncompleteDate(onlyDate: false, year: year, month: month, day: day
        ,hour: hour, minute: minute
      );
    }
  }

  String toParameter() {
    return '${_formatInt(year, 4, _defaultYear)}${_formatInt(month, 2, _default)}'
        '${_formatInt(day, 2, _default)}${_formatInt(hour, 2, _default)}'
        '${_formatInt(minute, 2, _default)}';
  }

  String format() {
    if (year == null) {
      return '';
    }
    if (onlyDate) {
      return'${_formatInt(day, 2, _default)}.${_formatInt(month, 2, _default)}'
          '.${_formatInt(year, 4, _defaultYear)}';
    } else {
      return'${_formatInt(day, 2, _default)}.${_formatInt(month, 2, _default)}'
          '.${_formatInt(year, 4, _defaultYear)}'
          ' ${_formatInt(hour, 2, _default)}:${_formatInt(minute, 2, _default)}';
    }
  }
  
  @override
  int compareTo(IncompleteDate other) {
    return toParameter().compareTo(other.toParameter());
  }

  String _formatInt(int? value, int length, String defaultValue) {
    if (value == null || value == 0) {
      return defaultValue;
    }
    return value.toString().padLeft(length, '0');
  }

  bool isEmpty() {
    return year == null;
  }

  bool isNotEmpty() {
    return !isEmpty();
  }
}

class IncompleteDateUtil {
  static int parseYear(String value) {
    if (value.isEmpty) {
      throw const FormatException("Jahresangabe ist erforderlich.");
    }
    int year = parseInt(value);
    int currentYear = DateTime.now().year;
    if (value.length < 3) {
      int xx = currentYear - 2000;
      year = (year > xx) ? 1900 + year : 2000 + year;
    } else if (value.length == 4) {
      if (year - 1 > currentYear) {
        throw const FormatException("Jahresangabe liegt in der Zukunft");
      }
    }
    return year;
  }

  static int parseInt(String value) {
    return num.parse(value).toInt();
  }

  static int dateOfMonth(int month, int year) {
    if (month == 0) {
      return 31;
    }
    if (month == 2) {
      return (year % 4 == 0) ? 29 : 28;
    } else {
      return _datesOfMonth[month - 1];
    }
  }

  static int? parsePartOfDate(String value, int from, int to) {
    if (value.isEmpty || value == '-' || value == '--') {
      return null;
    }
    int x = parseInt(value);
    if (x < from || x > to) {
      throw FormatException('Angabe muss zwischen $from und $to liegen');
    }
    return x;
  }


}