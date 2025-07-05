import 'package:flutter/material.dart';
import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'dart:async';
import 'package:mime/mime.dart';

import 'package:file_picker/file_picker.dart';

class UploadMediaWidget extends StatelessWidget {
  final AppModel app;

  const UploadMediaWidget({required this.app});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        processPicker(app, FileType.custom);
      },
      heroTag: 'uploadBtn',
      child: Icon(Icons.image),
    );
  }

  Future processPicker(AppModel app, FileType fileType) async {
    FilePickerResult? results = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: [
        "avi",
        "flv",
        "m4v",
        "mkv",
        "mov",
        "mp4",
        "mpeg",
        "webm",
        "wmv",
        "bmp",
        "gif",
        "jpeg",
        "jpg",
        "png",
      ],
      allowMultiple: true,
    );
    if (results == null) return;

    for (PlatformFile pf in results.files) {
      String? filePath = pf.path;
      if (filePath != null) {
        String? mimeStr = lookupMimeType(filePath);

        if (mimeStr != null) {
          List<String> fileTypes = mimeStr.split('/');
          FileType? fileType;
          if (fileTypes.contains("image")) {
            fileType = FileType.image;
          } else if (fileTypes.contains("video")) {
            fileType = FileType.video;
          }

          if (fileType != null) {
            MediaModel media = MediaModel(
              fileType: fileType,
              fileName: pf.name,
              path: filePath,
              isLocal: true,
              isDbSample: false,
            );
            app.addUserMedia(media);
          }
        }
      }
    }
  }
}
