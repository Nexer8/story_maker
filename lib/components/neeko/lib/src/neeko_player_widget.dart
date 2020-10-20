//Copyright (c) 2019 Neeko Contributors
//
//Neeko is licensed under the Mulan PSL v1.
//
//You can use this software according to the terms and conditions of the Mulan PSL v1.
//You may obtain a copy of Mulan PSL v1 at:
//
//http://license.coscl.org.cn/MulanPSL
//
//THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
//PURPOSE.
//
//See the Mulan PSL v1 for more details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:storymaker/components/neeko/lib/src/progress_bar.dart';
import 'package:video_player/video_player.dart';

import 'neeko_fullscreen_player.dart';
import 'neeko_player.dart';
import 'neeko_player_options.dart';
import 'video_controller_widgets.dart';
import 'video_controller_wrapper.dart';

///core video player
class NeekoPlayerWidget extends StatefulWidget {
  final VideoControllerWrapper videoControllerWrapper;

  final NeekoPlayerOptions playerOptions;

  ///The duration for which controls in the player will be visible.
  ///default 3 seconds
  final Duration controllerTimeout;

  /// Overrides the default buffering indicator for the player.
  final Widget bufferIndicator;

  final Color liveUIColor;

  /// Defines the aspect ratio to be assigned to the player.
  /// Default = 16/9
  final double aspectRatio;

  /// Adds custom top bar widgets
  final List<Widget> actions;

  /// Video starts playing from the duration provided.
  final Duration startAt;

  final bool inFullScreen;

  /// Callback of back-button's onTap event  when the top controller is portrait
  final Function onPortraitBackTap;

  /// When the skip previous button tapped
  final Function onSkipPrevious;

  /// When the skip previous button tapped
  final Function onSkipNext;

  final Color progressBarPlayedColor;
  final Color progressBarBufferedColor;
  final Color progressBarHandleColor;
  final Color progressBarBackgroundColor;

  /// Allow developers to indicate a custom tag (which is linked with its corresponding fullscreen)
  final String tag;

  NeekoPlayerWidget(
      {Key key,
      @required this.videoControllerWrapper,
      this.playerOptions = const NeekoPlayerOptions(),
      this.controllerTimeout = const Duration(seconds: 3),
      this.bufferIndicator,
      this.liveUIColor = Colors.red,
      this.aspectRatio = 16 / 9,
      this.actions,
      this.startAt = const Duration(seconds: 0),
      this.inFullScreen = false,
      this.onPortraitBackTap,
      this.onSkipPrevious,
      this.onSkipNext,
      this.progressBarPlayedColor,
      this.progressBarBufferedColor: const Color(0xFF757575),
      this.progressBarHandleColor,
      this.progressBarBackgroundColor: const Color(0xFFF5F5F5),
      this.tag: "com.jarvanmo.neekoPlayerHeroTag"})
      : assert(videoControllerWrapper != null),
        assert(playerOptions != null),
        super(key: key);

  @override
  _NeekoPlayerWidgetState createState() => _NeekoPlayerWidgetState();
}

class _NeekoPlayerWidgetState extends State<NeekoPlayerWidget> {
  final _showControllers = ValueNotifier<bool>(false);

  Timer _timer;

  VideoPlayerController get controller =>
      widget.videoControllerWrapper.controller;

  VideoControllerWrapper get videoControllerWrapper =>
      widget.videoControllerWrapper;

  @override
  void initState() {
    super.initState();
    _loadController();

    _addShowControllerListener();
    _listenVideoControllerWrapper();
    _configureVideoPlayer();
  }

  void _listenVideoControllerWrapper() {
    videoControllerWrapper.addListener(() {
      if (mounted)
        setState(() {
//          _addShowControllerListener();
//          _autoPlay();
        });
    });
  }

  void _addShowControllerListener() {
    _showControllers.addListener(() {
      _timer?.cancel();
      if (_showControllers.value) {
        _timer = Timer(
          widget.controllerTimeout,
          () => _showControllers.value = false,
        );
      }
    });
  }

  void _loadController() {
//    controller = widget.videoPlayerController;
//    controller.isFullScreen = widget.inFullScreen ?? false;
//    controller.addListener(_listener);
  }

  _configureVideoPlayer() {
    if (widget.playerOptions.autoPlay) {
      _autoPlay();
    }

//    widget.videoPlayerController.setLooping(widget.playerOptions.loop);
  }

  _autoPlay() async {
    if (controller == null) {
      return;
    }

    if (controller.value.isPlaying) {
      return;
    }
    if (controller.value.initialized) {
      if (widget.startAt != null) {
        await controller.seekTo(widget.startAt);
      }
      controller.play();
    }
  }

  @override
  void dispose() {
//    if (widget.playerOptions.autoPlay) {
//      controller.dispose();
//    }

//    _showControllers.dispose();
    controller?.dispose();
    videoControllerWrapper?.dispose();
    _timer?.cancel();
    super.dispose();
  }

//  Widget fullScreenRoutePageBuilder(
//      BuildContext context,
//      Animation<double> animation,
//      Animation<double> secondaryAnimation,
//      ) {
//    return _buildFullScreenVideo();
//  }

  void pushFullScreenWidget() {
    final TransitionRoute<void> route = PageRouteBuilder<void>(
      settings: RouteSettings(name: "neeko_full"),
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          fullScreenRoutePageBuilder(
        context: context,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        videoControllerWrapper: widget.videoControllerWrapper,
        actions: widget.actions,
        progressBarBackgroundColor: widget.progressBarBackgroundColor,
        progressBarHandleColor: widget.progressBarHandleColor,
        progressBarBufferedColor: widget.progressBarBufferedColor,
        progressBarPlayedColor: widget.progressBarPlayedColor,
        aspectRatio: widget.aspectRatio,
        bufferIndicator: widget.bufferIndicator,
        onSkipPrevious: widget.onSkipPrevious,
        onSkipNext: widget.onSkipNext,
        controllerTimeout: widget.controllerTimeout,
        playerOptions: NeekoPlayerOptions(
            enableDragSeek: widget.playerOptions.enableDragSeek,
            showFullScreenButton: widget.playerOptions.showFullScreenButton,
            autoPlay: true,
            useController: widget.playerOptions.useController,
            preferredOrientationsWhenEnterLandscape:
                widget.playerOptions.preferredOrientationsWhenEnterLandscape,
            preferredOrientationsWhenExitLandscape:
                widget.playerOptions.preferredOrientationsWhenExitLandscape,
            enabledSystemUIOverlaysWhenEnterLandscape:
                widget.playerOptions.enabledSystemUIOverlaysWhenEnterLandscape,
            enabledSystemUIOverlaysWhenExitLandscape:
                widget.playerOptions.enabledSystemUIOverlaysWhenExitLandscape),
        liveUIColor: widget.liveUIColor,
      ),
    );

    route.completed.then((void value) {
//      controller.setVolume(0.0);
    });

//    controller.setVolume(1.0);
    Navigator.of(context).push(route).then((_) {
      if (mounted)
        setState(() {
          _listenVideoControllerWrapper();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
//    if (controller.isFullScreen == null) {
//      controller.isFullScreen =
//          MediaQuery.of(context).orientation == Orientation.landscape;
//    }

    return Hero(
      tag: this.widget.tag,
      child: Container(
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            overflow: Overflow.visible,
            children: <Widget>[
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width:
                        videoControllerWrapper.controller?.value?.size?.width ??
                            0,
                    height: videoControllerWrapper
                            .controller?.value?.size?.height ??
                        0,
                    child:
                        NeekoPlayer(controllerWrapper: videoControllerWrapper),
                  ),
                ),
              ),
              if (widget.playerOptions.useController)
                TouchShutter(
                  videoControllerWrapper,
                  showControllers: _showControllers,
                  enableDragSeek: widget.playerOptions.enableDragSeek,
                ),
              if (widget.playerOptions.useController)
                Center(
                  child: CenterControllerActionButtons(
                    videoControllerWrapper,
                    showControllers: _showControllers,
                    onSkipPrevious: widget.onSkipPrevious,
                    onSkipNext: widget.onSkipNext,
                    bufferIndicator: widget.bufferIndicator ??
                        Container(
                          width: 70.0,
                          height: 70.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                  ),
                ),
              if (widget.playerOptions.useController)
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: TopBar(
                      videoControllerWrapper,
                      showControllers: _showControllers,
                      options: widget.playerOptions,
                      actions: widget.actions,
                      isFullscreen: false,
                      onPortraitBackTap: widget.onPortraitBackTap,
                    )),
              if (widget.playerOptions.useController)
                (!widget.playerOptions.isLive)
                    ? Positioned(
                        left: 0,
                        right: 0,
                        child: ProgressBar(
                          videoControllerWrapper,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                        ),
                        bottom: -27.9,
                      )
                    : Container(),
              if (widget.playerOptions.useController)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: widget.playerOptions.isLive
                      ? LiveBottomBar(
                          videoControllerWrapper,
                          aspectRatio: widget.aspectRatio,
                          liveUIColor: widget.liveUIColor,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                          isFullscreen: false,
                          onEnterFullscreen: pushFullScreenWidget,
                        )
                      : BottomBar(
                          videoControllerWrapper,
                          aspectRatio: widget.aspectRatio,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                          isFullscreen: false,
                          onEnterFullscreen: pushFullScreenWidget,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
