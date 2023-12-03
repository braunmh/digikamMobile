import 'package:openapi/openapi.dart';

import '../settings.dart';

class KeywordService {

  static List<Keyword> _keywords = [];

  static Future<List<Keyword>> getKeywords() async {
    if (_keywords.isNotEmpty) {
      return _keywords;
    }
    KeywordsApi api = Openapi(basePathOverride: SettingsFactory().settings.url)
        .getKeywordsApi();
    final response = await api.findKeywordsByName(name: '');
    if (response.statusCode == 200) {
      _keywords = response.data!.toList();
      return _keywords;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static void refresh() {
    _keywords.clear();
  }
}

class CameraService {
  static final List<String> _cameras = [];

  static Future<List<String>> getCameras() async {
    if (_cameras.isNotEmpty) {
      return _cameras;
    }
    CameraApi api = Openapi(basePathOverride: SettingsFactory().settings.url).getCameraApi();
    final response = await api.findCamerasByMakerAndModel(makeAndModel: '');
    if (response.statusCode == 200) {
      for (Camera camera in response.data!) {
        _cameras.add(camera.name);
      }
      return _cameras;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static void refresh() {
    _cameras.clear();
  }

}

class AuthorService {
  static final List<String> _authors = [];

  static Future<List<String>> getAuthors() async {
    if (_authors.isNotEmpty) {
      return _authors;
    }
    CreatorApi api = Openapi(basePathOverride: SettingsFactory().settings.url).getCreatorApi();
    final response = await api.findCreatorsByName(name:  '');
    if (response.statusCode == 200) {
      for (Creator entry in response.data!) {
        _authors.add(entry.name);
      }
      return _authors;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static void refresh() {
    _authors.clear();
  }

}