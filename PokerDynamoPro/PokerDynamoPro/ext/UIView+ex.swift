//
//  UIView+ex.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//


import UIKit

extension UIImage {
    static func framesFromGif(named: String) -> [UIImage]? {
        guard let path = Bundle.main.path(forResource: named, ofType: "gif"),
              let data = NSData(contentsOfFile: path),
              let source = CGImageSourceCreateWithData(data, nil) else { return nil }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        return images
    }
}

extension UIView {
    
    func toImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        guard let pngData = image.pngData() else { return nil }
        
        return UIImage(data: pngData)
    }
}
