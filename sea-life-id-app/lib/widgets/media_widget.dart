import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:underwater_video_tagging/widgets/media_popup_menu_widget.dart';
import 'package:underwater_video_tagging/widgets/tag_widget.dart';

class MediaWidget extends StatelessWidget {
  MediaWidget(
      {Key? key,
      required this.mediaList,
      required this.mediaIndex,
      required this.onTap,
      required this.appStore})
      : super(key: key);

  final ObservableList<MediaModel> mediaList;
  final int mediaIndex;
  final GestureTapCallback onTap;
  final AppModel appStore;

  Widget getWidgetThumbnailVideo(MediaModel mm) {
    if (mm.thumbnail != null) {
      return GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: mm.fileName,
          child: Stack(
            children: <Widget>[
              Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  alignment: Alignment.center,
                  child: Image.memory(Uint8List.fromList(mm.thumbnail!),
                      fit: BoxFit.cover)),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.play_circle, color: Colors.white)),
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getImage(MediaModel mm) {
    if (!mm.isLocal) {
      return GestureDetector(
          onTap: onTap,
          child: Hero(
              tag: mediaList[mediaIndex].fileName,
              child: CachedNetworkImage(
                  imageUrl: mm.path,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error))));
    } else {
      return GestureDetector(
          onTap: onTap,
          child: Hero(
              tag: mediaList[mediaIndex].fileName,
              child: Image.file(File(mm.path))));
    }
  }

  Widget widgetCustomCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: <Widget>[
          mediaList[mediaIndex].fileType == FileType.video
              ? getWidgetThumbnailVideo(mediaList[mediaIndex])
              : getImage(mediaList[mediaIndex]),
          ListTile(
              title: TagWidget(media: mediaList[mediaIndex]),
              trailing: !mediaList[mediaIndex].isDbSample
                  ? PopUpMenu(app: appStore, media: mediaList[mediaIndex])
                  : null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Card(child: widgetCustomCard());
    });
  }
}
