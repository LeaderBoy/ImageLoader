//
//  Copyright (C) 2020 杨志远.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  UIImage + GIF.swift
//  ImageLoader
//
//  Created by 杨志远 on 2020/1/17.
//

import UIKit


extension UIImage {
    
    static func gifImageSource(from gifData : Data) -> CGImageSource? {
        if gifData.count == 0 {
            return nil
        }
        if let imageSource = CGImageSourceCreateWithData(gifData as CFData, nil) {
            return imageSource
        } else {
            return nil
        }
    }
    
    /// retrive frame images and duration
    /// - Parameter imageSource: get image propertys from imageSource
    static func animatedImagesPropertys(from imageSource : CGImageSource) -> ([UIImage],TimeInterval) {
        let imageCount = CGImageSourceGetCount(imageSource)
        var duration : Double = 0
        var images : [UIImage] = []
        
        for index in 0...imageCount {
            guard let cgimage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
                continue
            }
            let image = UIImage(cgImage: cgimage)
            duration += frameDuration(from: imageSource, at: index)
            images.append(image)
        }
        return (images,duration)
    }
    
    
    /// retrive frame duration from image located at index
    /// duration at some gif will be 0,so replace 0 with 0.1
    /// - Parameter imageSource: imageSource
    /// - Parameter index: index
    static func frameDuration(from imageSource : CGImageSource,at index : Int) -> TimeInterval {
        var duration = 0.1
        
        guard let framePropertys = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) else {
            return duration
        }
        
        guard let gifPropertys = (framePropertys as Dictionary)[kCGImagePropertyGIFDictionary] else {
            return duration
        }
        if let delay = gifPropertys[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber {
            let value = delay.doubleValue
            duration = value == 0 ? duration : value
        } else if let delay = gifPropertys[kCGImagePropertyGIFDelayTime] as? NSNumber {
            let value = delay.doubleValue
            duration = value == 0 ? duration : value
        }
        return duration
    }
    
    
    /// retrive gif image from data
    /// - Parameter gifData: data
    static func gifImage(with gifData : Data) -> UIImage? {
        guard let imageSource = gifImageSource(from: gifData) else {
            return nil
        }
        let propertys = animatedImagesPropertys(from: imageSource)
        let (images,duration) = propertys
        if images.count == 0 || duration == 0 {
            return UIImage(data: gifData)
        }
        let image = UIImage.animatedImage(with: images, duration: duration)
        return image
    }
}
