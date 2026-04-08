# face_plugin - 人脸检测与特征提取插件

一个用于 Android 和 iOS 平台的 Flutter 插件，基于 MobileFaceNet 实现人脸检测和特征提取。

## ✨ 功能特性

- **人脸检测**: 检测人脸并返回边界框和面部关键点
- **特征提取**: 使用 MobileFaceNet 提取 128 维人脸特征向量
- **跨平台**: Android (Java + TFLite) 和 iOS (Swift + TFLite) 完整实现
- **开箱即用**: 简洁的 API，易于集成

## 📦 安装

在项目的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  face_plugin:
    path: ../face_plugin  # 或您的实际路径
```

## 🚀 快速开始

### 1. 准备模型文件

使用本插件前，需要提供 MobileFaceNet TFLite 模型：

- **Android**: 将 `mobilefacenet.tflite` 放入 `android/src/main/assets/`
- **iOS**: 将 `mobilefacenet.tflite` 放入 `ios/Classes/`

### 模型要求

- **输入尺寸**: 112x112x3 (RGB 图像)
- **输出**: 128 维特征向量
- **预处理**: 归一化，mean=127.5, std=128.0

模型获取方式：
- https://github.com/sirius-ai/MobileFaceNet_TF
- https://github.com/deepinsight/insightface

详细说明请查看 [MODEL_GUIDE.md](MODEL_GUIDE.md)

### 2. 导入插件

```dart
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';
```

### 3. 检测人脸

```dart
// 加载图片字节数据
Uint8List imageBytes = await loadImageBytes();

// 检测人脸
List<Face> faces = await FacePlugin.detectFaces(imageBytes);

for (Face face in faces) {
  print('检测到人脸: (${face.faceX}, ${face.faceY})');
  print('边界框大小: ${face.bboxW} x ${face.bboxH}');
  print('置信度: ${face.faceScore}');
  print('关键点:');
  print('  右眼: (${face.reyeX}, ${face.reyeY})');
  print('  左眼: (${face.leyeX}, ${face.leyeY})');
  print('  鼻子: (${face.noseX}, ${face.noseY})');
}
```

### 4. 提取特征向量

```dart
// 提取人脸特征
List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);

for (int i = 0; i < features.length; i++) {
  print('人脸 ${i + 1} 特征向量 (${features[i].length} 维)');
  print('  前 5 个值: ${features[i].take(5).toList()}');
}
```

## 📖 API 文档

### Face 类

```dart
class Face {
  final double faceX;        // 人脸边界框 X 坐标
  final double faceY;        // 人脸边界框 Y 坐标
  final double bboxW;        // 边界框宽度
  final double bboxH;        // 边界框高度
  
  final double reyeX;        // 右眼 X 坐标
  final double reyeY;        // 右眼 Y 坐标
  final double leyeX;        // 左眼 X 坐标
  final double leyeY;        // 左眼 Y 坐标
  final double noseX;        // 鼻子 X 坐标
  final double noseY;        // 鼻子 Y 坐标
  final double rmouthX;      // 右嘴角 X 坐标
  final double rmouthY;      // 右嘴角 Y 坐标
  final double lmouthX;      // 左嘴角 X 坐标
  final double lmouthY;      // 左嘴角 Y 坐标
  
  final double width;        // 原始图片宽度
  final double height;       // 原始图片高度
  
  final double faceScore;    // 检测置信度
  final int faceTv;          // 人脸类型值
  final int clsId;           // 分类 ID
}
```

### 方法

#### `detectFaces(Uint8List imageBytes)`

检测图片中的人脸。

- **参数**: 
  - `imageBytes`: 图片字节数据 (Uint8List)
- **返回值**: `Future<List<Face>>` - 检测到的人脸列表

#### `extractFeatures(Uint8List imageBytes)`

提取每个人脸的 128 维特征向量。

- **参数**: 
  - `imageBytes`: 图片字节数据 (Uint8List)
- **返回值**: `Future<List<List<double>>>` - 特征向量列表（每个 128 维）

## 💡 使用示例

### 人脸比较

```dart
import 'dart:math';

// 欧氏距离
double euclideanDistance(List<double> f1, List<double> f2) {
  double sum = 0;
  for (int i = 0; i < f1.length; i++) {
    sum += (f1[i] - f2[i]) * (f1[i] - f2[i]);
  }
  return sqrt(sum);
}

// 余弦相似度
double cosineSimilarity(List<double> f1, List<double> f2) {
  double dot = 0, norm1 = 0, norm2 = 0;
  for (int i = 0; i < f1.length; i++) {
    dot += f1[i] * f2[i];
    norm1 += f1[i] * f1[i];
    norm2 += f2[i] * f2[i];
  }
  return dot / (sqrt(norm1) * sqrt(norm2));
}

// 使用示例
Future<void> compareFaces() async {
  final image1 = await File('person1.jpg').readAsBytes();
  final image2 = await File('person2.jpg').readAsBytes();
  
  final features1 = await FacePlugin.extractFeatures(image1);
  final features2 = await FacePlugin.extractFeatures(image2);
  
  if (features1.isNotEmpty && features2.isNotEmpty) {
    final distance = euclideanDistance(features1[0], features2[0]);
    final similarity = cosineSimilarity(features1[0], features2[0]);
    
    print('欧氏距离: $distance');
    print('余弦相似度: $similarity');
    
    // 判断是否为同一人
    if (distance < 1.0 || similarity > 0.6) {
      print('可能是同一个人');
    }
  }
}
```

更多示例请查看 [EXAMPLES.md](EXAMPLES.md)

## 📱 平台支持

| 平台 | 支持 | 实现 |
|------|------|------|
| Android | ✅ | Java + TFLite 2.14.0 |
| iOS | ✅ | Swift + TFLite 2.14.0 |

## 📋 系统要求

- **Flutter**: >=3.3.0
- **Dart**: ^3.6.0
- **Android**: minSdk 21 (Android 5.0+)
- **iOS**: 12.0+

## ⚠️ 注意事项

### 当前实现

- **人脸检测**: 使用简化算法（假设人脸居中），适合演示和测试
- **特征提取**: 完整实现，可直接用于生产环境

### 生产环境建议

为了获得更好的人脸检测效果，建议集成专业的人脸检测库：

- **Android**: Google ML Kit Face Detection、MTCNN 或 MediaPipe
- **iOS**: Vision Framework 人脸检测

特征提取功能已完全可用于生产环境，基于 MobileFaceNet 模型，性能优异。

## 📚 文档

- [README.md](README.md) - 完整文档（英文）
- [README_CN.md](README_CN.md) - 完整文档（中文）
- [QUICK_START.md](QUICK_START.md) - 快速开始指南
- [MODEL_GUIDE.md](MODEL_GUIDE.md) - 模型集成指南
- [EXAMPLES.md](EXAMPLES.md) - 代码示例集合
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 快速参考卡
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - 部署检查清单

## 🎯 运行示例

```bash
cd example
flutter run
```

示例应用展示了：
- 人脸检测功能
- 特征提取功能
- 详细的结果展示
- 错误处理示例

## 🤝 贡献

欢迎提交 Pull Request！

## 📄 许可证

请查看 LICENSE 文件了解详情。

## 🆘 常见问题

### Q: 模型文件在哪里获取？

A: 查看 [MODEL_GUIDE.md](MODEL_GUIDE.md) 了解如何获取或转换模型文件。

### Q: 如何提高人脸检测准确率？

A: 当前实现使用简化的检测算法。生产环境建议集成专业的人脸检测库（Android 使用 ML Kit，iOS 使用 Vision Framework）。

### Q: 特征向量可以用来做什么？

A: 128 维特征向量可用于：
- 人脸识别（身份验证）
- 人脸相似度比较
- 人脸搜索
- 人脸聚类

### Q: 性能如何？

A: 在中端手机上，特征提取通常在 50-100ms 内完成。具体性能取决于设备和图片大小。

### Q: 支持多人脸吗？

A: 当前实现主要针对单人脸场景，但架构支持多人脸扩展。

## 📞 技术支持

遇到问题？请：
1. 查看相关文档
2. 查看 [EXAMPLES.md](EXAMPLES.md) 中的示例
3. 检查 [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
4. 提交 GitHub Issue

---

**开始使用 face_plugin，让您的应用拥有人脸识别能力！** 🚀

