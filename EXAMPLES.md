# 代码示例集合

这个文件包含了 face_plugin 的各种使用场景示例代码。

## 1. 基础使用

### 检测人脸

```dart
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';
import 'dart:io';

Future<void> detectFacesExample() async {
  // 从文件加载图片
  final file = File('path/to/image.jpg');
  final Uint8List imageBytes = await file.readAsBytes();
  
  // 检测人脸
  final List<Face> faces = await FacePlugin.detectFaces(imageBytes);
  
  print('检测到 ${faces.length} 个人脸');
  
  for (var i = 0; i < faces.length; i++) {
    final face = faces[i];
    print('人脸 ${i + 1}:');
    print('  位置: (${face.faceX.toInt()}, ${face.faceY.toInt()})');
    print('  大小: ${face.bboxW.toInt()} x ${face.bboxH.toInt()}');
    print('  置信度: ${face.faceScore.toStringAsFixed(2)}');
  }
}
```

### 提取特征向量

```dart
Future<void> extractFeaturesExample() async {
  final file = File('path/to/image.jpg');
  final Uint8List imageBytes = await file.readAsBytes();
  
  // 提取特征
  final List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);
  
  print('提取了 ${features.length} 个特征向量');
  
  for (var i = 0; i < features.length; i++) {
    print('特征向量 ${i + 1}: ${features[i].length} 维');
    print('  前 5 个值: ${features[i].take(5).map((v) => v.toStringAsFixed(4)).join(", ")}');
  }
}
```

## 2. 人脸比较

### 计算欧氏距离

```dart
import 'dart:math';

double euclideanDistance(List<double> feature1, List<double> feature2) {
  if (feature1.length != feature2.length) {
    throw ArgumentError('Feature vectors must have same length');
  }
  
  double sum = 0;
  for (int i = 0; i < feature1.length; i++) {
    final diff = feature1[i] - feature2[i];
    sum += diff * diff;
  }
  
  return sqrt(sum);
}

Future<void> compareFacesExample() async {
  // 加载两张图片
  final image1 = await File('person1.jpg').readAsBytes();
  final image2 = await File('person2.jpg').readAsBytes();
  
  // 提取特征
  final features1 = await FacePlugin.extractFeatures(image1);
  final features2 = await FacePlugin.extractFeatures(image2);
  
  if (features1.isNotEmpty && features2.isNotEmpty) {
    final distance = euclideanDistance(features1[0], features2[0]);
    print('欧氏距离: ${distance.toStringAsFixed(4)}');
    
    // 通常距离 < 1.0 表示同一个人
    if (distance < 1.0) {
      print('可能是同一个人');
    } else {
      print('可能是不同的人');
    }
  }
}
```

### 计算余弦相似度

```dart
double cosineSimilarity(List<double> feature1, List<double> feature2) {
  if (feature1.length != feature2.length) {
    throw ArgumentError('Feature vectors must have same length');
  }
  
  double dotProduct = 0;
  double norm1 = 0;
  double norm2 = 0;
  
  for (int i = 0; i < feature1.length; i++) {
    dotProduct += feature1[i] * feature2[i];
    norm1 += feature1[i] * feature1[i];
    norm2 += feature2[i] * feature2[i];
  }
  
  if (norm1 == 0 || norm2 == 0) return 0;
  
  return dotProduct / (sqrt(norm1) * sqrt(norm2));
}

Future<void> cosineSimilarityExample() async {
  final image1 = await File('person1.jpg').readAsBytes();
  final image2 = await File('person2.jpg').readAsBytes();
  
  final features1 = await FacePlugin.extractFeatures(image1);
  final features2 = await FacePlugin.extractFeatures(image2);
  
  if (features1.isNotEmpty && features2.isNotEmpty) {
    final similarity = cosineSimilarity(features1[0], features2[0]);
    print('余弦相似度: ${similarity.toStringAsFixed(4)}');
    
    // 通常相似度 > 0.6 表示同一个人
    if (similarity > 0.6) {
      print('可能是同一个人');
    } else {
      print('可能是不同的人');
    }
  }
}
```

## 3. 批量处理

### 处理多张图片

```dart
Future<Map<String, List<double>>> processFaceDatabase(List<String> imagePaths) async {
  final Map<String, List<double>> faceDatabase = {};
  
  for (final path in imagePaths) {
    try {
      final imageBytes = await File(path).readAsBytes();
      final features = await FacePlugin.extractFeatures(imageBytes);
      
      if (features.isNotEmpty) {
        faceDatabase[path] = features[0];
        print('处理完成: $path');
      } else {
        print('未检测到人脸: $path');
      }
    } catch (e) {
      print('处理失败 $path: $e');
    }
  }
  
  return faceDatabase;
}
```

### 人脸搜索

```dart
class FaceSearchResult {
  final String imagePath;
  final double similarity;
  
  FaceSearchResult(this.imagePath, this.similarity);
}

Future<List<FaceSearchResult>> searchSimilarFaces(
  List<double> queryFeature,
  Map<String, List<double>> database,
  {double threshold = 0.6, int topK = 5}
) async {
  final List<FaceSearchResult> results = [];
  
  // 计算查询特征与数据库中每个特征的相似度
  for (final entry in database.entries) {
    final similarity = cosineSimilarity(queryFeature, entry.value);
    if (similarity >= threshold) {
      results.add(FaceSearchResult(entry.key, similarity));
    }
  }
  
  // 按相似度降序排序
  results.sort((a, b) => b.similarity.compareTo(a.similarity));
  
  // 返回前 K 个结果
  return results.take(topK).toList();
}

Future<void> faceSearchExample() async {
  // 构建人脸数据库
  final database = await processFaceDatabase([
    'faces/person1_1.jpg',
    'faces/person1_2.jpg',
    'faces/person2_1.jpg',
    'faces/person3_1.jpg',
  ]);
  
  // 搜索相似人脸
  final queryImage = await File('query.jpg').readAsBytes();
  final queryFeatures = await FacePlugin.extractFeatures(queryImage);
  
  if (queryFeatures.isNotEmpty) {
    final results = await searchSimilarFaces(queryFeatures[0], database);
    
    print('找到 ${results.length} 个相似人脸:');
    for (final result in results) {
      print('  ${result.imagePath}: ${result.similarity.toStringAsFixed(4)}');
    }
  }
}
```

## 4. Flutter Widget 集成

### 实时相机人脸检测

```dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:face_plugin/face_plugin.dart';

class LiveFaceDetection extends StatefulWidget {
  @override
  _LiveFaceDetectionState createState() => _LiveFaceDetectionState();
}

class _LiveFaceDetectionState extends State<LiveFaceDetection> {
  CameraController? _controller;
  List<Face>? _detectedFaces;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    
    await _controller!.initialize();
    setState(() {});
    
    // 开始帧处理
    _controller!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // 转换 CameraImage 到 Uint8List (需要实现转换函数)
      final imageBytes = await convertCameraImage(image);
      
      // 检测人脸
      final faces = await FacePlugin.detectFaces(imageBytes);
      
      setState(() {
        _detectedFaces = faces;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        if (_detectedFaces != null)
          CustomPaint(
            painter: FaceBoxPainter(_detectedFaces!),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            'Faces: ${_detectedFaces?.length ?? 0}',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class FaceBoxPainter extends CustomPainter {
  final List<Face> faces;
  
  FaceBoxPainter(this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final face in faces) {
      // 绘制边界框
      final rect = Rect.fromLTWH(
        face.faceX,
        face.faceY,
        face.bboxW,
        face.bboxH,
      );
      canvas.drawRect(rect, paint);
      
      // 绘制关键点
      final pointPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(face.reyeX, face.reyeY), 3, pointPaint);
      canvas.drawCircle(Offset(face.leyeX, face.leyeY), 3, pointPaint);
      canvas.drawCircle(Offset(face.noseX, face.noseY), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
```

## 5. 错误处理

### 完善的错误处理示例

```dart
Future<void> robustFaceDetection(String imagePath) async {
  try {
    // 检查文件是否存在
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('图片文件不存在: $imagePath');
    }
    
    // 读取图片
    final imageBytes = await file.readAsBytes();
    
    if (imageBytes.isEmpty) {
      throw Exception('图片文件为空');
    }
    
    // 检测人脸
    final faces = await FacePlugin.detectFaces(imageBytes);
    
    if (faces.isEmpty) {
      print('未检测到人脸');
      return;
    }
    
    print('成功检测到 ${faces.length} 个人脸');
    
    // 提取特征
    final features = await FacePlugin.extractFeatures(imageBytes);
    
    if (features.length != faces.length) {
      print('警告: 特征数量与人脸数量不匹配');
    }
    
    // 处理结果
    for (var i = 0; i < faces.length; i++) {
      print('人脸 ${i + 1}: 置信度 ${faces[i].faceScore}');
      if (i < features.length) {
        print('  特征向量维度: ${features[i].length}');
      }
    }
    
  } on FileSystemException catch (e) {
    print('文件系统错误: $e');
  } on FormatException catch (e) {
    print('图片格式错误: $e');
  } catch (e) {
    print('未知错误: $e');
  }
}
```

## 6. 性能优化

### 使用 Isolate 处理大批量图片

```dart
import 'dart:isolate';

class FaceProcessTask {
  final String imagePath;
  final SendPort sendPort;
  
  FaceProcessTask(this.imagePath, this.sendPort);
}

void faceProcessIsolate(FaceProcessTask task) async {
  try {
    final imageBytes = await File(task.imagePath).readAsBytes();
    final features = await FacePlugin.extractFeatures(imageBytes);
    
    task.sendPort.send({
      'path': task.imagePath,
      'features': features.isNotEmpty ? features[0] : null,
      'success': true,
    });
  } catch (e) {
    task.sendPort.send({
      'path': task.imagePath,
      'error': e.toString(),
      'success': false,
    });
  }
}

Future<Map<String, List<double>>> processFacesBatch(List<String> imagePaths) async {
  final results = <String, List<double>>{};
  final receivePort = ReceivePort();
  
  for (final path in imagePaths) {
    await Isolate.spawn(
      faceProcessIsolate,
      FaceProcessTask(path, receivePort.sendPort),
    );
  }
  
  int processed = 0;
  await for (final message in receivePort) {
    final data = message as Map<String, dynamic>;
    
    if (data['success']) {
      if (data['features'] != null) {
        results[data['path']] = data['features'];
      }
    } else {
      print('处理失败: ${data['path']} - ${data['error']}');
    }
    
    processed++;
    if (processed >= imagePaths.length) {
      receivePort.close();
      break;
    }
  }
  
  return results;
}
```

## 7. 数据持久化

### 保存和加载特征向量

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FaceFeatureStorage {
  static const String _keyPrefix = 'face_feature_';
  
  // 保存特征向量
  static Future<void> saveFeature(String userId, List<double> feature) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(feature);
    await prefs.setString('$_keyPrefix$userId', jsonString);
  }
  
  // 加载特征向量
  static Future<List<double>?> loadFeature(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$userId');
    
    if (jsonString == null) return null;
    
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((e) => e as double).toList();
  }
  
  // 删除特征向量
  static Future<void> deleteFeature(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$userId');
  }
  
  // 获取所有保存的特征
  static Future<Map<String, List<double>>> loadAllFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    
    final Map<String, List<double>> features = {};
    
    for (final key in keys) {
      final userId = key.substring(_keyPrefix.length);
      final feature = await loadFeature(userId);
      if (feature != null) {
        features[userId] = feature;
      }
    }
    
    return features;
  }
}

// 使用示例
Future<void> storageExample() async {
  // 提取并保存特征
  final imageBytes = await File('user_photo.jpg').readAsBytes();
  final features = await FacePlugin.extractFeatures(imageBytes);
  
  if (features.isNotEmpty) {
    await FaceFeatureStorage.saveFeature('user_123', features[0]);
    print('特征已保存');
  }
  
  // 加载特征进行比对
  final savedFeature = await FaceFeatureStorage.loadFeature('user_123');
  if (savedFeature != null) {
    final newImageBytes = await File('new_photo.jpg').readAsBytes();
    final newFeatures = await FacePlugin.extractFeatures(newImageBytes);
    
    if (newFeatures.isNotEmpty) {
      final similarity = cosineSimilarity(savedFeature, newFeatures[0]);
      print('相似度: $similarity');
    }
  }
}
```

---

这些示例涵盖了 face_plugin 的主要使用场景。根据您的具体需求，可以组合和修改这些示例代码。

