//
//  UIImage+Extension.swift
//  EZSwiftKit
//
//  Created by WeiXinbing on 2020/4/15.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIImage {
    
    // 添加滤镜
    func addFilter(name: String) -> UIImage {
        //将UIImage转换成CIImage
        let ciImage = CIImage.init(image: self)
        // 创建滤镜
        let filter = CIFilter.init(name: name, parameters: [kCIInputImageKey: ciImage!])
        filter?.setDefaults()
        
        // 创建基于GPU的CIContext对象
        let context = CIContext.init(options: nil)
        // 渲染并输出CIImage
        let outputImage = (filter?.outputImage)!
        // 创建CGImage句柄
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        
        return UIImage.init(cgImage: cgImage!)
    }
    
    
    /// 获取旋转后的图片
    /// - Parameter degrees: 角度（0~360）
    func getRotatedImage(degrees: CGFloat) -> UIImage? {
        let angle = degrees * .pi / 180
        return getRotatedImage(angle: angle)
    }
    /// 得到旋转后的图片
    /// - Parameter angle: 旋转弧度
    func getRotatedImage(angle: CGFloat) -> UIImage? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.transform = CGAffineTransform.init(rotationAngle: angle)
        let rotatedSize = view.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
        context?.rotate(by: angle)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage!, in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img
    }
    
    
    /// 旋转图片
    /// - Parameter orient: 指定方向
    func rotate(orient: Orientation) -> UIImage? {
        
        var rect: CGRect = .zero
        var copy: UIImage? = nil
        var context: CGContext? = nil
        var tran: CGAffineTransform = .identity
        
        rect.size.width = CGFloat(cgImage!.width)
        rect.size.height = CGFloat(cgImage!.height)
        
        switch orient {
        case .up:
            return self
        case .down:
            tran = CGAffineTransform(translationX: rect.width, y: 0)
            tran = tran.rotated(by: .pi)
        case .left:
            tran = CGAffineTransform(translationX: 0, y: rect.width)
            tran = tran.rotated(by: 3/2 * .pi)
        case .right:
            tran = CGAffineTransform(translationX: rect.height, y: 0)
            tran = tran.rotated(by: 1/2 * .pi)
            
        case .upMirrored:
            tran = CGAffineTransform(translationX: rect.width, y: 0)
            tran = tran.scaledBy(x: -1, y: 1)
        case .downMirrored:
            tran = CGAffineTransform(translationX: 0, y: rect.height)
            tran = tran.scaledBy(x: 1, y: -1)
        case .leftMirrored:
            tran = tran.scaledBy(x: -1, y: 1)
            tran = tran.rotated(by: 1/2 * .pi)
        case .rightMirrored:
            tran = CGAffineTransform(translationX: rect.height, y: rect.width)
            tran = tran.scaledBy(x: -1, y: 1)
            tran = tran.rotated(by: 3/2 * .pi)
        default:
            return self
        }
        
        switch orient {
        case .left, .right, .leftMirrored, .rightMirrored:
            let size = CGSize(width: rect.height, height: rect.width)
            UIGraphicsBeginImageContext(size)
            context = UIGraphicsGetCurrentContext()
            context?.scaleBy(x: -1, y: 1)
            context?.translateBy(x: -rect.height, y: 0)
            
        default:
            UIGraphicsBeginImageContext(rect.size)
            context = UIGraphicsGetCurrentContext()
            context?.scaleBy(x: 1, y: -1)
            context?.translateBy(x: 0, y: -rect.height)
        }
        
        context?.concatenate(tran)
        context?.draw(cgImage!, in: rect)
        
        copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copy
    }
}

// MARK: - Properties
public extension UIImage {

    /// SwifterSwift: Size in bytes of UIImage
    var bytesSize: Int {
        return jpegData(compressionQuality: 1)?.count ?? 0
    }

    /// SwifterSwift: Size in kilo bytes of UIImage
    var kilobytesSize: Int {
        return (jpegData(compressionQuality: 1)?.count ?? 0) / 1024
    }

    /// SwifterSwift: UIImage with .alwaysOriginal rendering mode.
    var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }

    /// SwifterSwift: UIImage with .alwaysTemplate rendering mode.
    var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }

}

// MARK: - Methods
public extension UIImage {

    /// SwifterSwift: Compressed UIImage from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional UIImage (if applicable).
    func compressed(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }

    /// SwifterSwift: Compressed UIImage data from original UIImage.
    ///
    /// - Parameter quality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality), (default is 0.5).
    /// - Returns: optional Data (if applicable).
    func compressedData(quality: CGFloat = 0.5) -> Data? {
        return jpegData(compressionQuality: quality)
    }

    /// SwifterSwift: UIImage Cropped to CGRect.
    ///
    /// - Parameter rect: CGRect to crop UIImage to.
    /// - Returns: cropped UIImage
    func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.width <= size.width && rect.size.height <= size.height else { return self }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let image = cgImage?.cropping(to: scaledRect) else { return self }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }

    /// SwifterSwift: UIImage scaled to height with respect to aspect ratio.
    ///
    /// - Parameters:
    ///   - toHeight: new height.
    ///   - opaque: flag indicating whether the bitmap is opaque.
    /// - Returns: optional scaled UIImage (if applicable).
    func scaled(toHeight: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toHeight / size.height
        let newWidth = size.width * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: toHeight), opaque, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: toHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: UIImage scaled to width with respect to aspect ratio.
    ///
    /// - Parameters:
    ///   - toWidth: new width.
    ///   - opaque: flag indicating whether the bitmap is opaque.
    /// - Returns: optional scaled UIImage (if applicable).
    func scaled(toWidth: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: toWidth, height: newHeight), opaque, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: toWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: Creates a copy of the receiver rotated by the given angle.
    ///
    ///     // Rotate the image by 180°
    ///     image.rotated(by: Measurement(value: 180, unit: .degrees))
    ///
    /// - Parameter angle: The angle measurement by which to rotate the image.
    /// - Returns: A new image rotated by the given angle.
    @available(tvOS 10.0, watchOS 3.0, *)
    func rotated(by angle: Measurement<UnitAngle>) -> UIImage? {
        let radians = CGFloat(angle.converted(to: .radians).value)

        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())

        UIGraphicsBeginImageContext(roundedDestRect.size)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }

        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)

        draw(in: CGRect(origin: CGPoint(x: -size.width / 2,
                                        y: -size.height / 2),
                        size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: Creates a copy of the receiver rotated by the given angle (in radians).
    ///
    ///     // Rotate the image by 180°
    ///     image.rotated(by: .pi)
    ///
    /// - Parameter radians: The angle, in radians, by which to rotate the image.
    /// - Returns: A new image rotated by the given angle.
    func rotated(by radians: CGFloat) -> UIImage? {
        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())

        UIGraphicsBeginImageContext(roundedDestRect.size)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }

        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)

        draw(in: CGRect(origin: CGPoint(x: -size.width / 2,
                                        y: -size.height / 2),
                        size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: UIImage filled with color
    ///
    /// - Parameter color: color to fill image with.
    /// - Returns: UIImage filled with given color.
    func filled(withColor color: UIColor) -> UIImage {

        #if !os(watchOS)
        if #available(tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { context in
                color.setFill()
                context.fill(CGRect(origin: .zero, size: size))
            }
        }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext() else { return self }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let mask = cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: UIImage tinted with color
    ///
    /// - Parameters:
    ///   - color: color to tint image with.
    ///   - blendMode: how to blend the tint
    /// - Returns: UIImage tinted with given color.
    func tint(_ color: UIColor, blendMode: CGBlendMode, alpha: CGFloat = 1.0) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: size)

        #if !os(watchOS)
        if #available(tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            return UIGraphicsImageRenderer(size: size, format: format).image { context in
                color.setFill()
                context.fill(drawRect)
                draw(in: drawRect, blendMode: blendMode, alpha: alpha)
            }
        }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: alpha)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// SwifterSwift: UImage with background color
    ///
    /// - Parameters:
    ///   - backgroundColor: Color to use as background color
    /// - Returns: UIImage with a background color that is visible where alpha < 1
    func withBackgroundColor(_ backgroundColor: UIColor) -> UIImage {

        #if !os(watchOS)
        if #available(tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            return UIGraphicsImageRenderer(size: size, format: format).image { context in
                backgroundColor.setFill()
                context.fill(context.format.bounds)
                draw(at: .zero)
            }
        }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        draw(at: .zero)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// SwifterSwift: UIImage with rounded corners
    ///
    /// - Parameters:
    ///   - radius: corner radius (optional), resulting image will be round if unspecified
    /// - Returns: UIImage with all corners rounded
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// SwifterSwift: Base 64 encoded PNG data of the image.
    ///
    /// - returns: Base 64 encoded PNG data of the image as a String.
    func pngBase64String() -> String? {
        return pngData()?.base64EncodedString()
    }

    /// SwifterSwift: Base 64 encoded JPEG data of the image.
    ///
    /// - parameter compressionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
    /// - returns: Base 64 encoded JPEG data of the image as a String.
    func jpegBase64String(compressionQuality: CGFloat) -> String? {
        return jpegData(compressionQuality: compressionQuality)?.base64EncodedString()
    }

}

// MARK: - Initializers
public extension UIImage {

    /// SwifterSwift: Create UIImage from color and size.
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }

    /// SwifterSwift: Create a new image from a base 64 string.
    ///
    /// - Parameters:
    ///   - base64String: a base-64 `String`, representing the image
    ///   - scale: The scale factor to assume when interpreting the image data created from the base-64 string. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the `size` property.
    convenience init?(base64String: String, scale: CGFloat = 1.0) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.init(data: data, scale: scale)
    }

    /// SwifterSwift: Create a new image from a URL
    ///
    /// - Important:
    ///   Use this method to convert data:// URLs to UIImage objects.
    ///   Don't use this synchronous initializer to request network-based URLs. For network-based URLs, this method can block the current thread for tens of seconds on a slow network, resulting in a poor user experience, and in iOS, may cause your app to be terminated.
    ///   Instead, for non-file URLs, consider using this in an asynchronous way, using `dataTask(with:completionHandler:)` method of the URLSession class or a library such as `AlamofireImage`, `Kingfisher`, `SDWebImage`, or others to perform asynchronous network image loading.
    /// - Parameters:
    ///   - url: a `URL`, representing the image location
    ///   - scale: The scale factor to assume when interpreting the image data created from the URL. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the `size` property.
    convenience init?(url: URL, scale: CGFloat = 1.0) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data, scale: scale)
    }

}

#endif