import 'dart:io';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/io.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';

import '../search/bloc.dart';
import '../settings.dart';

class DioSingleton {
  static final baseOptions = BaseOptions(
    baseUrl: SettingsFactory().settings.url,
    connectTimeout: const Duration(milliseconds: 12000),
    receiveTimeout: const Duration(milliseconds: 10000),
  );

  static SecurityContext? _context;
  
  static Future<void> init() async {
    if (_context == null) {
      SecurityContext securityContext = SecurityContext.defaultContext;

      String data = await rootBundle.loadString("assets/cert-selfsigned.pem");
//it can be "cert.crt" as well.
      List<int> bytes = utf8.encode(data);
      securityContext.setTrustedCertificatesBytes(bytes);
      _context = securityContext;
    }
  }

  static Future<Dio> createInstance() async {
    var dio = Dio(baseOptions);

    // always update to the latest fingerprint.
    // openssl s_client -servername pinning-test.badssl.com \
    //    -connect pinning-test.badssl.com:443 < /dev/null 2>/dev/null \
    //    | openssl x509 -noout -fingerprint -sha256
    //final fingerprint = '09B858F7AB304DC51FD05D0BF387A839FBD203BC2DA214F254A23DA923E0E198';
    // Don't trust any certificate just because their root cert is trusted
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(
          context: _context,
        );
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback = (cert, host, port) {
          return true;
        };
        return client;
      },
    );
    return dio;
  }
}
class CacheService {

  static Future<void> refreshServer() async {
    Openapi openapi = Openapi(dio: await DioSingleton.createInstance());
    Response<void> response = await openapi.getCreatorApi().refreshCreatorCache();
    if (response.statusCode != 200) {
      throw Exception('Status: ${response.statusCode} ${response.statusMessage}');
    }
    response = await openapi.getKeywordsApi().refreshKeywordsCache();
    if (response.statusCode != 200) {
      throw Exception('Status: ${response.statusCode} ${response.statusMessage}');
    }
    response = await openapi.getCameraApi().refreshCameraCache();
    if (response.statusCode != 200) {
      throw Exception('Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static void refreshClient() {
    CreatorService.refresh();
    KeywordService.refresh();
    CameraService.refresh();
  }
}

class KeywordService {

  static List<Keyword> _keywords = [];

  static Future<List<Keyword>> getKeywords() async {
    if (_keywords.isNotEmpty) {
      return _keywords;
    }
    KeywordsApi api = Openapi(dio: await DioSingleton.createInstance())
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
    CameraApi api = Openapi(dio: await DioSingleton.createInstance()).getCameraApi();
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
    CreatorApi api = Openapi(dio: await DioSingleton.createInstance()).getCreatorApi();
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
    ImageApi openApi = Openapi(dio: await DioSingleton.createInstance()).getImageApi();
    final response = await openApi.getInformationAboutImage(imageId: imageId);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  static Future<String> updateRating(int imageId, int rating) async {
    ImageApi openApi = Openapi(dio: await DioSingleton.createInstance()).getImageApi();
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
    ImageApi openApi = Openapi(dio: await DioSingleton.createInstance()).getImageApi();
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

  static Future<Response<BuiltList<ImagesInner>>> findImagesByImageAttributes(SearchStartedEvent event
  ) async {
    ImageApi openApi = Openapi(dio: await DioSingleton.createInstance()).getImageApi();
    BuiltList<int> keywords = event.keywords.map((e) => e.id).toList().build();
    final response = await openApi.findImagesByImageAttributes(
        keywords: keywords,
        apertureFrom: event.aperture.fromNullable,
        apertureTo: event.aperture.toNullable,
        creator: event.author,
        dateFrom: (event.date.from.isEmpty()) ? null: event.date.from.toParameter(),
        dateTo: (event.date.to.isEmpty()) ? null: event.date.to.toParameter(),
        focalLengthFrom: event.focalLength.fromNullable,
        focalLengthTo: event.focalLength.toNullable,
        exposureTimeFrom: event.exposureTime.fromNullable,
        exposureTimeTo: event.exposureTime.toNullable,
        isoFrom: event.iso.fromNullable,
        isoTo: event.iso.toNullable,
        makeModel: event.camera,
        orientation: event.orientation,
        ratingFrom: event.rating.fromNullable,
        ratingTo: event.rating.toNullable
    );
    return response;
  }
}