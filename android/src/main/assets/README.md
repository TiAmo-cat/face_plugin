# MobileFaceNet Model

The `mobilefacenet.tflite` model file is bundled with the plugin.

## Model Specifications

- **Input**: 112x112x3 (RGB image)
- **Output**: 128 or 192-dimensional feature vector (auto-detected from model)
- **Preprocessing**: (pixel - 127.5) / 128.0

## Replacing the Model

You can replace this with another MobileFaceNet-compatible TFLite model.

Example sources:
- https://github.com/sirius-ai/MobileFaceNet_TF
- https://github.com/deepinsight/insightface

Make sure the model is optimized for mobile inference.

