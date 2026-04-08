# 部署检查清单

在使用或发布 face_plugin 之前，请确保完成以下步骤：

## ✅ 模型文件准备

- [ ] 已获取或训练 MobileFaceNet TFLite 模型
- [ ] 模型输入格式正确：112x112x3 (RGB)
- [ ] 模型输出格式正确：128 维特征向量
- [ ] 已验证模型可以正常推理

### Android
- [ ] 将 `mobilefacenet.tflite` 复制到 `android/src/main/assets/`
- [ ] 文件大小合理（通常 1-5 MB）
- [ ] 文件权限正确

### iOS
- [ ] 将 `mobilefacenet.tflite` 复制到 `ios/Classes/`
- [ ] 文件大小合理（通常 1-5 MB）
- [ ] 文件权限正确

## ✅ 依赖安装

### Flutter
- [ ] 运行 `flutter pub get`
- [ ] 无依赖冲突
- [ ] 所有依赖版本兼容

### Android
- [ ] TensorFlow Lite 2.14.0 已添加到 build.gradle
- [ ] Gradle 同步成功
- [ ] 无编译错误

### iOS
- [ ] TensorFlow Lite Swift 依赖已添加到 podspec
- [ ] 运行 `cd example/ios && pod install`
- [ ] Pod 安装成功
- [ ] 无链接错误

## ✅ 代码完整性

### Dart 层
- [ ] `lib/face_plugin.dart` - 主 API 实现
- [ ] `lib/face_plugin_platform_interface.dart` - Platform Interface
- [ ] `lib/face_plugin_method_channel.dart` - Method Channel
- [ ] Face 模型类完整
- [ ] 无编译错误
- [ ] 无 lint 警告

### Android 原生
- [ ] `FacePlugin.java` 完整实现
- [ ] 包名正确：`com.example.face_plugin`
- [ ] Method Channel 名称匹配：`face_plugin`
- [ ] TFLite 初始化代码
- [ ] 图像预处理实现
- [ ] 错误处理完善

### iOS 原生
- [ ] `FacePlugin.swift` 完整实现
- [ ] Method Channel 名称匹配：`face_plugin`
- [ ] TFLite 初始化代码
- [ ] 图像预处理实现
- [ ] 错误处理完善

## ✅ 功能测试

### 基础功能
- [ ] detectFaces 可以正常调用
- [ ] extractFeatures 可以正常调用
- [ ] 返回数据格式正确
- [ ] 无运行时错误

### Android 测试
- [ ] 在真机上测试通过
- [ ] 在模拟器上测试通过
- [ ] 模型加载成功
- [ ] 特征提取正确
- [ ] 性能可接受

### iOS 测试
- [ ] 在真机上测试通过
- [ ] 在模拟器上测试通过
- [ ] 模型加载成功
- [ ] 特征提取正确
- [ ] 性能可接受

### 边界情况
- [ ] 测试空图片
- [ ] 测试无人脸图片
- [ ] 测试多人脸图片
- [ ] 测试模糊图片
- [ ] 测试大图片（>5MB）
- [ ] 测试小图片（<100KB）
- [ ] 测试不同格式（JPG, PNG, etc.）

## ✅ 性能验证

- [ ] 特征提取时间 < 200ms（中端设备）
- [ ] 内存占用合理（< 50MB）
- [ ] 无内存泄漏
- [ ] 批量处理稳定
- [ ] 长时间运行稳定

## ✅ 文档完整性

- [ ] README.md - 主文档完整
- [ ] QUICK_START.md - 快速开始指南
- [ ] MODEL_GUIDE.md - 模型集成说明
- [ ] EXAMPLES.md - 代码示例
- [ ] CHANGELOG.md - 更新日志
- [ ] PROJECT_SUMMARY.md - 项目总结
- [ ] LICENSE - 许可证文件
- [ ] 各目录 README 说明文件

### API 文档
- [ ] 所有公开方法有注释
- [ ] 参数说明清晰
- [ ] 返回值说明清晰
- [ ] 使用示例完整

## ✅ 示例应用

- [ ] example/lib/main.dart 可以运行
- [ ] UI 显示正常
- [ ] 功能演示完整
- [ ] 无崩溃

## ✅ 错误处理

- [ ] 模型文件缺失时有错误提示
- [ ] 图片解码失败时有错误提示
- [ ] 推理失败时有错误提示
- [ ] 所有异常都有捕获
- [ ] 错误消息清晰有用

## ✅ 安全性

- [ ] 无硬编码密钥
- [ ] 无敏感信息泄露
- [ ] 输入验证完善
- [ ] 权限请求合理

## ✅ 兼容性

### Flutter 版本
- [ ] Flutter >=3.3.0 测试通过
- [ ] Dart ^3.6.0 兼容

### Android 版本
- [ ] API 21 (Android 5.0) 测试
- [ ] API 30+ (Android 11+) 测试
- [ ] 各主流设备测试

### iOS 版本
- [ ] iOS 12.0 测试
- [ ] iOS 15+ 测试
- [ ] iPhone 和 iPad 测试

## ✅ 生产环境准备

### 性能优化
- [ ] 考虑使用量化模型
- [ ] 图片预处理优化
- [ ] 内存管理优化

### 功能增强
- [ ] 考虑集成专业人脸检测（如需）
- [ ] 添加人脸对齐（如需）
- [ ] 添加活体检测（如需）

### 监控和日志
- [ ] 添加适当的日志
- [ ] 添加性能监控
- [ ] 添加错误上报

## ✅ 发布准备

### 版本管理
- [ ] pubspec.yaml 版本号正确
- [ ] CHANGELOG.md 已更新
- [ ] Git 标签已创建

### 代码质量
- [ ] 代码格式化：`flutter format .`
- [ ] 代码分析：`flutter analyze`
- [ ] 无警告和错误

### 文档
- [ ] 所有文档已审核
- [ ] 示例代码已测试
- [ ] 链接都有效

## 🎯 快速检查命令

```bash
# 1. 格式化代码
flutter format .

# 2. 分析代码
flutter analyze

# 3. 运行测试（如有）
flutter test

# 4. 清理并重新获取依赖
flutter clean
flutter pub get

# 5. Android 构建
cd example
flutter build apk --release

# 6. iOS 构建
flutter build ios --release

# 7. 运行示例
flutter run
```

## 📋 发布前最终检查

- [ ] 所有上述检查项都已完成
- [ ] 在至少 2 个 Android 设备上测试
- [ ] 在至少 2 个 iOS 设备上测试
- [ ] 文档无拼写错误
- [ ] 代码无 TODO 标记（或已处理）
- [ ] 准备好支持计划

## ✨ 完成！

如果所有检查项都已完成，您的 face_plugin 就可以使用或发布了！

记住：
- 定期更新依赖
- 收集用户反馈
- 持续改进性能
- 保持文档更新

