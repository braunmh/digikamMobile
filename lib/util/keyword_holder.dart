import 'package:built_collection/built_collection.dart';
import 'package:openapi/openapi.dart';

class KeywordHolder {
  final List<Keyword> _keywords = [];
  final List<String> _keywordValues = [];

  void add(Keyword value) {
    _keywords.add(value);
    _keywordValues.add(value.name);
  }

  BuiltList<int>? getParameter(List<String> params) {
    if (params.isNotEmpty) {
      return null;
    }
    List<int> result = [];
    for (String s in params) {
      Keyword k = getByName(s);
      result.add(k.id);
    }
    if (result.isEmpty) {
      return null;
    }
    return result.build();
  }

  Keyword getByName(String value) {
    for (Keyword k in _keywords) {
      if (value.toLowerCase() == k.name.toLowerCase()) {
        return k;
      }
    }
    return Keyword();
  }

  List<String> get keywordValues {
    return _keywordValues;
  }
}
