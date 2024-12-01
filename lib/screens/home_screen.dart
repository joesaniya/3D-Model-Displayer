import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/3d_model_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3D Model Displayer')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['obj', 'stl', 'glb', 'gltf'],
              );
              if (result != null) {
                String path = result.files.single.path!;
                Provider.of<ModelProvider>(context, listen: false)
                    .loadModel(path);
                print('Path:$path');
              }
            },
            child: Text('Load 3D Model'),
          ),
          if (Provider.of<ModelProvider>(context).isModelLoaded)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.rotate_left),
                  onPressed: () {
                    Provider.of<ModelProvider>(context, listen: false)
                        .updateRotation(-0.1, 0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.rotate_right),
                  onPressed: () {
                    Provider.of<ModelProvider>(context, listen: false)
                        .updateRotation(0.1, 0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: () {
                    Provider.of<ModelProvider>(context, listen: false)
                        .updateZoom(0.1);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.zoom_out),
                  onPressed: () {
                    Provider.of<ModelProvider>(context, listen: false)
                        .updateZoom(-0.1);
                  },
                ),
              ],
            ),
          Expanded(
            child: Consumer<ModelProvider>(
              builder: (context, modelProvider, child) {
                if (!modelProvider.isModelLoaded) {
                  return Center(child: Text('No 3D Model Loaded'));
                } else {
                  return WebviewScaffold(
                    url: Uri.dataFromString(
                      '''
                      <html>
                        <head>
                          <title>3D Model Viewer</title>
                          <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
                          <script src="https://cdn.jsdelivr.net/npm/three/examples/js/loaders/GLTFLoader.js"></script>
                        </head>
                        <body>
                          <script>
                            var scene = new THREE.Scene();
                            var camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
                            var renderer = new THREE.WebGLRenderer();
                            renderer.setSize(window.innerWidth, window.innerHeight);
                            document.body.appendChild(renderer.domElement);

                            var loader = new THREE.GLTFLoader();
                            loader.load("file:///${modelProvider.modelPath}", function(gltf) {
                              scene.add(gltf.scene);
                              renderer.render(scene, camera);
                            }, undefined, function(error) {
                              console.error(error);
                            });

                            camera.position.z = 5;

                            var animate = function() {
                              requestAnimationFrame(animate);
                              renderer.render(scene, camera);
                            };

                            animate();

                            // Rotate model based on user interaction
                            window.addEventListener("keydown", function(event) {
                              if (event.key === "ArrowLeft") {
                                camera.rotation.y += 0.1;
                              } else if (event.key === "ArrowRight") {
                                camera.rotation.y -= 0.1;
                              }
                            });

                            // Zoom with mouse wheel
                            window.addEventListener("wheel", function(event) {
                              camera.position.z += event.deltaY * 0.05;
                            });
                          </script>
                        </body>
                      </html>
                      ''',
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ).toString(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:three_d_model_viewer/models/3d_model_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView();
  }

  Future<void> _pickModelFile() async {
    // Allow the user to pick a model file (e.g., .obj, .glb, .stl)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['obj', 'glb', 'stl']);

    if (result != null) {
      String filePath = result.files.single.path ?? '';
      // Update model path in state
      Provider.of<ModelState>(context, listen: false).modelPath = filePath;

      // Load the model in the WebView
      _loadModel(filePath);
    }
  }

  void _loadModel(String filePath) {
    // Convert file path to a URL or local path
    final String htmlContent = '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>3D Model Viewer</title>
        <style>
          body { margin: 0; overflow: hidden; }
          canvas { display: block; }
        </style>
      </head>
      <body>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/loaders/GLTFLoader.min.js"></script>
        <script>
          let scene = new THREE.Scene();
          let camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
          let renderer = new THREE.WebGLRenderer();
          renderer.setSize(window.innerWidth, window.innerHeight);
          document.body.appendChild(renderer.domElement);

          let loader = new THREE.GLTFLoader();
          loader.load('$filePath', function(gltf) {
            scene.add(gltf.scene);
            camera.position.z = 5;
            animate();
          });

          function animate() {
            requestAnimationFrame(animate);
            renderer.render(scene, camera);
          }
        </script>
      </body>
      </html>
    ''';

    _webViewController.loadUrl(Uri.dataFromString(htmlContent,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("3D Model Viewer"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickModelFile,
            child: Text("Load 3D Model"),
          ),
          Expanded(
            child: WebView(
              initialUrl: '',
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              },
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ],
      ),
    );
  }
}
*/



