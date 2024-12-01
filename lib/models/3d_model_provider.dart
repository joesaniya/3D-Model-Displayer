import 'package:flutter/material.dart';

class ModelProvider with ChangeNotifier {
  // Model data (Path to the model file)
  String _modelPath = '';
  bool _isModelLoaded = false;

  // Camera state
  double _zoomLevel = 1.0;
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  // Getters
  String get modelPath => _modelPath;
  bool get isModelLoaded => _isModelLoaded;
  double get zoomLevel => _zoomLevel;
  double get rotationX => _rotationX;
  double get rotationY => _rotationY;

  // Set model path and loading status
  void loadModel(String path) {
    _modelPath = path;
    _isModelLoaded = true;
    notifyListeners();
  }

  // Reset the model
  void resetModel() {
    _modelPath = '';
    _isModelLoaded = false;
    _zoomLevel = 1.0;
    _rotationX = 0.0;
    _rotationY = 0.0;
    notifyListeners();
  }


  void updateZoom(double delta) {
    _zoomLevel += delta;
    notifyListeners();
  }

  // Update model rotation
  void updateRotation(double deltaX, double deltaY) {
    _rotationX += deltaX;
    _rotationY += deltaY;
    notifyListeners();
  }
}
/*import 'package:flutter/material.dart';

class ModelState with ChangeNotifier {
  String _modelPath = '';
  String get modelPath => _modelPath;

  set modelPath(String path) {
    _modelPath = path;
    notifyListeners();
  }
}


*/