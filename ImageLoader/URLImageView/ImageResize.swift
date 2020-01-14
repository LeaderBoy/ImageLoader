//
//  ImageResize.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit
//import func AVFoundation.AVMakeRect


func resizeImage(data imageData : Data,to size : CGSize) -> UIImage? {
    guard let image = UIImage(data: imageData) else {
        return nil
    }
    let render = UIGraphicsImageRenderer(size: size)
    return render.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}



/// Downsampling large image for display at smaller size
/// https://developer.apple.com/videos/play/wwdc2018/219/
/// - Parameter imageURL: image url
/// - Parameter pointSize: the thumbnail size
/// - Parameter scale: the thumbnail scale
func downsample(imageAt imageURL : URL,to pointSize : CGSize,scale : CGFloat) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache : false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
        return nil
    }
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
    let downSampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways : true,
        kCGImageSourceShouldCacheImmediately : true,
        kCGImageSourceCreateThumbnailWithTransform : true,
        kCGImageSourceThumbnailMaxPixelSize : maxDimensionInPixels
    ] as CFDictionary
    
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions) else {
        return nil
    }
    return UIImage(cgImage: downsampledImage)
}

func downsample(imageAt imageData : Data,to pointSize : CGSize,scale : CGFloat) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache : false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
        return nil
    }
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
    let downSampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways : true,
        kCGImageSourceShouldCacheImmediately : true,
        kCGImageSourceCreateThumbnailWithTransform : true,
        kCGImageSourceThumbnailMaxPixelSize : maxDimensionInPixels
    ] as CFDictionary
    
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions) else {
        return nil
    }
        
    return UIImage(cgImage: downsampledImage)
}
