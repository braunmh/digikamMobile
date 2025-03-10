import 'dart:io';
import 'dart:ui';

import 'package:digikam/dialog/video/video_about_dialog.dart';
import 'package:digikam/dialog/goto_position_dialog.dart';
import 'package:digikam/dialog/video/video_play_dialog.dart';
import 'package:digikam/dialog/video/video_update_dialog.dart';
import 'package:digikam/dialog/video/video_rate_dialog.dart';
import 'package:digikam/settings.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:openapi/openapi.dart' as open_api;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';

import '../../widget/app_bar.dart';

class VideoSlider extends StatefulWidget {
  const VideoSlider({
    super.key,
    required this.videos,
  });

  final List<open_api.Media> videos;

  @override
  State<VideoSlider> createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  late List<String> videoUrl;
  bool _showAppBar = false;
  late final AnimationController _animationController;
  late final CarouselSliderController _carouselController;
  late int maxWidth;
  late int maxHeight;
  int current = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _carouselController = CarouselSliderController();
    FlutterView view = PlatformDispatcher.instance.views.first;
    maxWidth = view.physicalSize.width.toInt();
    maxHeight = (view.physicalSize.height + 56).toInt();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    String remoteUrl = SettingsFactory().settings.url;
    videoUrl = widget.videos
        .map((e) => '$remoteUrl/video/thumbnail/${e.id}')
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
              items: videoUrl
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
    bool isSupportedFormat = widget.videos[current].name.toLowerCase().endsWith('.mp4');
    return SlidingAppBar(
        controller: _animationController,
        visible: _showAppBar,
        child: AppBar(
          title: Text(AppLocalizations.of(context)!.sliderTitle(widget.videos.length)),
          actions: [
            IconButton(
                onPressed: ()  {
                  if (isSupportedFormat) {
                    showVideoDialog(context);
                  } else {
                    showAboutDialog(context);
                  }
                },
                icon: Icon(
                  (isSupportedFormat)
                    ? Icons.play_circle_outline
                    : Icons.info,
                  semanticLabel: AppLocalizations.of(context)!.commonInfo,
                )),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int> (
                    enabled: isSupportedFormat,
                    value:6,
                    child: buildIconText(Icons.play_circle_outline, 'Play Video'),
                  ),
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
                    showRateDialog(context, remoteUrl);
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
                  case 6:
                    if (isSupportedFormat) {
                      showVideoDialog(context);
                    }
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
            GotoPositionDialog(start: current, max: videoUrl.length));
    _carouselController.jumpToPage(pageNr);
  }

  Future<void> showShareDialog() async {
    final http.Response response = await http.get(Uri.parse(videoUrl[current]));
    // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    String filename = '${dir.path}/digikam_$current.jpg';

    // Save to filesystem
    final file = File(filename);
    file.writeAsBytesSync(response.bodyBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Digikam');
  }

  Future<void> showRateDialog(BuildContext context, String remoteUrl) async {
    await showDialog(
        context: context,
        builder: (context) => RateVideoDialog(
            videoId: widget.videos[current].id));
  }

  Future<void> showAboutDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AboutVideoDialog(
            videoId: widget.videos[current].id));
  }

  Future<void> showUpdateDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => VideoUpdateDialog(
            videoId: widget.videos[current].id));
  }

  Future<void> gotoLocation(BuildContext context, String remoteUrl) async {
    final open_api.Video video = await getVideoInformation(widget.videos[current].id, remoteUrl);
    if (video.latitude == null || video.longitude == null) {
      return;
    }
    MapsLauncher.launchCoordinates(video.latitude!, video.longitude!);
  }

  Future<open_api.Video> getVideoInformation(int imageId, String remoteUrl) async {
    open_api.VideoApi openApi =
    open_api.Openapi(basePathOverride: remoteUrl).getVideoApi();
    final response =
    await openApi.getInformationAboutVideo(videoId: imageId);
    if (200 == response.statusCode) {
      return response.data!;
    } else {
      throw Exception(
          'Status: ${response.statusCode} ${response.statusMessage}');
    }
  }

  void showVideoDialog(BuildContext context) {
    Navigator.push<VideoPlayerDialog>(
      context,
      MaterialPageRoute(builder: (BuildContext context) => VideoPlayerDialog(video: widget.videos[current])),
    );
  }

}
