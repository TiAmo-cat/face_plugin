import Flutter
import UIKit
import TensorFlowLite
import Vision

public class FacePlugin: NSObject, FlutterPlugin {
    private var interpreter: Interpreter?

    private let inputSize = 112
    private var featureDim = 128  // Will be updated after loading model
    private let imageMean: Float = 127.5
    private let imageStd: Float = 128.0

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "face_plugin", binaryMessenger: registrar.messenger())
        let instance = FacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Initialize TFLite model
        instance.loadModel(registrar: registrar)
    }

    private func loadModel(registrar: FlutterPluginRegistrar) {
        // Try to load from plugin bundle first
        let bundle = Bundle(for: type(of: self))

        if let modelPath = bundle.path(forResource: "mobilefacenet", ofType: "tflite") {
            do {
                interpreter = try Interpreter(modelPath: modelPath)
                try interpreter?.allocateTensors()

                // Auto-detect feature dimension from model output
                if let outputTensor = try? interpreter?.output(at: 0) {
                    let shape = outputTensor.shape.dimensions
                    if shape.count >= 2 {
                        featureDim = shape[1]
                        print("Model loaded successfully from plugin bundle")
                        print("Model output shape: \(shape)")
                        print("Feature dimension: \(featureDim)")
                    }
                }
                return
            } catch {
                print("Failed to load model from plugin bundle: \(error)")
            }
        }

        // Fallback: try main bundle
        if let modelPath = Bundle.main.path(forResource: "mobilefacenet", ofType: "tflite") {
            do {
                interpreter = try Interpreter(modelPath: modelPath)
                try interpreter?.allocateTensors()

                // Auto-detect feature dimension from model output
                if let outputTensor = try? interpreter?.output(at: 0) {
                    let shape = outputTensor.shape.dimensions
                    if shape.count >= 2 {
                        featureDim = shape[1]
                        print("Model loaded successfully from main bundle")
                        print("Model output shape: \(shape)")
                        print("Feature dimension: \(featureDim)")
                    }
                }
                return
            } catch {
                print("Failed to load model from main bundle: \(error)")
            }
        }

        print("ERROR: Model file 'mobilefacenet.tflite' not found in any bundle")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detectFaces":
            detectFaces(call: call, result: result)
        case "extractFeatures":
            extractFeatures(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func detectFaces(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageData = args["imageBytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "imageBytes is required", details: nil))
            return
        }

        guard let image = UIImage(data: imageData.data) else {
            result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image", details: nil))
            return
        }

        performFaceDetectionWithVision(image: image) { faces in
            result(faces)
        }
    }

    private func extractFeatures(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageData = args["imageBytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "imageBytes is required", details: nil))
            return
        }

        guard let image = UIImage(data: imageData.data) else {
            result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode image", details: nil))
            return
        }

        performFaceDetectionWithVision(image: image) { facesData in
            let features = self.extractFeaturesFromFaces(image: image, facesData: facesData)
            result(features)
        }
    }

    private func performFaceDetectionWithVision(image: UIImage, completion: @escaping ([[String: Any]]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Face detection error: \(error)")
                completion([])
                return
            }

            guard let observations = request.results as? [VNFaceObservation] else {
                completion([])
                return
            }

            let faces = self.convertVisionFacesToMap(observations: observations,
                                                     imageWidth: image.size.width,
                                                     imageHeight: image.size.height)
            completion(faces)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform face detection: \(error)")
            completion([])
        }
    }

    private func convertVisionFacesToMap(observations: [VNFaceObservation], imageWidth: CGFloat, imageHeight: CGFloat) -> [[String: Any]] {
        var faces: [[String: Any]] = []

        for observation in observations {
            var face: [String: Any] = [:]

            // Convert normalized coordinates to pixel coordinates
            let boundingBox = observation.boundingBox
            let x = boundingBox.origin.x * imageWidth
            let y = (1 - boundingBox.origin.y - boundingBox.height) * imageHeight // Flip Y axis
            let width = boundingBox.width * imageWidth
            let height = boundingBox.height * imageHeight

            face["faceX"] = x
            face["faceY"] = y
            face["bboxW"] = width
            face["bboxH"] = height

            // Extract landmarks if available
            if let landmarks = observation.landmarks {
                // Right eye (from image perspective)
                if let rightEye = landmarks.rightEye {
                    let point = rightEye.normalizedPoints.first ?? CGPoint.zero
                    face["reyeX"] = point.x * imageWidth
                    face["reyeY"] = (1 - point.y) * imageHeight
                } else {
                    face["reyeX"] = x + width * 0.3
                    face["reyeY"] = y + height * 0.35
                }

                // Left eye (from image perspective)
                if let leftEye = landmarks.leftEye {
                    let point = leftEye.normalizedPoints.first ?? CGPoint.zero
                    face["leyeX"] = point.x * imageWidth
                    face["leyeY"] = (1 - point.y) * imageHeight
                } else {
                    face["leyeX"] = x + width * 0.7
                    face["leyeY"] = y + height * 0.35
                }

                // Nose
                if let nose = landmarks.nose {
                    let point = nose.normalizedPoints.first ?? CGPoint.zero
                    face["noseX"] = point.x * imageWidth
                    face["noseY"] = (1 - point.y) * imageHeight
                } else {
                    face["noseX"] = x + width * 0.5
                    face["noseY"] = y + height * 0.5
                }

                // Mouth
                if let outerLips = landmarks.outerLips {
                    let points = outerLips.normalizedPoints
                    if points.count >= 2 {
                        // Right mouth corner
                        let rightPoint = points[0]
                        face["rmouthX"] = rightPoint.x * imageWidth
                        face["rmouthY"] = (1 - rightPoint.y) * imageHeight

                        // Left mouth corner
                        let leftPoint = points[points.count / 2]
                        face["lmouthX"] = leftPoint.x * imageWidth
                        face["lmouthY"] = (1 - leftPoint.y) * imageHeight
                    } else {
                        face["rmouthX"] = x + width * 0.35
                        face["rmouthY"] = y + height * 0.75
                        face["lmouthX"] = x + width * 0.65
                        face["lmouthY"] = y + height * 0.75
                    }
                } else {
                    face["rmouthX"] = x + width * 0.35
                    face["rmouthY"] = y + height * 0.75
                    face["lmouthX"] = x + width * 0.65
                    face["lmouthY"] = y + height * 0.75
                }
            } else {
                // Default landmark positions
                face["reyeX"] = x + width * 0.3
                face["reyeY"] = y + height * 0.35
                face["leyeX"] = x + width * 0.7
                face["leyeY"] = y + height * 0.35
                face["noseX"] = x + width * 0.5
                face["noseY"] = y + height * 0.5
                face["rmouthX"] = x + width * 0.35
                face["rmouthY"] = y + height * 0.75
                face["lmouthX"] = x + width * 0.65
                face["lmouthY"] = y + height * 0.75
            }

            face["width"] = imageWidth
            face["height"] = imageHeight
            face["faceScore"] = observation.confidence
            face["faceTv"] = 1
            face["clsId"] = 0

            faces.append(face)
        }

        return faces
    }

    private func extractFeaturesFromFaces(image: UIImage, facesData: [[String: Any]]) -> [[Double]] {
        var features: [[Double]] = []

        guard let interpreter = interpreter else {
            print("Interpreter not initialized")
            return features
        }

        guard let cgImage = image.cgImage else {
            return features
        }

        for faceData in facesData {
            guard let faceX = faceData["faceX"] as? Double,
                  let faceY = faceData["faceY"] as? Double,
                  let bboxW = faceData["bboxW"] as? Double,
                  let bboxH = faceData["bboxH"] as? Double else {
                continue
            }

            // Expand bounding box slightly
            let padding = max(bboxW, bboxH) * 0.2
            let left = max(0, Int(faceX - padding))
            let top = max(0, Int(faceY - padding))
            let right = min(cgImage.width, Int(faceX + bboxW + padding))
            let bottom = min(cgImage.height, Int(faceY + bboxH + padding))

            let width = right - left
            let height = bottom - top

            if width <= 0 || height <= 0 {
                continue
            }

            // Crop face region
            let cropRect = CGRect(x: left, y: top, width: width, height: height)
            guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
                continue
            }

            let croppedImage = UIImage(cgImage: croppedCGImage)

            // Resize and extract features
            guard let resizedImage = croppedImage.resized(to: CGSize(width: inputSize, height: inputSize)),
                  let inputData = preprocessImage(resizedImage) else {
                continue
            }

            do {
                // Copy input data to interpreter
                try interpreter.copy(inputData, toInputAt: 0)

                // Run inference
                try interpreter.invoke()

                // Get output
                let outputTensor = try interpreter.output(at: 0)
                let outputData = outputTensor.data

                // Convert to Float array
                var feature: [Double] = []
                let floatArray = outputData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
                    let buffer = pointer.bindMemory(to: Float.self)
                    return Array(buffer)
                }

                for i in 0..<min(featureDim, floatArray.count) {
                    feature.append(Double(floatArray[i]))
                }

                features.append(feature)

            } catch {
                print("Failed to run inference for face: \(error)")
            }
        }

        return features
    }

    private func preprocessImage(_ image: UIImage) -> Data? {
        guard let cgImage = image.cgImage else { return nil }

        let width = inputSize
        let height = inputSize
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelValues = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelValues,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Convert to normalized float values
        var floatValues = [Float](repeating: 0, count: width * height * 3)

        for i in 0..<(width * height) {
            let r = Float(pixelValues[i * 4])
            let g = Float(pixelValues[i * 4 + 1])
            let b = Float(pixelValues[i * 4 + 2])

            floatValues[i * 3] = (r - imageMean) / imageStd
            floatValues[i * 3 + 1] = (g - imageMean) / imageStd
            floatValues[i * 3 + 2] = (b - imageMean) / imageStd
        }

        return Data(bytes: floatValues, count: floatValues.count * MemoryLayout<Float>.size)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
