# MobileFaceNet Model for iOS

Please place your `mobilefacenet.tflite` model file in this directory.

## Model Requirements

- **Input**: 112x112x3 (RGB image)
- **Output**: 128-dimensional feature vector
- **Preprocessing**: (pixel - 127.5) / 128.0

## Where to get the model

You can convert a MobileFaceNet model to TFLite format or download a pre-trained one.

Example sources:
- https://github.com/sirius-ai/MobileFaceNet_TF
- https://github.com/deepinsight/insightface

Make sure the model is optimized for mobile inference.

## Installation

1. Place `mobilefacenet.tflite` in this directory
2. Run `pod install` in your iOS project to install dependencies

