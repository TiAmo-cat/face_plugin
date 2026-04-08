import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Plugin Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FaceDetectionPage(),
    );
  }
}

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  List<Face>? _faces;
  List<List<double>>? _features;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _testWithSampleImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load a sample image from assets
      // For this demo, you can use any test image
      // In a real app, you'd use image_picker or similar

      final ByteData data = await rootBundle.load('assets/sample_face.jpg');
      final Uint8List imageBytes = data.buffer.asUint8List();

      // Detect faces
      final faces = await FacePlugin.detectFaces(imageBytes);

      // Extract features
      final features = await FacePlugin.extractFeatures(imageBytes);

      setState(() {
        _faces = faces;
        _features = features;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        print('===============>$_errorMessage');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Plugin Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Face Detection & Feature Extraction',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This plugin detects faces and extracts 128-dimensional feature vectors using MobileFaceNet.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testWithSampleImage,
              icon: const Icon(Icons.face),
              label: const Text('Test Face Detection'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing image...'),
                  ],
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              )
            else if (_faces != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Detected ${_faces!.length} face(s)'),
                      Text('Extracted ${_features!.length} feature vector(s)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _faces!.length,
                  itemBuilder: (context, index) {
                    final face = _faces![index];
                    final feature = _features!.isNotEmpty && index < _features!.length
                        ? _features![index]
                        : null;

                    return Card(
                      child: ExpansionTile(
                        title: Text('Face ${index + 1}'),
                        subtitle: Text(
                          'Position: (${face.faceX.toInt()}, ${face.faceY.toInt()}), '
                          'Score: ${face.faceScore.toStringAsFixed(2)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bounding Box:'),
                                Text('  X: ${face.faceX.toStringAsFixed(1)}'),
                                Text('  Y: ${face.faceY.toStringAsFixed(1)}'),
                                Text('  Width: ${face.bboxW.toStringAsFixed(1)}'),
                                Text('  Height: ${face.bboxH.toStringAsFixed(1)}'),
                                const SizedBox(height: 8),
                                Text('Landmarks:'),
                                Text('  Right Eye: (${face.reyeX.toInt()}, ${face.reyeY.toInt()})'),
                                Text('  Left Eye: (${face.leyeX.toInt()}, ${face.leyeY.toInt()})'),
                                Text('  Nose: (${face.noseX.toInt()}, ${face.noseY.toInt()})'),
                                Text('  Right Mouth: (${face.rmouthX.toInt()}, ${face.rmouthY.toInt()})'),
                                Text('  Left Mouth: (${face.lmouthX.toInt()}, ${face.lmouthY.toInt()})'),
                                const SizedBox(height: 8),
                                Text('Image Size: ${face.width.toInt()} x ${face.height.toInt()}'),
                                if (feature != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Feature Vector (${feature.length} dimensions):'),
                                  Text('  First 10 values: ${feature.take(10).map((v) => v.toStringAsFixed(4)).join(', ')}'),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Click the button above to test face detection.\n\n'
                    'Note: Make sure you have placed the mobilefacenet.tflite model file in:\n'
                    '- Android: android/src/main/assets/\n'
                    '- iOS: ios/Classes/',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
