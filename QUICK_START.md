# Quick Start Guide

## 1. 安装依赖

在您的 Flutter 项目的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  face_plugin:
    path: ../face_plugin  # 或者您的实际路径
```

然后运行：

```bash
flutter pub get
```

## 2. 获取 MobileFaceNet 模型

您需要获取一个 MobileFaceNet TFLite 模型文件。

### 选项 1: 下载预训练模型

从以下仓库获取预训练的 MobileFaceNet 模型：
- https://github.com/sirius-ai/MobileFaceNet_TF
- https://github.com/deepinsight/insightface

### 选项 2: 自己转换模型

如果您有 MobileFaceNet 的其他格式模型，可以使用 TensorFlow Lite Converter 转换。

### 模型要求

- **输入**: 112x112x3 (RGB 图像)
- **输出**: 128 维特征向量
- **预处理**: (pixel - 127.5) / 128.0

## 3. 放置模型文件

### Android

将 `mobilefacenet.tflite` 复制到：
```
face_plugin/android/src/main/assets/mobilefacenet.tflite
```

### iOS

将 `mobilefacenet.tflite` 复制到：
```
face_plugin/ios/Classes/mobilefacenet.tflite
```

## 4. 基本使用

```dart
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';

// 加载图片
Uint8List imageBytes = ...; // 从文件、网络或相机获取

// 检测人脸
List<Face> faces = await FacePlugin.detectFaces(imageBytes);
print('检测到 ${faces.length} 个人脸');

// 提取特征
List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);
print('提取了 ${features.length} 个特征向量');

// 使用人脸信息
for (var i = 0; i < faces.length; i++) {
  final face = faces[i];
  final feature = features[i];
  
  print('人脸 ${i + 1}:');
  print('  位置: (${face.faceX}, ${face.faceY})');
  print('  大小: ${face.bboxW} x ${face.bboxH}');
  print('  置信度: ${face.faceScore}');
  print('  特征向量维度: ${feature.length}');
}
```

## 5. 完整示例

查看 `example/lib/main.dart` 获取完整的使用示例。

运行示例：

```bash
cd example
flutter run
```

## 6. 注意事项

### 当前实现

- 人脸检测使用简化的算法（假设人脸在图片中心）
- 这是为了演示目的，生产环境请使用专业的人脸检测算法

### 生产环境建议

**Android:**
- 集成 Google ML Kit Face Detection
- 或使用 MTCNN
- 或使用 MediaPipe

**iOS:**
- 使用 Vision Framework 的人脸检测
- 或集成第三方人脸检测库

**特征提取:**
- MobileFaceNet 特征提取已完整实现
- 可直接用于人脸识别、人脸相似度比较等应用

## 7. 常见问题

### Q: 模型文件找不到？

**Android:** 确保文件在 `android/src/main/assets/` 目录下，并且文件名正确为 `mobilefacenet.tflite`

**iOS:** 确保文件在 `ios/Classes/` 目录下，并且运行 `pod install` 更新依赖

### Q: 特征提取失败？

检查：
1. 模型文件是否正确放置
2. 模型格式是否符合要求（输入 112x112x3，输出 128 维）
3. 查看控制台错误日志

### Q: 如何比较两个人脸？

```dart
// 计算欧氏距离
double euclideanDistance(List<double> f1, List<double> f2) {
  double sum = 0;
  for (int i = 0; i < f1.length; i++) {
    sum += (f1[i] - f2[i]) * (f1[i] - f2[i]);
  }
  return sqrt(sum);
}

// 计算余弦相似度
double cosineSimilarity(List<double> f1, List<double> f2) {
  double dot = 0, norm1 = 0, norm2 = 0;
  for (int i = 0; i < f1.length; i++) {
    dot += f1[i] * f2[i];
    norm1 += f1[i] * f1[i];
    norm2 += f2[i] * f2[i];
  }
  return dot / (sqrt(norm1) * sqrt(norm2));
}

// 使用
double distance = euclideanDistance(features[0], features[1]);
double similarity = cosineSimilarity(features[0], features[1]);
print('距离: $distance, 相似度: $similarity');
```

## 8. 性能优化

- 图片预处理在原生层完成，性能较好
- 建议在后台线程处理大批量图片
- 可以缓存已提取的特征向量

## 9. 下一步

- 集成完整的人脸检测算法
- 添加活体检测
- 添加人脸对齐
- 优化模型推理性能
- 支持批量处理

祝使用愉快！如有问题，请提交 Issue。

