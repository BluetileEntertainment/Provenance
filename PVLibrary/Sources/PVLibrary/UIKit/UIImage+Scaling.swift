//
//  UIImage+Scaling.swift
//  Provenance
//
//  Created by Joseph Mattiello on 01/11/2023.
//  Copyright (c) 2023 Joseph Mattiello. All rights reserved.
//

import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit

public extension UIImage {
    #if !os(watchOS)
    func scalePreservingAspectRatio(width: Int, height: Int) -> UIImage {
        let widthRatio = CGFloat(width) / size.width
        let heightRatio = CGFloat(height) / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: format
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }
    #endif

    func scaledImage(withMaxResolution maxResolution: Int) -> UIImage? {
        guard let imgRef = cgImage else { return nil }
        let width = imgRef.width
        let height = imgRef.height

        var tranform: CGAffineTransform = .identity
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)

        if width > maxResolution || height > maxResolution {
            let ratio = Double(width) / Double(height)
            if ratio > 1 {
                bounds.size.width = Double(maxResolution)
                bounds.size.height = bounds.size.width / ratio
            } else {
                bounds.size.height = Double(maxResolution)
                bounds.size.width = bounds.size.height / ratio
            }
        }

        let scaleRatio: Double = bounds.size.width / Double(width)
        let imageSize = CGSize(width: width, height: height)

        var boundHeight: Double = 0

        let orientation = imageOrientation
        switch orientation {
        case .up:
            tranform = .identity
        case .upMirrored:
            tranform = tranform
                .translatedBy(x: imageSize.width, y: 0.0)
                .scaledBy(x: -1.0, y: 1.0)
        case .down:
            tranform = tranform
                .translatedBy(x: imageSize.width, y: imageSize.height)
                .rotated(by: Double.pi)
        case .downMirrored:
            tranform = tranform
                .translatedBy(x: 0, y: imageSize.height)
                .scaledBy(x: 1.0, y: -1.0)
        case .leftMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            tranform = tranform
                .translatedBy(x: imageSize.height, y: imageSize.width)
                .scaledBy(x: -1.0, y: 1.0)
                .rotated(by: 3.0 * Double.pi / 2.0)
        case .left:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            tranform = tranform
                .translatedBy(x: 0.0, y: imageSize.width)
                .rotated(by: 3.0 * Double.pi / 2.0)
        case .rightMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            tranform = tranform
                .scaledBy(x: -1.0, y: 1.0)
                .rotated(by: Double.pi / 2.0)
        case .right:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            tranform = tranform
                .translatedBy(x: imageSize.height, y: 0.0)
                .rotated(by: 3.0 * Double.pi / 2.0)
        @unknown default:
            fatalError()
        }

        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        switch orientation {
        case .left, .right:
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: Double(-height), y: 0)
        default:
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: Double(-height))
        }
        context.concatenate(tranform)

        context.draw(imgRef, in: .init(x: 0, y: 0, width: width, height: height))
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageCopy
    }
}
#else
import AppKit
public typealias UIImage = NSImage
#endif
