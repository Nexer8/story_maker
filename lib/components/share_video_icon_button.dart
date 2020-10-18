import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ShareVideoIconButton extends StatelessWidget {
  final File videoToShare;

  ShareVideoIconButton({this.videoToShare});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.share,
      ),
      onPressed: () async {
        final RenderBox box = context.findRenderObject();

        await Share.shareFiles([videoToShare.path],
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      },
    );
  }
}
