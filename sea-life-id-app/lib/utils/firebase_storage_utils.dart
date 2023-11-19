import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:underwater_video_tagging/utils/video_utils.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FirebaseStorageUtils {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static Future<bool> uploadMedia(
      String folder, String indice, File f, String comment) async {
    var uuid = Uuid();
    var id = uuid.v1().toString();

    Reference firebaseStorageFileRef =
        _firebaseStorage.ref().child("$folder/${id}_$indice");
    UploadTask uploadTask = firebaseStorageFileRef.putFile(f);
    await Future.value(uploadTask);

    if (comment.isNotEmpty) {
      String mediaProcessingFolder = await VideoUtils.assetPath("processing");
      await Directory(mediaProcessingFolder).create(recursive: true);

      File commentFile = File("$mediaProcessingFolder/${id}_comment.txt");
      commentFile.writeAsStringSync(comment);

      SettableMetadata metadata =
          new SettableMetadata(contentType: "text/plain");
      Reference firebaseStorageCommentFileRef =
          _firebaseStorage.ref().child("$folder/${id}_${indice}_comment.txt");
      UploadTask uploadTask =
          firebaseStorageCommentFileRef.putFile(commentFile, metadata);
      await Future.value(uploadTask);
    }
    return true;
  }

  static Future<bool> hasModel() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File modelFile = File('${appDocDir.path}/model.tflite');
    return modelFile.existsSync();
  }

  static Future<bool> hasLatestModel() async {
    bool hasLatestModel = false;
    FullMetadata metadata =
        await _firebaseStorage.ref('models/model-2.tflite').getMetadata();
    String? firebaseMd5Value = metadata.md5Hash;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File modelFile = File('${appDocDir.path}/model.tflite');
    if (modelFile.existsSync()) {
      Hash hasher = md5;
      Digest localMd5Digest = await hasher.bind(modelFile.openRead()).first;
      String localMd5Value = base64.encode(localMd5Digest.bytes);
      hasLatestModel = firebaseMd5Value == localMd5Value;
    }
    return hasLatestModel;
  }

  static Future<void> downloadModel() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToModelFile = File('${appDocDir.path}/model.tflite');
    await _firebaseStorage
        .ref('models/model-2.tflite')
        .writeToFile(downloadToModelFile);
    File downloadToModelDicFile = File('${appDocDir.path}/model.txt');
    await _firebaseStorage
        .ref('models/model-2.txt')
        .writeToFile(downloadToModelDicFile);
  }

  static Future<bool> initModel() async {
    bool init = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      bool hasLatestModel = await FirebaseStorageUtils.hasLatestModel();
      if (!hasLatestModel) {
        await downloadModel();
        init = true;
      } else {
        // await Future.delayed(Duration(seconds: 1));
        init = true;
      }
    } else {
      bool hasModel = await FirebaseStorageUtils.hasModel();
      if (!hasModel) {
        // await Future.delayed(Duration(seconds: 1));
      } else {
        // await Future.delayed(Duration(seconds: 1));
        init = true;
      }
    }
    return init;
  }
}
