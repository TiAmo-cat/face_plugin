# 🔍 特征提取失败调试指南

## ❌ 问题

```
Detected 1 face(s)
Extracted 0 feature vector(s)  ← 这里是 0
```

人脸检测成功了，但特征提取失败了。

---

## 🔍 可能的原因

### 1. TFLite 模型未加载 (最常见)
- 模型文件不存在
- 模型文件损坏
- 模型文件路径错误

### 2. 图像处理错误
- 人脸裁剪失败
- 图像预处理错误
- 内存不足

### 3. 模型格式不匹配
- 输入尺寸不对
- 输出维度不对

---

## 🚀 立即检查

### 第 1 步: 查看详细日志

```powershell
# 停止当前运行
# Ctrl+C

# 清理并重新运行
flutter clean
flutter run

# 在另一个终端查看日志
adb logcat -s FacePlugin:* flutter:*
```

### 第 2 步: 查找关键信息

#### 成功的日志应该显示:
```
D/FacePlugin: TFLite model loaded successfully
D/FacePlugin: Extracting features for 1 faces
D/FacePlugin: Face 0 bounding box: Rect(195, 67 - 494, 366)
D/FacePlugin: Crop region: left=136, top=8, width=417, height=417
D/FacePlugin: Face cropped and resized to 112x112
D/FacePlugin: Running TFLite inference...
D/FacePlugin: Feature extracted successfully for face 0, vector length: 128
D/FacePlugin: Total features extracted: 1
```

#### 如果模型未加载:
```
E/FacePlugin: Failed to load TFLite model: ...
E/FacePlugin: TFLite interpreter is null!
```

#### 如果裁剪失败:
```
E/FacePlugin: Invalid crop dimensions for face 0
```

#### 如果推理失败:
```
E/FacePlugin: Error extracting features for face 0: ...
```

---

## ✅ 解决方案

### 方案 1: 验证模型文件

```powershell
# 检查文件是否存在
Test-Path "D:\projects\pluginDemo\facePlugin\face_plugin\android\src\main\assets\mobilefacenet.tflite"

# 检查文件大小
Get-Item "D:\projects\pluginDemo\facePlugin\face_plugin\android\src\main\assets\mobilefacenet.tflite" | Select-Object Name, Length
```

**应该显示:**
- True (文件存在)
- Length: 约 5,233,552 bytes (5 MB)

**如果不存在或大小不对:**
```powershell
# 重新放置模型文件
Copy-Item "你的模型文件路径\mobilefacenet.tflite" "D:\projects\pluginDemo\facePlugin\face_plugin\android\src\main\assets\mobilefacenet.tflite"
```

### 方案 2: 清理并重新构建

```powershell
cd D:\projects\pluginDemo\facePlugin\face_plugin\example

# 完全清理
flutter clean
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue

# Android 清理
cd android
./gradlew clean
cd ..

# 重新获取依赖
flutter pub get

# 重新运行
flutter run
```

### 方案 3: 验证模型格式

如果有 Python 环境，可以验证模型：

```python
import tensorflow as tf
import numpy as np

# 加载模型
interpreter = tf.lite.Interpreter(model_path="mobilefacenet.tflite")
interpreter.allocate_tensors()

# 检查输入输出
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("输入形状:", input_details[0]['shape'])  # 应该是 [1, 112, 112, 3]
print("输出形状:", output_details[0]['shape'])  # 应该是 [1, 128]

# 测试推理
test_input = np.random.randn(1, 112, 112, 3).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], test_input)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

print("输出:", output.shape, output[0][:5])
```

---

## 🎯 常见问题

### Q1: "TFLite interpreter is null"

**原因:** 模型文件加载失败

**解决:**
1. 确认模型文件存在
2. 确认文件名是 `mobilefacenet.tflite`
3. 确认文件大小正确（约 5 MB）
4. 重新构建项目

### Q2: "Invalid crop dimensions"

**原因:** 人脸边界框计算错误

**解决:**
1. 检查图片尺寸是否太小
2. 检查人脸是否太靠近边缘
3. 尝试使用分辨率更高的图片

### Q3: 日志显示成功但 Flutter 收到 0

**原因:** 可能是异步回调问题

**解决:**
1. 查看完整的 logcat 日志
2. 确认 `addOnSuccessListener` 被调用
3. 检查是否有其他异常

---

## 📱 测试步骤

### 1. 准备测试图片

确保你有一张清晰的人脸照片：
- 分辨率: 至少 640x480
- 格式: JPG 或 PNG
- 人脸: 清晰、正面、占比合理

### 2. 放置测试图片

```powershell
# 放到 example assets
Copy-Item "你的图片.jpg" "D:\projects\pluginDemo\facePlugin\face_plugin\example\assets\sample_face.jpg"
```

### 3. 运行并查看日志

```powershell
# 终端 1: 运行应用
flutter run

# 终端 2: 查看日志
adb logcat -s FacePlugin:* flutter:* | Out-String -Stream
```

### 4. 点击测试按钮

在应用中点击 "Test Face Detection" 按钮

### 5. 检查结果

**成功:**
```
I/flutter: Detected 1 face(s)
I/flutter: Extracted 1 feature vector(s)  ← 应该是 1 或更多
I/flutter: Feature vector length: 128
```

**失败:**
```
I/flutter: Detected 1 face(s)
I/flutter: Extracted 0 feature vector(s)  ← 仍然是 0
E/FacePlugin: TFLite interpreter is null!
```

---

## 🔧 进阶调试

### 查看完整日志

```powershell
adb logcat > logcat.txt
```

然后在 `logcat.txt` 中搜索：
- "FacePlugin"
- "TFLite"
- "mobilefacenet"
- "Exception"
- "Error"

### 检查内存

```powershell
adb shell dumpsys meminfo com.example.myFace
```

确认应用有足够内存运行。

### 检查存储空间

```powershell
adb shell df /data/data/com.example.myFace
```

确认有足够空间存储模型。

---

## 💡 快速修复检查清单

- [ ] 模型文件存在于 `android/src/main/assets/mobilefacenet.tflite`
- [ ] 模型文件大小约 5 MB
- [ ] 运行 `flutter clean`
- [ ] 运行 `cd android && ./gradlew clean`
- [ ] 运行 `flutter pub get`
- [ ] 重新运行 `flutter run`
- [ ] 查看 logcat 日志查找错误
- [ ] 测试图片清晰且包含人脸
- [ ] 设备有足够内存

---

## 📞 还是不行？

### 发送这些信息寻求帮助:

1. **模型文件检查结果:**
```powershell
Get-Item "D:\projects\pluginDemo\facePlugin\face_plugin\android\src\main\assets\mobilefacenet.tflite" | Format-List
```

2. **完整的 FacePlugin 日志:**
```powershell
adb logcat -s FacePlugin:* -d
```

3. **Flutter 错误日志:**
```powershell
adb logcat -s flutter:* -d
```

4. **设备信息:**
```powershell
adb shell getprop ro.build.version.release
adb shell getprop ro.product.model
```

---

## 🎯 下一步

立即运行：

```powershell
cd D:\projects\pluginDemo\facePlugin\face_plugin\example
flutter clean
flutter run

# 在另一个终端
adb logcat -s FacePlugin:*
```

然后点击测试按钮，查看详细日志！

