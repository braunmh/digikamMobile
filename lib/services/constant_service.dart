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

const ratingValues = [
  IntDropDownValue(value: 0, name: "--"),
  IntDropDownValue(value: 1, name: "*"),
  IntDropDownValue(value: 2, name: "**"),
  IntDropDownValue(value: 3, name: "***"),
  IntDropDownValue(value: 4, name: "****"),
  IntDropDownValue(value: 5, name: "*****"),
];
