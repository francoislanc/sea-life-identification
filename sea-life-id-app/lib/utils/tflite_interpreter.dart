import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:underwater_video_tagging/utils/isolate_inference.dart';

class TfLiteInterpreter {
  late Interpreter _interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  final File modelPath;
  final File labelsPath;
  final double detectionThreshold;

  TfLiteInterpreter(this.modelPath, this.labelsPath, this.detectionThreshold);

  Future<List<DetectedObject>> predictImage(String imgPath) async {
    var image = File(imgPath);
    return await _predict(image);
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = Interpreter.fromFile(modelPath);
      // Get tensor input shape [1, 224, 224, 3]
      inputTensor = _interpreter.getInputTensors().first;
      // Get tensor output shape [1, 1001]
      outputTensor = _interpreter.getOutputTensors().first;
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    final labelTxt = await labelsPath.readAsString();
    labels = labelTxt.split('\n');
  }

  Future<void> initHelper() async {
    _loadLabels();
    _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort
        .send(inferenceModel..responsePort = responsePort.sendPort);
    // get inference result.
    var results = await responsePort.first;
    return results;
  }

  // inference still image
  Future<Map<String, double>> inferenceImage(image_lib.Image image) async {
    var isolateModel = InferenceModel(image, _interpreter.address, labels,
        inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  Future<void> close() async {
    isolateInference.close();
  }

  Future<List<DetectedObject>> _predict(File imageFile) async {
    final imageData = imageFile.readAsBytesSync();
    var image = image_lib.decodeImage(imageData);

    var isolateModel = InferenceModel(image, _interpreter.address, labels,
        inputTensor.shape, outputTensor.shape);
    Map<String, double> doubleMap = await _inference(isolateModel);
    return doubleMap.entries
        .where((e) => e.value > detectionThreshold)
        .map((e) => DetectedObject(e.key, e.value))
        .toList();
  }
}

class DetectedObject {
  DetectedObject(this.detectedClass, this.confidenceInClass);
  final String detectedClass;
  final double confidenceInClass;

  @override
  String toString() =>
      "obj (detectedClass=$detectedClass, confidenceInClass=${confidenceInClass.toStringAsFixed(3)})";
}
