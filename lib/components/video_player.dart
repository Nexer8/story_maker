import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neeko/neeko.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:storymaker/services/general_processor.dart';

class MyVideoPlayer extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<MyVideoPlayer> {
  VideoControllerWrapper videoControllerWrapper;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generalStoryProcessor = Provider.of<GeneralStoryProcessor>(context);

    return Expanded(
      child: Column(children: <Widget>[
        Expanded(
          child: Container(),
        ),
        generalStoryProcessor.processedClip == null
            ? Container()
            : Container(
                child: NeekoPlayerWidget(
                  videoControllerWrapper: videoControllerWrapper =
                      VideoControllerWrapper(
                          DataSource.file(generalStoryProcessor.processedClip)),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final RenderBox box = context.findRenderObject();

                        await Share.shareFiles(
                            [generalStoryProcessor.processedClip.path],
                            sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size);
                        // GallerySaver.saveVideo(
                        //     generalStoryProcessor.processedClip.path);
                        print('Share');
                      },
                    ),
                  ],
                ),
              ),
        Expanded(
          child: Container(),
        ),
      ]),
    );
  }
}
