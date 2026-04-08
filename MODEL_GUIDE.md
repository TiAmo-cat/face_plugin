# 模型集成说明

## 📦 获取 MobileFaceNet 模型

### 方法 1: 使用预训练模型（推荐）

以下是一些可用的 MobileFaceNet 模型资源：

1. **InsightFace 官方模型**
   - 仓库: https://github.com/deepinsight/insightface
   - 模型质量高，经过大规模数据训练
   - 需要转换为 TFLite 格式

2. **MobileFaceNet-TF**
   - 仓库: https://github.com/sirius-ai/MobileFaceNet_TF
   - 已包含 TFLite 模型
   - 直接可用

3. **ArcFace 相关模型**
   - 多个开源实现提供了 MobileFaceNet 变体

### 方法 2: 自己训练模型

如果您有自己的人脸数据集，可以训练自定义模型：

1. 使用 TensorFlow/PyTorch 训练 MobileFaceNet
2. 导出为 SavedModel 或 ONNX
3. 转换为 TFLite

## 🔧 模型转换为 TFLite

如果您有 TensorFlow SavedModel 格式的模型：

```python
import tensorflow as tf

# 加载模型
model = tf.keras.models.load_model('mobilefacenet_model')

# 转换为 TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# 可选：量化以减小模型大小
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# 转换
tflite_model = converter.convert()

# 保存
with open('mobilefacenet.tflite', 'wb') as f:
    f.write(tflite_model)
```

如果您有 PyTorch 模型：

```python
import torch
import torch.onnx
import onnx
from onnx_tf.backend import prepare
import tensorflow as tf

# 1. PyTorch -> ONNX
model = torch.load('mobilefacenet.pth')
dummy_input = torch.randn(1, 3, 112, 112)
torch.onnx.export(model, dummy_input, 'mobilefacenet.onnx')

# 2. ONNX -> TensorFlow
onnx_model = onnx.load('mobilefacenet.onnx')
tf_rep = prepare(onnx_model)
tf_rep.export_graph('mobilefacenet_tf')

# 3. TensorFlow -> TFLite
converter = tf.lite.TFLiteConverter.from_saved_model('mobilefacenet_tf')
tflite_model = converter.convert()

with open('mobilefacenet.tflite', 'wb') as f:
    f.write(tflite_model)
```

## ✅ 模型验证

验证您的模型是否符合要求：

```python
import tensorflow as tf
import numpy as np

# 加载模型
interpreter = tf.lite.Interpreter(model_path="mobilefacenet.tflite")
interpreter.allocate_tensors()

# 获取输入输出详情
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("输入详情:")
print(f"  形状: {input_details[0]['shape']}")  # 应该是 [1, 112, 112, 3]
print(f"  类型: {input_details[0]['dtype']}")  # 应该是 float32

print("\n输出详情:")
print(f"  形状: {output_details[0]['shape']}")  # 应该是 [1, 128] 或 [1, 512]
print(f"  类型: {output_details[0]['dtype']}")  # 应该是 float32

# 测试推理
test_image = np.random.randn(1, 112, 112, 3).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], test_image)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

print(f"\n输出特征向量维度: {output.shape}")
print(f"前 10 个值: {output[0][:10]}")
```

## 📝 模型要求总结

| 项目 | 要求 |
|------|------|
| 输入形状 | [1, 112, 112, 3] 或 [112, 112, 3] |
| 输入类型 | float32 |
| 输入范围 | 经过归一化：(pixel - 127.5) / 128.0 |
| 输出形状 | [1, 128] 或 [128] |
| 输出类型 | float32 |
| 文件名 | mobilefacenet.tflite |

## 🚀 安装模型

### Android

```bash
# 进入项目目录
cd face_plugin

# 创建 assets 目录（如果不存在）
mkdir -p android/src/main/assets

# 复制模型文件
cp /path/to/your/mobilefacenet.tflite android/src/main/assets/
```

### iOS

```bash
# 进入项目目录
cd face_plugin

# 复制模型文件
cp /path/to/your/mobilefacenet.tflite ios/Classes/

# 更新 Pod 依赖
cd example/ios
pod install
```

## 🔍 故障排除

### 模型加载失败

**Android:**
```
Error: Failed to load model
```

解决方案：
1. 确认文件在 `android/src/main/assets/mobilefacenet.tflite`
2. 清理构建：`flutter clean && flutter pub get`
3. 重新运行应用

**iOS:**
```
Error: Model file not found
```

解决方案：
1. 确认文件在 `ios/Classes/mobilefacenet.tflite`
2. 运行 `pod install`
3. 在 Xcode 中确认文件已添加到项目
4. Clean Build Folder (Cmd+Shift+K)

### 推理结果异常

如果特征向量全是 0 或 NaN：

1. 检查输入图像预处理是否正确
2. 验证模型输入输出格式
3. 确认模型文件没有损坏
4. 查看原生日志输出

### 性能问题

如果推理速度慢：

1. 考虑使用量化模型
2. 在 Android 上启用 GPU 加速（需修改代码）
3. 减小输入图像分辨率
4. 使用更轻量的模型架构

## 📚 参考资源

- [TensorFlow Lite 官方文档](https://www.tensorflow.org/lite)
- [MobileFaceNet 论文](https://arxiv.org/abs/1804.07573)
- [ArcFace 论文](https://arxiv.org/abs/1801.07698)
- [InsightFace 项目](https://github.com/deepinsight/insightface)

