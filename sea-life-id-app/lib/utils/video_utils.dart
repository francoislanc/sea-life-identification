import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:uuid/uuid.dart';

class VideoInfo {
  VideoInfo({required this.duration});
  final double duration;

  @override
  String toString() => "VideoInfo (duration=$duration)";
}

class VideoUtils {
  static final uuid = new Uuid();

  static Future<int> execute(String command, MediaModelBase media) async {
    FFmpegSession s = await FFmpegKit.executeAsync(command);

    SessionState state = await s.getState();
    while (state == SessionState.running || state == SessionState.created) {
      state = await s.getState();
      List<Statistics> statistics = await s.getStatistics();
      if (statistics.length > 0) {
        Statistics lastStatistic = statistics.last;
        await Future.delayed(Duration(milliseconds: 100));
        double progress =
            (lastStatistic.getTime() / (media.mediaInfo!.duration * 1000.0)) *
                50;
        media.setProcessingProgress(progress.round());
      }
    }
    ReturnCode? rc = await s.getReturnCode();
    if (rc != null) {
      return rc.getValue();
    } else {
      return -1;
    }
  }

  static Future<int> executeCmd(String command) async {
    FFmpegSession s = await FFmpegKit.execute(command);
    ReturnCode? rc = await s.getReturnCode();
    if (rc != null) {
      return rc.getValue();
    } else {
      return -1;
    }
  }

  static Future<VideoInfo?> getMediaInformation(String path) async {
    MediaInformationSession session =
        await FFprobeKit.getMediaInformation(path);
    MediaInformation? mapInfo = session.getMediaInformation();
    if (mapInfo != null) {
      double duration = double.parse(mapInfo.getDuration()!);
      return VideoInfo(duration: duration);
    }
    return null;
  }

  static Future<Directory> getAppTmpPath() async {
    Directory tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/sea-life-id");
    return tempDir;
  }

  static Future<Directory> get tempDirectory async {
    return await getAppTmpPath();
  }

  static Future<File> copyFileAssets(String assetName, String localName) async {
    final ByteData assetByteData = await rootBundle.load(assetName);

    final List<int> byteList = assetByteData.buffer
        .asUint8List(assetByteData.offsetInBytes, assetByteData.lengthInBytes);

    final String fullTemporaryPath =
        join((await tempDirectory).path, localName);

    return new File(fullTemporaryPath)
        .writeAsBytes(byteList, mode: FileMode.writeOnly, flush: true);
  }

  static Future<String> assetPath(String assetName) async {
    return join((await tempDirectory).path, assetName, uuid.v1());
  }

  static String processAndCopyImage(String inputImage, String outputImage) {
    return "-i " +
        "\"$inputImage\"" +
        " -vf \"scale=w=1024:h=1024:force_original_aspect_ratio=decrease\" " +
        outputImage;
  }

  static String generateImagesFromVideo(String videoPath, String imageFolder) {
    return "-i " +
        "\"$videoPath\"" +
        " -vf \"fps=1.5, scale=w=1024:h=1024:force_original_aspect_ratio=decrease\" " +
        imageFolder +
        "/" +
        "image%04d.jpg -hide_banner";
  }
}
