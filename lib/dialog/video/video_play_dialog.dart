import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:digikam/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:video_player/video_player.dart';

import '../../widget/app_bar.dart';

class VideoPlayerDialog extends StatefulWidget {
  final Media video;

  const VideoPlayerDialog({super.key, required this.video});

  @override
  State<VideoPlayerDialog> createState() {
    return _VideoPlayerState();
  }
}

class _ControllerStatus {
  final bool ready;
  String message;
  _ControllerStatus(this.ready, {this.message = ''});
}

class _VideoPlayerState extends State<VideoPlayerDialog> with SingleTickerProviderStateMixin {

  late final AnimationController _animationController;
  late VideoPlayerController _videoPlayerController;
  late ChewieController chewieController;
  bool startedPlaying = false;
  final bool _showAppBar = false;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<_ControllerStatus> initializeController() async {
    try {
      File videoFile = await VideoService.getVideoAsFile(widget.video);
      _videoPlayerController = VideoPlayerController.file(videoFile);
      await _videoPlayerController.initialize();
      chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          progressIndicatorDelay:
            bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
          hideControlsTimer: const Duration(seconds: 5),
      );
      startedPlaying = true;

      return _ControllerStatus(true);
    } catch (e) {
      return _ControllerStatus(false, message: e.toString());
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.video.name,
        theme: AppTheme.light.copyWith(
            platform: Theme.of(context).platform,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.video.name),
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: buildContent(context),
        ),

    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children:[
        Expanded(
            child: FutureBuilder<_ControllerStatus>(
              future: initializeController(),
              builder: (BuildContext context, AsyncSnapshot<_ControllerStatus> snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data!.ready)
                      ?  Chewie(controller: chewieController)
                      : Text(snapshot.data!.message);
                } else {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  );
                }
              },
            ),

        ),
        TextButton(
          onPressed: () {
            chewieController.enterFullScreen();
          },
          child: const Text('Fullscreen'),
        )
      ]
    );
  }

  SlidingAppBar buildSlidingAppBar(BuildContext context) {
    return SlidingAppBar(
        controller: _animationController,
        visible: _showAppBar,
        child: AppBar(
          title: Text(widget.video.name),
        ));
  }

}

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(secondary: Colors.red),
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(secondary: Colors.red),
    disabledColor: Colors.grey.shade400,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}