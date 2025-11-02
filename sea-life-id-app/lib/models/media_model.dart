import 'dart:typed_data';

import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:file_picker/file_picker.dart';
import 'package:underwater_video_tagging/utils/tflite_interpreter.dart';
import 'package:underwater_video_tagging/utils/video_utils.dart';
import 'dart:io';
import 'package:underwater_video_tagging/utils/automatic_tagging_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'media_model.g.dart';

class MediaModel = MediaModelBase with _$MediaModel;

abstract class MediaModelBase with Store {
  MediaModelBase({
    required this.fileType,
    required this.fileName,
    required this.path,
    required this.isLocal,
    required this.isDbSample,
  });

  final FileType fileType;
  final String fileName;
  final String path;
  final bool isLocal;
  final bool isDbSample;

  @observable
  Uint8List? thumbnail;

  @observable
  ObservableList<String> tags = ObservableList();

  @computed
  List<ItemTags> get uiTags {
    return tags.map((s) => ItemTags(index: 0, title: s)).toList();
  }

  @action
  void addTag(String tag) {
    tags.add(tag);
  }

  @action
  void removeTagAt(int index) {
    tags.removeAt(index);
  }

  @observable
  bool hasBeenProcessed = false;

  @action
  void setHasBeenProcessed(bool v) {
    hasBeenProcessed = v;
  }

  @observable
  bool inProcessing = false;

  @action
  void setInProcessing(bool v) {
    inProcessing = v;
  }

  @observable
  int processingProgress = 0;

  @action
  void setProcessingProgress(int v) {
    processingProgress = v;
  }

  @observable
  bool extractingImages = false;

  @action
  void setExtractingImages(bool v) {
    extractingImages = v;
  }

  @action
  Future<void> createThumbnail() async {
    if (this.fileType == FileType.video) {
      try {
        Uint8List? bytes = await VideoThumbnail.thumbnailData(
          video: this.path,
          imageFormat: ImageFormat.WEBP,
          maxWidth: 600,
          timeMs: 0,
          quality: 50,
        );
        thumbnail = bytes;
      } catch (error) {}
    }
  }

  VideoInfo? mediaInfo;

  Future<void> processFile() async {
    // var info = await VideoUtils.getMediaInformation(media.path);
    String mediaProcessingFolder = await VideoUtils.assetPath("processing");
    await Directory(mediaProcessingFolder).create(recursive: true);
    var uuid = Uuid();

    int rc = -1;
    int minimunOccurence = 1;
    if (fileType == FileType.image) {
      rc = await VideoUtils.executeCmd(
        VideoUtils.processAndCopyImage(
          path,
          "$mediaProcessingFolder/${uuid.v1()}.jpg",
        ),
      );
    } else if (fileType == FileType.video) {
      //setExtractingImages(true);

      mediaInfo = await VideoUtils.getMediaInformation(path);
      minimunOccurence = 3;
      rc = await VideoUtils.execute(
        VideoUtils.generateImagesFromVideo(path, mediaProcessingFolder),
        this,
      );
      //setExtractingImages(false);
    }

    if (rc == 0) {
      List<FileSystemEntity> fileSystemEntities = await Directory(
        mediaProcessingFolder,
      ).list(recursive: true, followLinks: false).toList();

      int numFiles = fileSystemEntities.length;

      int numProcessedFiles = 0;

      Map<String, List<DetectedObject>> detectedObjects = {};

      for (FileSystemEntity f in fileSystemEntities) {
        List<DetectedObject> detectedObjectsOnImage =
            await AutomaticTagging.syncroDetectObjectOnImage(f.path);
        // await Future.delayed(Duration(milliseconds: 100));

        for (DetectedObject o in detectedObjectsOnImage) {
          if (!detectedObjects.containsKey(o.detectedClass)) {
            detectedObjects[o.detectedClass] = [];
          }
          detectedObjects[o.detectedClass]!.add(o);
        }
        numProcessedFiles += 1;
        double progress =
            50 + numProcessedFiles.toDouble() / numFiles.toDouble() * 50;
        setProcessingProgress(progress.round());
      }

      Set<String> tags = Set();
      for (String c in detectedObjects.keys) {
        List<DetectedObject>? objs = detectedObjects[c];

        /* print("$c ${objs.length}");
        for (DetectedObject o in objs) {
          print(o);
        } */

        if (objs != null && objs.length >= minimunOccurence) {
          tags.add("$c");
        }
      }
      for (String s in tags) {
        addTag(s);
      }
    }
    await Directory(mediaProcessingFolder).delete(recursive: true);
  }

  @override
  String toString() => "$path (fileType=$fileType)";
}
