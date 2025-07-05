import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:underwater_video_tagging/utils/tflite_interpreter.dart';

class AutomaticTagging {
  static String model = "model-3.tflite";
  static String modelLabels = "model-3.txt";
  static String modelVersion = "v3.1";
  static double confidence = 0.40;

  static TfLiteInterpreter? _imageLabeler;

  static Future<void> initLabeler() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File modelFile = File('${appDocDir.path}/model.tflite');
    File modelDicFile = File('${appDocDir.path}/model.txt');
    _imageLabeler = new TfLiteInterpreter(modelFile, modelDicFile, confidence);
    _imageLabeler!.initHelper();
  }

  static Future<List<DetectedObject>> syncroDetectObjectOnImage(
    String path,
  ) async {
    List<DetectedObject> detectedObjects = await _detectObjectOnImage(path);
    return detectedObjects;
  }

  static Future<List<DetectedObject>> _detectObjectOnImage(String path) async {
    List<DetectedObject> detectedObjects = [];
    List<DetectedObject> recognitions = await _imageLabeler!.predictImage(path);
    // print("_imageLabeler $recognitions");
    for (DetectedObject r in recognitions) {
      detectedObjects.add(DetectedObject(r.detectedClass, r.confidenceInClass));
    }

    // print("detectedObjects $detectedObjects");
    return detectedObjects;
  }

  /// copies file from assets to dst file
  static Future<void> copyFileFromAssets(String filename, File dstFile) async {
    ByteData data = await rootBundle.load("assets/$filename");
    final buffer = data.buffer;
    dstFile.writeAsBytesSync(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  static Future<Directory> getAppTmpPath() async {
    Directory tempDir = await getTemporaryDirectory();
    tempDir = Directory("${tempDir.path}/sea-life-id");
    return tempDir;
  }

  static Future<void> deleteAppTmpFolder() async {
    Directory tempDir = await getAppTmpPath();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}
