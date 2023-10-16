//
//  ImageModel.swift
//  uppgift4
//
//  Created by Anton Smedberg on 2023-10-16.
//

import Vision
import Foundation
import UIKit

class ImageModel {
    enum ImageModelError: Error {
        case modelInitializationFailed
        case imageLoadingFailed
        case imageConversionFailed
        case classificationFailed(String)
    }

    // Klassificerar en bild baserat på dess namn
    func classifyImage(named imageName: String) throws -> String {
        // Försöker initialisera Core ML-modellen
        guard let imageClassifierWrapper = try? MobileNetV2(configuration: MLModelConfiguration()) else {
            throw ImageModelError.modelInitializationFailed
        }

        // Laddar bilden
        guard let theimage = UIImage(named: imageName) else {
            throw ImageModelError.imageLoadingFailed
        }

        // Konverterar bilden till en buffer
        guard let theimageBuffer = buffer(from: theimage) else {
            throw ImageModelError.imageConversionFailed
        }

        do {
            // Försöker klassificera bilden med hjälp av modellen
            let output = try imageClassifierWrapper.prediction(image: theimageBuffer)
            let confidencePercentage = Int((output.classLabelProbs[output.classLabel]! * 100).rounded())
            let animalName = output.classLabel.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? output.classLabel
            return "\(animalName) (\(confidencePercentage)%)"
        } catch {
            throw ImageModelError.classificationFailed(error.localizedDescription)
        }
    }

    // Konverterar en UIImage till en CVPixelBuffer
    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        // Ritar bilden i CGContext
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
