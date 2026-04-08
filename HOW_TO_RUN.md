# 🚀 如何运行 Example 应用

## 📋 前置条件

### 1. 确认模型文件已存在
- ✅ Android: `android/src/main/assets/mobilefacenet.tflite`
- ✅ iOS: `ios/Classes/mobilefacenet.tflite`

### 2. 开发环境
- Flutter SDK (已安装)
- Android Studio 或 Xcode (至少一个)
- 连接的设备或模拟器

---

## 🤖 在 Android 上运行

### 方式 1: 使用 Android 真机

1. **连接 Android 设备**
   - 用 USB 线连接手机
   - 启用"开发者选项"和"USB 调试"

2. **进入 example 目录**
   ```powershell
   cd D:\projects\pluginDemo\facePlugin\face_plugin\example
   ```

3. **清理并获取依赖**
   ```powershell
   flutter clean
   flutter pub get
   ```

4. **运行应用**
   ```powershell
   flutter run
   ```

### 方式 2: 使用 Android 模拟器

1. **启动模拟器**
   - 打开 Android Studio
   - Tools → Device Manager
   - 启动一个模拟器 (推荐 API 30+)

2. **进入目录并运行**
   ```powershell
   cd D:\projects\pluginDemo\facePlugin\face_plugin\example
   flutter pub get
   flutter run
   ```

---

## 🍎 在 iOS 上运行

### 方式 1: 使用 iOS 模拟器

1. **安装 CocoaPods 依赖**
   ```powershell
   cd D:\projects\pluginDemo\facePlugin\face_plugin\example\ios
   pod install
   cd ..
   ```

2. **运行应用**
   ```powershell
   flutter run -d "iPhone 15"
   ```
   
   或者让 Flutter 自动选择：
   ```powershell
   flutter run
   ```

### 方式 2: 使用 iOS 真机

1. **配置签名**
   - 打开 Xcode: `open ios/Runner.xcworkspace`
   - 选择 Runner 项目
   - Signing & Capabilities → Team: 选择你的开发者账号

2. **安装依赖并运行**
   ```powershell
   cd ios
   pod install
   cd ..
   flutter run -d "你的iPhone名称"
   ```

---

## 📱 快速命令汇总

### 完整启动流程 (推荐)

```powershell
# 1. 进入 example 目录
cd D:\projects\pluginDemo\facePlugin\face_plugin\example

# 2. 清理旧构建
flutter clean

# 3. 获取依赖
flutter pub get

# 4. (iOS only) 安装 pods
cd ios
pod install
cd ..

# 5. 查看可用设备
flutter devices

# 6. 运行应用
flutter run
```

### 指定设备运行

```powershell
# Android 真机/模拟器
flutter run -d android

# iOS 模拟器
flutter run -d "iPhone 15 Pro"

# 查看所有设备
flutter devices
```

### Release 模式运行 (更快)

```powershell
flutter run --release
```

---

## ✅ 预期结果

### 应用启动后

1. **界面显示**
   ```
   Face Detection & Feature Extraction
   
   This plugin detects faces and extracts 
   128-dimensional feature vectors using MobileFaceNet.
   
   [Test Face Detection] 按钮
   ```

2. **点击按钮**
   - 如果有 `assets/sample_face.jpg`：显示检测结果
   - 如果没有：显示错误提示

3. **成功输出示例**
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
     First 10 values: 0.1234, -0.5678, ...
   ```

---

## 🐛 常见问题解决

### 问题 1: "No devices found"

**解决方案:**
```powershell
# 检查设备连接
flutter devices

# Android: 确保 USB 调试已启用
adb devices

# iOS: 确保 Xcode 命令行工具已安装
xcode-select --install
```

### 问题 2: "Unable to load asset"

**原因:** 缺少 sample_face.jpg

**解决方案:**
1. 准备一张人脸图片
2. 复制到 `example/assets/sample_face.jpg`
3. 或者修改代码使用 image_picker

### 问题 3: Android 编译失败

**解决方案:**
```powershell
cd example/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
flutter run
```

### 问题 4: iOS Pod install 失败

**解决方案:**
```powershell
cd example/ios
pod deintegrate
pod install --repo-update
cd ..
```

### 问题 5: "Model file not found"

**检查:**
```powershell
# Android 模型
Test-Path "D:\projects\pluginDemo\facePlugin\face_plugin\android\src\main\assets\mobilefacenet.tflite"

# iOS 模型
Test-Path "D:\projects\pluginDemo\facePlugin\face_plugin\ios\Classes\mobilefacenet.tflite"
```

如果返回 False，需要重新放置模型文件。

---

## 📊 验证功能

### 1. 检查日志

**Android:**
```powershell
# 在另一个终端窗口
adb logcat | Select-String "face|Face|ML Kit|TFLite"
```

**iOS:**
在 Xcode 中查看控制台输出

### 2. 预期日志

**Android 成功:**
```
I/flutter: Detected 1 face(s)
I/flutter: Extracted 1 feature vector(s)
I/flutter: Feature length: 128
```

**iOS 成功:**
```
Model loaded successfully from plugin bundle
Face detection complete
Feature extraction complete
```

### 3. 性能测试

添加测试图片后，记录：
- 人脸检测时间: 应该 < 100ms
- 特征提取时间: 应该 < 150ms
- 总处理时间: 应该 < 300ms

---

## 🎯 下一步

### 添加真实图片测试

1. **准备测试图片**
   - 找一张清晰的人脸照片
   - 重命名为 `sample_face.jpg`

2. **放置到 assets**
   ```powershell
   # 确保目录存在
   New-Item -ItemType Directory -Force -Path "D:\projects\pluginDemo\facePlugin\face_plugin\example\assets"
   
   # 复制图片
   Copy-Item "你的图片路径.jpg" "D:\projects\pluginDemo\facePlugin\face_plugin\example\assets\sample_face.jpg"
   ```

3. **重新运行**
   ```powershell
   flutter run
   ```

### 集成 Image Picker (可选)

如果想从相册选择图片：

```powershell
# 添加依赖
cd example
flutter pub add image_picker
```

然后修改 main.dart 使用 ImagePicker。

---

## 💡 提示

- **首次运行**: 可能需要较长时间下载依赖
- **模拟器性能**: 真机运行会更快
- **Release 模式**: 使用 `--release` 获得最佳性能
- **热重载**: 修改 Dart 代码后按 `r` 快速重载

---

**准备好了吗？开始运行！** 🚀

```powershell
cd D:\projects\pluginDemo\facePlugin\face_plugin\example
flutter run
```

