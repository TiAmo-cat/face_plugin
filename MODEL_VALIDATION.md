# 模型验证脚本

本文件提供了验证 MobileFaceNet 模型的 Python 脚本。

## 验证模型文件

```python
import tensorflow as tf
import numpy as np

def validate_mobilefacenet_model(model_path):
    """验证 MobileFaceNet TFLite 模型"""
    
    print(f"正在验证模型: {model_path}")
    print("=" * 60)
    
    try:
        # 加载模型
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        
        # 获取输入输出详情
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print("\n✅ 模型加载成功\n")
        
        # 显示输入信息
        print("📥 输入详情:")
        print(f"  - 形状: {input_details[0]['shape']}")
        print(f"  - 类型: {input_details[0]['dtype']}")
        print(f"  - 索引: {input_details[0]['index']}")
        
        # 显示输出信息
        print("\n📤 输出详情:")
        print(f"  - 形状: {output_details[0]['shape']}")
        print(f"  - 类型: {output_details[0]['dtype']}")
        print(f"  - 索引: {output_details[0]['index']}")
        
        # 验证输入形状
        input_shape = input_details[0]['shape']
        if input_shape[1] == 112 and input_shape[2] == 112 and input_shape[3] == 3:
            print("\n✅ 输入形状正确: [1, 112, 112, 3]")
        else:
            print(f"\n⚠️ 警告: 输入形状不符合预期，当前为 {input_shape}")
        
        # 验证输出形状
        output_shape = output_details[0]['shape']
        feature_dim = output_shape[1] if len(output_shape) > 1 else output_shape[0]
        
        if feature_dim == 128:
            print(f"✅ 输出维度正确: {feature_dim}")
        elif feature_dim == 512:
            print(f"⚠️ 输出维度为 {feature_dim}，需要在代码中调整 FEATURE_DIM")
        else:
            print(f"⚠️ 输出维度 {feature_dim} 不符合常见值 (128 或 512)")
        
        # 测试推理
        print("\n🧪 测试推理...")
        test_input = np.random.randn(1, 112, 112, 3).astype(np.float32)
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"  - 输出形状: {output.shape}")
        print(f"  - 输出类型: {output.dtype}")
        print(f"  - 前 10 个值: {output[0][:10]}")
        
        # 检查输出是否合理
        if np.isnan(output).any():
            print("\n❌ 错误: 输出包含 NaN 值")
            return False
        elif np.all(output == 0):
            print("\n❌ 错误: 输出全为 0")
            return False
        else:
            print("\n✅ 推理测试成功")
        
        print("\n" + "=" * 60)
        print("✅ 模型验证通过！可以正常使用。")
        print("=" * 60)
        
        return True
        
    except Exception as e:
        print(f"\n❌ 模型验证失败: {e}")
        return False

# 使用示例
if __name__ == "__main__":
    # Android 模型
    android_model = "android/src/main/assets/mobilefacenet.tflite"
    print("验证 Android 模型:")
    validate_mobilefacenet_model(android_model)
    
    print("\n\n")
    
    # iOS 模型
    ios_model = "ios/Classes/mobilefacenet.tflite"
    print("验证 iOS 模型:")
    validate_mobilefacenet_model(ios_model)
```

## 运行验证

```bash
# 确保已安装 TensorFlow
pip install tensorflow

# 运行验证脚本
python validate_model.py
```

## 预期输出

正常的模型应该输出类似以下信息：

```
正在验证模型: mobilefacenet.tflite
============================================================

✅ 模型加载成功

📥 输入详情:
  - 形状: [  1 112 112   3]
  - 类型: <class 'numpy.float32'>
  - 索引: 0

📤 输出详情:
  - 形状: [  1 128]
  - 类型: <class 'numpy.float32'>
  - 索引: 156

✅ 输入形状正确: [1, 112, 112, 3]
✅ 输出维度正确: 128

🧪 测试推理...
  - 输出形状: (1, 128)
  - 输出类型: float32
  - 前 10 个值: [-0.5234 0.8912 -0.1234 ...]

✅ 推理测试成功

============================================================
✅ 模型验证通过！可以正常使用。
============================================================
```

## 常见问题

### 问题1: 输出全为 0 或 NaN
- **原因**: 模型文件损坏或预处理不正确
- **解决**: 重新下载模型文件，检查预处理代码

### 问题2: 输入/输出形状不匹配
- **原因**: 模型版本不同
- **解决**: 在插件代码中调整 INPUT_SIZE 和 FEATURE_DIM 常量

### 问题3: 模型加载失败
- **原因**: 文件损坏或不是有效的 TFLite 文件
- **解决**: 重新转换或下载模型

## 模型大小验证

正常的 MobileFaceNet 模型大小应该在：
- **未量化**: 4-6 MB
- **量化后**: 1-2 MB

当前模型文件大小约 5.2 MB，属于正常范围。

