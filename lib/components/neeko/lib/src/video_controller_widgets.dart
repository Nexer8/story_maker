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

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'duration_formatter.dart';
import 'neeko_player_options.dart';
import 'progress_bar.dart';
import 'video_controller_wrapper.dart';

class CenterControllerActionButtons extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final ValueNotifier<bool> showControllers;
  final Widget bufferIndicator;
  final Function onSkipPrevious;
  final Function onSkipNext;

  const CenterControllerActionButtons(this.controllerWrapper,
      {Key key,
      this.showControllers,
      this.bufferIndicator,
      this.onSkipPrevious,
      this.onSkipNext})
      : super(key: key);

  @override
  _CenterControllerActionButtonsState createState() =>
      _CenterControllerActionButtonsState();
}

class _CenterControllerActionButtonsState
    extends State<CenterControllerActionButtons>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _controllerWrapper = widget.controllerWrapper;
    _controllerWrapper.addListener(() {
      _attachListenerToController();
    });
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 300),
    );
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  dispose() {
    _animController.dispose();
    super.dispose();
  }

  _attachListenerToController() {
    controller?.addListener(_videoControllerListener);
  }

  _videoControllerListener() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isPlaying = controller.value.isPlaying;
    });

    if (controller.value.isPlaying) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  _removeVideoControllerListener() {
    controller?.removeListener(_videoControllerListener);
  }

  _animate() {}

  @override
  Widget build(BuildContext context) {
    if (_controllerWrapper.controller == null) {
      return Container();
    }

    final iconSize = 60.0;

    _removeVideoControllerListener();
    _attachListenerToController();

    if (controller.value.isBuffering) {
      return widget.bufferIndicator;
    } else {
      return Visibility(
        visible: widget.showControllers.value || !controller.value.isPlaying,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
          ),
          height: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: _play,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _animController.view,
                    color: Colors.white,
                    size: iconSize * 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _play() async {
    if (!controller.value.initialized) {
      return;
    }

    if (_isPlaying) {
      controller.pause();
    } else {
      if (controller.value.position == null) {
        controller.play();
      } else if (controller.value.position.inMilliseconds >=
          controller.value.duration.inMilliseconds) {
        await controller.seekTo(Duration(seconds: 0));
        await controller.play();
      } else {
        controller.play();
      }
    }

    _animate();
  }
}

class TouchShutter extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final ValueNotifier<bool> showControllers;
  final bool enableDragSeek;

  const TouchShutter(this.controllerWrapper,
      {Key key, this.showControllers, this.enableDragSeek})
      : super(key: key);

  @override
  _TouchShutterState createState() => _TouchShutterState();
}

class _TouchShutterState extends State<TouchShutter> {
  double dragStartPos = 0.0;
  double delta = 0.0;
  int seekToPosition = 0;
  String seekDuration = "";
  String seekPosition = "";

  bool _dragging = false;

  VideoPlayerController get controller => widget.controllerWrapper.controller;

  @override
  void initState() {
    super.initState();
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Container();
    }

    return widget.enableDragSeek
        ? GestureDetector(
            onTap: () =>
                widget.showControllers.value = !widget.showControllers.value,
            onHorizontalDragStart: (details) {
              setState(() {
                _dragging = true;
              });
              dragStartPos = details.globalPosition.dx;
            },
            onHorizontalDragUpdate: (details) {
              delta = details.globalPosition.dx - dragStartPos;
              seekToPosition =
                  (controller.value.position.inMilliseconds + delta * 1000)
                      .round();
              setState(() {
                seekDuration = (delta < 0 ? "- " : "+ ") +
                    durationFormatter(
                        (delta < 0 ? -1 : 1) * (delta * 1000).round());
                if (seekToPosition < 0) seekToPosition = 0;
                seekPosition = durationFormatter(seekToPosition);
              });
            },
            onHorizontalDragEnd: (_) {
              controller.seekTo(Duration(milliseconds: seekToPosition));
              setState(() {
                _dragging = false;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: _dragging
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Colors.black.withAlpha(150),
                        ),
                        child: Text(
                          "$seekDuration ($seekPosition)",
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          )
        : GestureDetector(
            onTap: () =>
                widget.showControllers.value = !widget.showControllers.value,
          );
  }
}

class TopBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final List<Widget> actions;
  final ValueNotifier<bool> showControllers;
  final Widget leading;
  final NeekoPlayerOptions options;
  final Function onPortraitBackTap;
  final Function onLandscapeBackTap;

  final bool isFullscreen;

  const TopBar(this.controllerWrapper,
      {Key key,
      this.showControllers,
      this.actions,
      this.leading,
      this.options,
      this.onPortraitBackTap,
      this.onLandscapeBackTap,
      this.isFullscreen = false})
      : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.showControllers.value,
      child: Padding(
        padding: EdgeInsets.only(
            left: 2.0, right: 2.0, top: MediaQuery.of(context).padding.top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: widget.leading != null
                  ? widget.leading
                  : _buildLeading(context),
              flex: 7,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actions ?? [Container()],
              ),
              flex: 3,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final title = widget.controllerWrapper.dataSource.displayName;
    final subtitle = widget.controllerWrapper.dataSource.subtitle;
    final ThemeData themeData = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 8,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null)
                Text(
                  title,
                  maxLines: 1,
                  style: themeData.textTheme.subtitle1
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  softWrap: true,
                  style: themeData.textTheme.bodyText2
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )
            ],
          ),
          SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }
}

class BottomBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final Color backgroundColor;
  final double aspectRatio;
  final ValueNotifier<bool> showControllers;

  final bool isFullscreen;

  final Function onEnterFullscreen;
  final Function onExitFullscreen;

  const BottomBar(this.controllerWrapper,
      {Key key,
      this.playedColor,
      this.bufferedColor,
      this.handleColor,
      this.backgroundColor,
      this.aspectRatio,
      this.showControllers,
      this.isFullscreen = false,
      this.onEnterFullscreen,
      this.onExitFullscreen})
      : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentPosition = 0;
  int _duration = 0;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => widget.controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    _controllerWrapper = widget.controllerWrapper;
    _controllerWrapper.addListener(() {
      _attachListenerToController();
    });
    widget.showControllers.addListener(
      () {
        if (mounted) setState(() {});
      },
    );
  }

  _attachListenerToController() {
    controller?.addListener(_videoControllerListener);
  }

  _videoControllerListener() {
    if (controller.value.duration == null ||
        controller.value.position == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _currentPosition = controller.value.duration.inMilliseconds == 0
            ? 0
            : controller.value.position.inMilliseconds;
        _duration = controller.value.duration.inMilliseconds;
      });
    }
  }

  _removeVideoControllerListener() {
    controller?.removeListener(_videoControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    _removeVideoControllerListener();
    _attachListenerToController();

    return Visibility(
      visible: widget.showControllers.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 14.0,
          ),
          Text(
            durationFormatter(_currentPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          Expanded(
            child: Padding(
              child: Visibility(
                visible: widget.isFullscreen,
                child: ProgressBar(
                  _controllerWrapper,
                  showControllers: widget.showControllers,
                  backgroundColor: widget.backgroundColor,
                  bufferedColor: widget.bufferedColor,
                  handleColor: widget.handleColor,
                  playedColor: widget.playedColor,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
          ),
          Text(
            "${durationFormatter(_duration)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (controller == null || !controller.value.initialized) {
                return;
              }
              if (widget.isFullscreen && widget.onExitFullscreen != null) {
                widget.onExitFullscreen();
              } else if (!widget.isFullscreen &&
                  widget.onEnterFullscreen != null) {
                widget.onEnterFullscreen();
              }
            },
          ),
        ],
      ),
    );
  }
}

class LiveBottomBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;

  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final Color backgroundColor;
  final double aspectRatio;
  final ValueNotifier<bool> showControllers;

  final Color liveUIColor;

  final bool isFullscreen;

  final Function onEnterFullscreen;
  final Function onExitFullscreen;

  const LiveBottomBar(this.controllerWrapper,
      {Key key,
      this.playedColor,
      this.bufferedColor,
      this.handleColor,
      this.backgroundColor,
      this.aspectRatio,
      this.showControllers,
      this.liveUIColor,
      this.isFullscreen = false,
      this.onEnterFullscreen,
      this.onExitFullscreen})
      : super(key: key);

  @override
  _LiveBottomBarState createState() => _LiveBottomBarState();
}

class _LiveBottomBarState extends State<LiveBottomBar> {
  int _currentPosition = 0;
  double _currentSliderPosition = 0.0;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    controllerWrapper = widget.controllerWrapper;
    _attachListenerToController();
    widget.showControllers.addListener(
      () {
        if (mounted) setState(() {});
      },
    );
  }

  _attachListenerToController() {
    controller.addListener(
      () {
        if (controller.value.duration == null ||
            controller.value.position == null) {
          return;
        }
        if (mounted) {
          setState(() {
            _currentPosition = controller.value.position.inMilliseconds;
            _currentSliderPosition = controller.value.position.inMilliseconds /
                controller.value.duration.inMilliseconds;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controllerWrapper.hashCode != widget.controllerWrapper.hashCode) {
      controllerWrapper = widget.controllerWrapper;
      _attachListenerToController();
    }
    return Visibility(
      visible: widget.showControllers.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 14.0,
          ),
          Text(
            durationFormatter(_currentPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
          Expanded(
            child: Padding(
              child: Slider(
                value: _currentSliderPosition,
                onChanged: (value) {
                  controller.seekTo(
                    Duration(
                      milliseconds:
                          (controller.value.duration.inMilliseconds * value)
                              .round(),
                    ),
                  );
                },
                activeColor: widget.liveUIColor,
                inactiveColor: Colors.transparent,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
          ),
          InkWell(
            onTap: () => controller.seekTo(controller.value.duration),
            child: Material(
              color: widget.liveUIColor,
              child: Text(
                "LIVE ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (controller == null || !controller.value.initialized) {
                return;
              }

              if (widget.isFullscreen && widget.onExitFullscreen != null) {
                widget.onExitFullscreen();
              } else if (!widget.isFullscreen &&
                  widget.onEnterFullscreen != null) {
                widget.onEnterFullscreen();
              }
            },
          ),
        ],
      ),
    );
  }
}
