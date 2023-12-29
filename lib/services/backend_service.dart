import 'package:built_collection/built_collection.dart';
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

  static Future<List<Keyword>> getKeywordSuggestions(String pattern) async {
    List<Keyword> keywords = await KeywordService.getKeywords();

    if (pattern.isEmpty) {
      return keywords;
    }
    pattern = pattern.toLowerCase();
    return keywords
        .where((k) => k.name.toLowerCase().contains(pattern))
        .toList();
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

class CreatorService {
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

  static Future<List<String>> getAuthorSuggestions(String pattern) async {
    List<String> authors = await CreatorService.getAuthors();

    if (pattern.isEmpty) {
      return authors;
    }
    pattern = pattern.toLowerCase();
    return authors
        .where((k) => k.toLowerCase().contains(pattern))
        .toList();
  }
  static void refresh() {
    _authors.clear();
  }

}
class ImageService {
  static Future<Image> getImageInformation(int imageId) async {
    ImageApi openApi = Openapi(basePathOverride: SettingsFactory().settings.url).getImageApi();
    final response = await openApi.getInformationAboutImage(imageId: imageId);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static Future<String> updateRating(int imageId, int rating) async {
    ImageApi openApi = Openapi(basePathOverride: SettingsFactory().settings.url).getImageApi();
    final response =
    await openApi.rateImage(imageId: imageId, rating: rating);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static Future<void> update({
    required int imageId,
    required int rating,
    required List<Keyword> keywords,
    required String creator,
    required String title,
    required String description}) async {
    ImageApi openApi = Openapi(basePathOverride: SettingsFactory().settings.url).getImageApi();
    ImageUpdateBuilder builder = ImageUpdateBuilder();
    builder.imageId = imageId;
    builder.rating = rating;
    builder.description = description;
    builder.title = title;
    builder.keywords = ListBuilder(keywords.map((k) => k.id).toList());
    builder.creator = creator;
    final response = await openApi.imageUpdate(imageUpdate: builder.build());
    if (200 == response.statusCode) {
      return;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }
}