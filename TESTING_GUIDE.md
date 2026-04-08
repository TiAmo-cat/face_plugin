# 🧪 插件测试指南

## 前置条件

### 已确认
- ✅ Android 模型文件: `android/src/main/assets/mobilefacenet.tflite` (5.2 MB)
- ✅ iOS 模型文件: `ios/Classes/mobilefacenet.tflite` (5.2 MB)  
- ✅ 包名已改为: `myFace`

---

## 测试步骤

### 1. 清理并获取依赖

```bash
cd D:\projects\pluginDemo\facePlugin\face_plugin\example
flutter clean
flutter pub get
```

### 2. Android 测试

#### 方式 A: 连接真机
```bash
# 连接 Android 设备via USB
# 启用 USB 调试

# 运行应用
flutter run
```

#### 方式 B: 使用模拟器
```bash
# 启动 Android 模拟器

# 运行应用
flutter run
```

#### 预期结果
- ✅ 应用正常启动
- ✅ 显示 "Face Plugin Demo" 界面
- ✅ 点击 "Test Face Detection" 按钮
- ✅ 如果有 sample_face.jpg：显示检测结果
- ✅ 如果没有图片：显示错误信息（可以忽略）

#### 验证模型加载
查看 Logcat 输出：
```bash
# 过滤日志
adb logcat | grep -i "face\|tflite\|model"
```

应该看到类似：
```
I/flutter: Detected 1 face(s)
I/flutter: Extracted 1 feature vector(s)
```

没有错误如：
```
E/TfLiteInterpreter: Failed to load model
```

### 3. iOS 测试

#### 安装 CocoaPods 依赖
```bash
cd ios
pod install
cd ..
```

#### 运行应用
```bash
# 使用 iOS 模拟器
flutter run -d "iPhone 15"

# 或使用真机
flutter run -d "您的iPhone名称"
```

#### 预期结果
- ✅ 应用正常启动
- ✅ 显示 "Face Plugin Demo" 界面
- ✅ 点击按钮测试功能
- ✅ 检查控制台日志

#### 验证模型加载
查看 Xcode 控制台：
```
Model loaded successfully from plugin bundle
```

或：
```
Model loaded successfully from main bundle
```

没有错误如：
```
ERROR: Model file 'mobilefacenet.tflite' not found
```

---

## 功能测试

### 测试 1: 基础功能

#### 添加测试图片
```bash
# 准备一张包含人脸的图片 (JPG/PNG)
# 复制到: example/assets/sample_face.jpg
```

#### 运行测试
1. 启动应用
2. 点击 "Test Face Detection"
3. 查看结果

#### 预期输出
```
✅ Results
Detected 1 face(s)
Extracted 1 feature vector(s)

Face 1
Position: (123, 456), Score: 0.95

Bounding Box:
  X: 123.5
  Y: 456.7
  Width: 200.0
  Height: 200.0

Landmarks:
  Right Eye: (150, 480)
  Left Eye: (195, 480)
  Nose: (172, 520)
  Right Mouth: (162, 560)
  Left Mouth: (182, 560)

Image Size: 800 x 600

Feature Vector (128 dimensions):
  First 10 values: 0.1234, -0.5678, 0.9012, ...
```

### 测试 2: 特征向量验证

#### 验证特征向量
```dart
// 在 main.dart 中添加验证代码
final features = await FacePlugin.extractFeatures(imageBytes);

if (features.isNotEmpty) {
  final feature = features[0];
  
  // 检查维度
  assert(feature.length == 128, 'Feature should be 128-dimensional');
  
  // 检查值不全为 0
  final allZero = feature.every((v) => v == 0.0);
  assert(!allZero, 'Feature should not be all zeros');
  
  // 检查值不包含 NaN
  final hasNaN = feature.any((v) => v.isNaN);
  assert(!hasNaN, 'Feature should not contain NaN');
  
  print('✅ Feature vector validation passed');
  print('   Dimension: ${feature.length}');
  print('   Range: ${feature.reduce(min)} to ${feature.reduce(max)}');
  print('   Mean: ${feature.reduce((a, b) => a + b) / feature.length}');
}
```

### 测试 3: 人脸比较

#### 测试相似度计算
```dart
import 'dart:math';

// 计算欧氏距离
double euclideanDistance(List<double> f1, List<double> f2) {
  double sum = 0;
  for (int i = 0; i < f1.length; i++) {
    sum += (f1[i] - f2[i]) * (f1[i] - f2[i]);
  }
  return sqrt(sum);
}

// 测试
final image1 = await loadImage1();
final image2 = await loadImage2();

final features1 = await FacePlugin.extractFeatures(image1);
final features2 = await FacePlugin.extractFeatures(image2);

if (features1.isNotEmpty && features2.isNotEmpty) {
  final distance = euclideanDistance(features1[0], features2[0]);
  print('Distance: $distance');
  
  if (distance < 1.0) {
    print('✅ Same person (distance < 1.0)');
  } else {
    print('⚠️ Different persons (distance >= 1.0)');
  }
}
```

---

## 性能测试

### 测试推理时间

```dart
// 添加计时代码
final stopwatch = Stopwatch()..start();

final features = await FacePlugin.extractFeatures(imageBytes);

stopwatch.stop();
print('⏱️ Feature extraction time: ${stopwatch.elapsedMilliseconds}ms');

// 预期结果 (中端设备):
// Android: 50-150ms
// iOS: 40-120ms
```

### 测试内存使用

#### Android
```bash
# 运行应用后检查内存
adb shell dumpsys meminfo com.example.myFace

# 关注:
# TOTAL PSS: 应该 < 100 MB
```

#### iOS
- 使用 Xcode Instruments
- Memory Profiler
- 检查内存峰值 < 80 MB

---

## 错误场景测试

### 测试 1: 无模型文件
```
临时重命名模型文件测试错误处理
预期: 应用不崩溃，返回空结果或错误信息
```

### 测试 2: 无效图片
```dart
// 传入无效数据
final invalidData = Uint8List(100);
final result = await FacePlugin.detectFaces(invalidData);

// 预期: 不崩溃，返回错误或空列表
```

### 测试 3: 超大图片
```dart
// 加载 10MB+ 的图片
final largeImage = await loadLargeImage();
final result = await FacePlugin.extractFeatures(largeImage);

// 预期: 正常处理或合理的错误信息
```

---

## 验证清单

### 代码验证
- ✅ 无编译错误
- ✅ 无运行时崩溃
- ✅ 内存使用合理
- ✅ 性能符合预期

### 功能验证  
- ✅ detectFaces 返回正确格式
- ✅ extractFeatures 返回 128 维向量
- ✅ 特征向量不全为 0
- ✅ 特征向量不包含 NaN
- ✅ 索引对应关系正确

### 平台验证
- ✅ Android 正常运行
- ✅ iOS 正常运行
- ✅ 模型加载成功
- ✅ 推理正常执行

---

## 常见问题

### Q1: "Failed to decode image"
**原因**: 图片格式不支持或数据损坏  
**解决**: 使用 JPG 或 PNG 格式，检查文件完整性

### Q2: "Model file not found"
**原因**: 模型文件未正确打包  
**解决**:
- Android: 确认文件在 `android/src/main/assets/`
- iOS: 运行 `cd ios && pod install`

### Q3: 特征向量全为 0
**原因**: 模型未正确加载或推理失败  
**解决**: 检查日志，验证模型文件

### Q4: 性能很慢 (>500ms)
**原因**: Debug 模式或设备性能问题  
**解决**: 
- 使用 Release 模式: `flutter run --release`
- 在真机上测试

---

## 测试报告模板

```markdown
# 测试报告

## 测试环境
- 设备: [设备型号]
- 操作系统: [Android/iOS 版本]
- Flutter 版本: [版本号]

## 测试结果

### 功能测试
- [ ] 人脸检测
- [ ] 特征提取
- [ ] 索引对应

### 性能测试
- 推理时间: ___ ms
- 内存使用: ___ MB

### 问题记录
1. [问题描述]
   - 复现步骤:
   - 预期结果:
   - 实际结果:

## 结论
[ ] 通过
[ ] 未通过 - 原因:
```

---

## 下一步

测试通过后:
1. ✅ 完成所有功能测试
2. ✅ 记录测试结果
3. ✅ 准备发布到 pub.dev
4. ✅ 编写使用文档

**立即开始测试！** 🚀

