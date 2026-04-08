# 🚀 Face Plugin - 快速参考卡

---

## ⚡ 3 步开始

### 1️⃣ 获取模型
下载 `mobilefacenet.tflite` 模型文件  
👉 查看 [MODEL_GUIDE.md](MODEL_GUIDE.md)

### 2️⃣ 放置模型
```bash
# Android
android/src/main/assets/mobilefacenet.tflite

# iOS
ios/Classes/mobilefacenet.tflite
```

### 3️⃣ 使用插件
```dart
import 'package:face_plugin/face_plugin.dart';

// 检测人脸
List<Face> faces = await FacePlugin.detectFaces(imageBytes);

// 提取特征
List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);
```

---

## 📋 核心 API

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `detectFaces(imageBytes)` | `List<Face>` | 检测人脸，返回边界框和关键点 |
| `extractFeatures(imageBytes)` | `List<List<double>>` | 提取 128 维特征向量 |

---

## 🎯 Face 数据结构

```dart
Face {
  // 边界框
  faceX, faceY, bboxW, bboxH
  
  // 5 个关键点
  reyeX, reyeY      // 右眼
  leyeX, leyeY      // 左眼
  noseX, noseY      // 鼻子
  rmouthX, rmouthY  // 右嘴角
  lmouthX, lmouthY  // 左嘴角
  
  // 元数据
  width, height     // 图片尺寸
  faceScore         // 置信度
}
```

---

## 💡 常用代码片段

### 人脸比较（欧氏距离）
```dart
double euclideanDistance(List<double> f1, List<double> f2) {
  double sum = 0;
  for (int i = 0; i < f1.length; i++) {
    sum += (f1[i] - f2[i]) * (f1[i] - f2[i]);
  }
  return sqrt(sum);
}

// 使用: 距离 < 1.0 通常表示同一人
double dist = euclideanDistance(features1[0], features2[0]);
```

### 人脸比较（余弦相似度）
```dart
double cosineSimilarity(List<double> f1, List<double> f2) {
  double dot = 0, norm1 = 0, norm2 = 0;
  for (int i = 0; i < f1.length; i++) {
    dot += f1[i] * f2[i];
    norm1 += f1[i] * f1[i];
    norm2 += f2[i] * f2[i];
  }
  return dot / (sqrt(norm1) * sqrt(norm2));
}

// 使用: 相似度 > 0.6 通常表示同一人
double sim = cosineSimilarity(features1[0], features2[0]);
```

---

## 📱 平台支持

| 平台 | 最低版本 | 依赖 |
|------|----------|------|
| Android | API 21 (5.0) | TFLite 2.14.0 |
| iOS | 12.0 | TFLite 2.14.0 |
| Flutter | 3.3.0+ | - |

---

## 📚 文档导航

| 文档 | 内容 |
|------|------|
| [README.md](README.md) | 完整 API 文档 |
| [QUICK_START.md](QUICK_START.md) | 详细入门教程 |
| [MODEL_GUIDE.md](MODEL_GUIDE.md) | 模型获取和转换 |
| [EXAMPLES.md](EXAMPLES.md) | 20+ 代码示例 |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | 上线检查清单 |

---

## ⚠️ 重要提示

### ✅ 可用于生产
- **特征提取**: 完整实现，基于 MobileFaceNet

### ⚠️ 建议增强
- **人脸检测**: 当前为简化版本
- **生产建议**: 集成 ML Kit (Android) 或 Vision Framework (iOS)

---

## 🔍 故障排除

### 问题: 模型加载失败
```
✅ 检查文件路径
✅ 验证文件名: mobilefacenet.tflite
✅ 确认文件完整性
✅ 查看控制台日志
```

### 问题: 特征提取返回空数组
```
✅ 确认模型文件已放置
✅ 检查图片格式（支持 JPG/PNG）
✅ 验证图片不为空
✅ 查看原生日志
```

---

## 💻 示例应用

```bash
cd example
flutter run
```

功能演示:
- ✅ 人脸检测 UI
- ✅ 特征提取展示
- ✅ 详细结果显示
- ✅ 错误处理示例

---

## 📦 安装

```yaml
# pubspec.yaml
dependencies:
  face_plugin:
    path: ../face_plugin
```

```bash
flutter pub get
```

---

## 🎁 额外功能示例

### 人脸搜索
```dart
// 在数据库中搜索相似人脸
Future<List<Result>> searchFaces(
  List<double> queryFeature,
  Map<String, List<double>> database
) async {
  // 实现见 EXAMPLES.md
}
```

### 批量处理
```dart
// 处理多张图片
Future<Map<String, List<double>>> processBatch(
  List<String> imagePaths
) async {
  // 实现见 EXAMPLES.md
}
```

### 数据持久化
```dart
// 保存/加载特征向量
await FaceFeatureStorage.saveFeature(userId, feature);
List<double>? feature = await FaceFeatureStorage.loadFeature(userId);
// 实现见 EXAMPLES.md
```

---

## ✨ 快速命令

```bash
# 格式化代码
flutter format .

# 分析代码
flutter analyze

# 运行示例
cd example && flutter run

# Android 构建
flutter build apk

# iOS 构建
flutter build ios
```

---

**🎉 一切就绪！开始使用吧！**

需要帮助? 查看 [完整文档](README.md) 或 [示例代码](EXAMPLES.md)

