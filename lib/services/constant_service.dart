import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntDropDownValue {
  final int value;
  final String name;

  const IntDropDownValue({
   required this.name,
   required this.value
  });
}

class DoubleDropDownValue {
  final double value;
  final String name;

  const DoubleDropDownValue({
    required this.name,
    required this.value
  });
}

class StringDropDownValue {
  final String value;
  final String name;

  const StringDropDownValue({
    required this.name,
    required this.value
  });
}

class DropDownValueConstants {
  static final _factory = DropDownValueConstants();

  factory DropDownValueConstants() {
    return _factory;
  }

  static const ratingValues = [
    IntDropDownValue(value: 0, name: "--"),
    IntDropDownValue(value: 1, name: "*"),
    IntDropDownValue(value: 2, name: "**"),
    IntDropDownValue(value: 3, name: "***"),
    IntDropDownValue(value: 4, name: "****"),
    IntDropDownValue(value: 5, name: "*****"),
  ];

  static const isoValues = [
    IntDropDownValue(value: 0, name: "0"),
    IntDropDownValue(value: 50, name: "50"),
    IntDropDownValue(value: 64, name: "64"),
    IntDropDownValue(value: 100, name: "100"),
    IntDropDownValue(value: 200, name: "200"),
    IntDropDownValue(value: 400, name: "400"),
    IntDropDownValue(value: 800, name: "800"),
    IntDropDownValue(value: 1600, name: "1600"),
    IntDropDownValue(value: 3200, name: "3200"),
    IntDropDownValue(value: 6400, name: "6400"),
    IntDropDownValue(value: 12800, name: "12800"),
    IntDropDownValue(value: 25600, name: "25600"),
    IntDropDownValue(value: 1000000, name: "∞"),
  ];

  static const apertureValues = [
    DoubleDropDownValue(value: 0.0, name: "0"),
    DoubleDropDownValue(value: 1.0, name: "1"),
    DoubleDropDownValue(value: 1.4, name: "1.4"),
    DoubleDropDownValue(value: 1.7, name: "1.7"),
    DoubleDropDownValue(value: 2.0, name: "2"),
    DoubleDropDownValue(value: 2.8, name: "2.8"),
    DoubleDropDownValue(value: 4.0, name: "4"),
    DoubleDropDownValue(value: 5.6, name: "5.6"),
    DoubleDropDownValue(value: 8.0, name: "8"),
    DoubleDropDownValue(value: 11.0, name: "11"),
    DoubleDropDownValue(value: 16.0, name: "16"),
    DoubleDropDownValue(value: 22.0, name: "22"),
    DoubleDropDownValue(value: 32.0, name: "32"),
    DoubleDropDownValue(value: 45.0, name: "45"),
    DoubleDropDownValue(value: 1000000.0, name: "∞"),
  ];
  static const focalLengthValues = [
    IntDropDownValue(value: 0, name: "0"),
    IntDropDownValue(value: 10, name: "10"),
    IntDropDownValue(value: 15, name: "15"),
    IntDropDownValue(value: 20, name: "20"),
    IntDropDownValue(value: 25, name: "25"),
    IntDropDownValue(value: 30, name: "30"),
    IntDropDownValue(value: 35, name: "35"),
    IntDropDownValue(value: 50, name: "50"),
    IntDropDownValue(value: 60, name: "60"),
    IntDropDownValue(value: 70, name: "70"),
    IntDropDownValue(value: 80, name: "88"),
    IntDropDownValue(value: 90, name: "90"),
    IntDropDownValue(value: 100, name: "100"),
    IntDropDownValue(value: 150, name: "150"),
    IntDropDownValue(value: 200, name: "200"),
    IntDropDownValue(value: 300, name: "300"),
    IntDropDownValue(value: 400, name: "400"),
    IntDropDownValue(value: 500, name: "500"),
    IntDropDownValue(value: 700, name: "700"),
    IntDropDownValue(value: 1000, name: "1000"),
    IntDropDownValue(value: 1000000, name: "∞"),
  ];
  static const exposureValues = [
    DoubleDropDownValue(value: 0.0, name: "0"),
    DoubleDropDownValue(value: 8000.0, name: "1/8000"),
    DoubleDropDownValue(value: 4000.0, name: "1/4000"),
    DoubleDropDownValue(value: 2000.0, name: "1/2000"),
    DoubleDropDownValue(value: 1000.0, name: "1/1000"),
    DoubleDropDownValue(value: 500.0, name: "1/500"),
    DoubleDropDownValue(value: 250.0, name: "1/250"),
    DoubleDropDownValue(value: 125.0, name: "1/125"),
    DoubleDropDownValue(value: 60.0, name: "1/60"),
    DoubleDropDownValue(value: 30.0, name: "1/30"),
    DoubleDropDownValue(value: 15.0, name: "1/15"),
    DoubleDropDownValue(value: 8.0, name: "1/8"),
    DoubleDropDownValue(value: 4.0, name: "1/4"),
    DoubleDropDownValue(value: 2.0, name: "1/2"),
    DoubleDropDownValue(value: 1.0, name: "1"),
    DoubleDropDownValue(value: 0.5, name: "2"),
    DoubleDropDownValue(value: 0.25, name: "4"),
    DoubleDropDownValue(value: 0.125, name: "8"),
    DoubleDropDownValue(value: 0.0625, name: "16"),
    DoubleDropDownValue(value: 0.03125, name: "32"),
    DoubleDropDownValue(value: 0.00001, name: "∞"),
  ];

  static orientationValues(BuildContext context) {
   return [
     StringDropDownValue(value: "portrait", name: AppLocalizations.of(context)!.searchFormatPortrait),
     StringDropDownValue(value: "landscape", name: AppLocalizations.of(context)!.searchFormatLandscape),
   ];
  }
}