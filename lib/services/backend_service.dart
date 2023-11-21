import 'package:openapi/openapi.dart';

import '../settings.dart';

class KeywordService {

  static final List<Keyword> _keywords = [];

  static Future<List<Keyword>> getKeywords() async {
    if (_keywords.isNotEmpty) {
      return _keywords;
    }
    KeywordsApi api = Openapi(basePathOverride: SettingsFactory().settings.url)
        .getKeywordsApi();
    final response = await api.findKeywordsByName(name: '');
    if (response.statusCode == 200) {
      return response.data!.toList();
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static void refresh() {
    _keywords.clear();
  }
}