import 'dart:io';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfLiteInterpreter {
  late Interpreter _interpreter;
  late final List<String> labels;
  late final IsolateInterpreter _isolateInterpreter;
  late int inputTensorWidth, inputTensorHeight;
  late int outputTensorWidth, outputTensorHeight;

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
      _isolateInterpreter = await IsolateInterpreter.create(
        address: _interpreter.address,
      );
      // Get tensor input shape [1, 224, 224, 3]
      var inputTensor = _interpreter.getInputTensors().first;
      inputTensorWidth = inputTensor.shape[1];
      inputTensorHeight = inputTensor.shape[2];
      // Get tensor output shape [1, 70]
      var outputTensor = _interpreter.getOutputTensors().first;
      outputTensorWidth = outputTensor.shape[1];
      outputTensorHeight = outputTensor.shape[2];
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
  }

  Future<void> close() async {
    await _isolateInterpreter.close();
    _interpreter.close();
  }

  processImage(image_lib.Image? img, int width, int height) {
    // resize original image to match model shape.
    image_lib.Image imageInput = image_lib.copyResize(
      img!,
      width: width,
      height: height,
    );

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(imageInput.width, (x) {
        final pixel = imageInput.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      }),
    );
    return imageMatrix;
  }

  Future<List<DetectedObject>> _predict(File imageFile) async {
    final imageData = imageFile.readAsBytesSync();
    var image = image_lib.decodeImage(imageData);

    var imageMatrix = processImage(image, inputTensorWidth, inputTensorHeight);

    // Set tensor input [1, 224, 224, 3]
    final input = [imageMatrix];
    // Set tensor output [1, 70]
    final output = [List<double>.filled(outputTensorWidth, 0)];

    await _isolateInterpreter.run(input, output);

    final result = output.first;
    // int maxScore = 255; //result.reduce((a, b) => a + b);
    // Set classification map {label: points}
    var classification = <String, double>{};
    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points
        classification[labels[i]] = result[i].toDouble();
      }
    }
    // print(classification);

    return classification.entries
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
