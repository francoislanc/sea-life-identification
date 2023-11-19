import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:underwater_video_tagging/widgets/my_video_player.dart';

void openVideoPlayer(
    BuildContext context, final List<MediaModel> items, final int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      if (items.elementAt(index).fileType == FileType.video) {
        return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.black),
            child: Dialog(child: MyVideoPlayer(media: items.elementAt(index))));
      } else {
        return Dialog(
          child: Container(
            child: PhotoView(
              tightMode: true,
              imageProvider: items.elementAt(index).isLocal
                  ? FileImage(File(items.elementAt(index).path))
                      as ImageProvider
                  : CachedNetworkImageProvider(items.elementAt(index).path),
            ),
          ),
        );
      }
    },
  );
}
