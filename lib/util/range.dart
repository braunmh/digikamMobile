import '../widget/incomplete_date.dart';

class RowRangeInt extends RowRange<int> {
  RowRangeInt();

  @override
  int parse(String value) {
    try {
      return num.parse(value).toInt();
    } catch (e) {
      return 0;
    }
  }

  @override
  String validator() {
    if (from == 0 && to == 0) {
      return '';
    }
    if (to == 0) {
      return '';
    }
    if (from == 0) {
      return '';
    }
    if (from > to) {
      return 'Von muss kleiner als Bis sein.';
    }
    return '';
  }

  @override
  int get from => _from ?? 0;

  @override
  int get to => _to ?? 0;

  @override
  String toString() {
    return 'from: $from  to: $to';
  }

  @override
  bool isEmpty() {
    return to == 0 && from == 0;
  }

  @override
  int? get fromNullable => (from == 0) ? null : from;

  @override
  int? get toNullable => (to == 0) ? null : to;
}

class RowRangeDouble extends RowRange<double> {
  final bool inverse;

  RowRangeDouble({this.inverse = false});

  @override
  double parse(String value) {
    try {
      double temp = num.parse(value).toDouble();
      if (!inverse || temp == 0.0) {
        return temp;
      }
      return 1 / temp;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  String validator() {
    if (from == 0.0 && to == 0.0) {
      return '';
    }
    if (to == 0.0) {
      return '';
    }
    if (from == 0.0) {
      return '';
    }
    if (from > to) {
      return 'Von muss kleiner als Bis sein.';
    }
    return '';
  }

  @override
  double get from => _from ?? 0.0;

  @override
  double get to => _to ?? 0.0;

  @override
  String toString() {
    return 'from: $from  to: $to';
  }

  @override
  bool isEmpty() {
    return to == 0.0 && from == 0.0;
  }

  @override
  double? get fromNullable => (from == 0.0) ? null : from;

  @override
  double? get toNullable => (to == 0.0) ? null : to;
}

class RowRangeIncompleteDate extends RowRange<IncompleteDate> {
  final bool onlyDate;

  RowRangeIncompleteDate({
    required this.onlyDate,
  });

  @override
  IncompleteDate get from => _from ?? IncompleteDate(onlyDate: onlyDate);

  @override
  IncompleteDate parse(String value) {
    return IncompleteDate.parse(onlyDate, value);
  }

  @override
  IncompleteDate get to => _to ?? IncompleteDate(onlyDate: onlyDate);

  @override
  String validator() {
    if (_from == null && _to == null) {
      return '';
    }
    if (_from == null || _to == null) {
      return '';
    }
    if (from.toParameter().compareTo(to.toParameter()) > 0) {
      return 'Von muss kleiner als Bis sein.';
    }
    return '';
  }

  @override
  String toString() {
    return 'from: ${from.format()}  to: ${to.format()}';
  }

  @override
  bool isEmpty() {
    return (_from == null || _from!.isEmpty()) &&
        (_to == null || _to!.isEmpty());
  }

  @override
  IncompleteDate? get fromNullable => _from;

  @override
  // TODO: implement toNullable
  IncompleteDate? get toNullable => _to;
}

abstract class RowRange<T extends Comparable> {
  T? _from;
  T? _to;

  T parse(String value);

  String validator();

  T get to;

  T get from;

  T? get toNullable;

  T? get fromNullable;

  set to(T value) {
    _to = value;
  }

  set from(T value) {
    _from = value;
  }

  bool isEmpty();

  bool isNotEmpty() {
    return !isEmpty();
  }
}