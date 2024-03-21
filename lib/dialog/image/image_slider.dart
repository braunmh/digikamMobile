import 'dart:io';
import 'dart:ui';

import 'package:digikam/dialog/image/image_about_dialog.dart';
import 'package:digikam/dialog/goto_position_dialog.dart';
import 'package:digikam/dialog/image/image_update_dialog.dart';
import 'package:digikam/dialog/image/image_rate_dialog.dart';
import 'package:digikam/settings.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:openapi/openapi.dart' as open_api;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/app_bar.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({
    super.key,
    required this.images,
  });

  final List<open_api.Media> images;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  late List<String> imageUrl;
  bool _showAppBar = false;
  late final AnimationController _animationController;
  late final CarouselController _carouselController;
  late int maxWidth;
  late int maxHeight;
  int current = 0;

  @override
  void initState() {
    super.initState();
    // imageUrl = widget.images.map((e) =>
    // '${widget.remoteUrl}/image/scale?imageId=${e.imageId}&width=${widget
    //     .maxWith}&height=${widget.maxHeight}')
    //     .toList();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _carouselController = CarouselController();
    FlutterView view = PlatformDispatcher.instance.views.first;
    maxWidth = view.physicalSize.width.toInt();
    maxHeight = (view.physicalSize.height + 56).toInt();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    String remoteUrl = SettingsFactory().settings.url;
    imageUrl = widget.images
        .map((e) =>
            '$remoteUrl/image/scale?imageId=${e.id}&width=$maxWidth&height=$maxHeight')
        .toList();

    return Scaffold(
      appBar: (_showAppBar) ? buildSlidingAppBar(context, remoteUrl) : null,
      body: Builder(
        builder: (context) {
          final double height = maxHeight.toDouble();
          return GestureDetector(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                  height: height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      current = index;
                    });
                  }),
              items: imageUrl
                  .map((item) => Center(
                          child: Image.network(
                        item,
                        fit: BoxFit.fitWidth,
                        height: height,
                      )))
                  .toList(),
            ),
            onDoubleTap: () {
              setState(() => _showAppBar = !_showAppBar);
            },
          );
        },
      ),
    );
  }

  SlidingAppBar buildSlidingAppBar(BuildContext context, String remoteUrl) {
    return SlidingAppBar(
        controller: _animationController,
        visible: _showAppBar,
        child: AppBar(
          title: Text(AppLocalizations.of(context)!.sliderTitle(widget.images.length)),
          actions: [
            IconButton(
                onPressed: () async {
                  await showAboutDialog(context);
                },
                icon: Icon(
                  Icons.info,
                  semanticLabel: AppLocalizations.of(context)!.commonInfo,
                )),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                      value: 0,
                      child: buildIconText(Icons.share, AppLocalizations.of(context)!.commonShare)
                  ),
                  PopupMenuItem<int>(
                      value: 1,
                      child: buildIconText(Icons.navigation, AppLocalizations.of(context)!.commonGoto)
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: buildIconText(Icons.star_rate_rounded, AppLocalizations.of(context)!.commonRate),
                  ),
                  PopupMenuItem<int>(
                    value: 5,
                    child: buildIconText(Icons.edit_attributes, AppLocalizations.of(context)!.commonEdit),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: buildIconText(Icons.info, AppLocalizations.of(context)!.commonInfo),
                  ),
                  PopupMenuItem<int>(
                    value: 4,
                    child: buildIconText(Icons.map, AppLocalizations.of(context)!.commonLocation),
                  ),
                ];
              },
              onSelected: (int value) {
                switch (value) {
                  case 0:
                    showShareDialog();
                    break;
                  case 1:
                    showGotoDialog();
                    break;
                  case 2:
                    showRateDialog(context);
                    break;
                  case 3:
                    showAboutDialog(context);
                    break;
                  case 4:
                    gotoLocation(context, remoteUrl);
                    break;
                  case 5:
                    showUpdateDialog(context);
                    break;
                }
              },
            ),
          ],
        ));
  }

  Row buildIconText(IconData icon, text) {
    return Row(
      children: [
        Icon(icon),
        Text(text),
      ],
    );
  }

  Future<void> showGotoDialog() async {
    int pageNr = await showDialog(
        context: context,
        builder: (context) =>
            GotoPositionDialog(start: current, max: imageUrl.length));
    _carouselController.jumpToPage(pageNr);
  }

  Future<void> showShareDialog() async {
    final http.Response response = await http.get(Uri.parse(imageUrl[current]));
    // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    String filename = '${dir.path}/digikam_$current.jpg';

    // Save to filesystem
    final file = File(filename);
    file.writeAsBytesSync(response.bodyBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Digikam');
  }

  Future<void> showRateDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => RateImageDialog(
            imageId: widget.images[current].id));
  }

  Future<void> showAboutDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AboutImageDialog(
            imageId: widget.images[current].id));
  }

  Future<void> showUpdateDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => ImageUpdateDialog(
            imageId: widget.images[current].id));
  }

  Future<void> gotoLocation(BuildContext context, String remoteUrl) async {
    final open_api.Image image = await getImageInformation(widget.images[current].id, remoteUrl);
    if (image.latitude == null || image.longitude == null) {
      return;
    }
    MapsLauncher.launchCoordinates(image.latitude!, image.longitude!);
  }

  Future<open_api.Image> getImageInformation(int imageId, String remoteUrl) async {
    open_api.ImageApi openApi =
    open_api.Openapi(basePathOverride: remoteUrl).getImageApi();
    final response =
    await openApi.getInformationAboutImage(imageId: imageId);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

}

