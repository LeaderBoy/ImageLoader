//
//  URLImageView.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/5.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

let imageDecodeQueue = DispatchQueue(label: "image.decode.queue")

class URLImageView: UIImageView {
    
    let memoryCache = ImageMemoryCache.shared
    let diskCache = ImageDiskCache.shared
    var key : String = ""
    var animated : Bool = false
    
    var totalSize : Int64 = 0
    var receiveData : Data?
    var increatementallyImageSource : CGImageSource?
    
    typealias ImageloadCompletedHandler = (Result<Bool,Error>) -> Void
    
    func load(url : URL,animated : Bool,completed:ImageloadCompletedHandler? = nil) {
        key = url.absoluteString
        self.animated = animated
        image = nil
        print("调用")
//        if let image = memoryCache.object(forKey: key as NSString) {
//            self.image = image
//            print("memory")
//            return
//        }
//
//        /// sync
//        if let image = diskCache.object(forKey: key) {
//            self.image = image
//            memoryCache.setObject(image, forKey: key as NSString)
//            print("disk")
//            return
//        }
        
        ImageDownloader.shared.download(from: url) { (result) in
            if self.key == url.absoluteString {
                switch result {
                case .success(let data):
                    self.imageSuccessLoaded(from: data, completed: completed)
                case .failure(let error):
                    self.imageFailLoaded(with: error, completed: completed)
                }
            }
        }
    }
    
    func imageSuccessLoaded(from data : Data,completed:ImageloadCompletedHandler? = nil) {
        
        let size = CGSize(width: 375, height: 250)
        
        var image : UIImage?

        let applyImage : ((UIImage?) -> Void) = { image in
            DispatchQueue.main.async {
                if self.animated {
                    UIView.transition(with: self, duration: 0.25, options: [.curveEaseIn,.transitionCrossDissolve], animations: {
                        self.image = image
                    }, completion: nil)
                } else {
                    self.image = image
                }
                completed?(.success(true))
            }
        }
        
        if data.imageContentType == .gif {
            image = UIImage.gifImage(with: data)
            applyImage(image)
        } else {
            if let image = downsample(imageAt: data, to: size, scale: 1) {
                applyImage(image)
            } else {
                print("downsample failed")
            }
        }
        
        if let image = image {
            self.memoryCache.setObject(image, forKey: self.key as NSString)
            self.diskCache.setObject(data, forKey: self.key)
        }
    }
    
    func imageFailLoaded(with error : Error,completed:ImageloadCompletedHandler? = nil) {
        print("加载失败:\(error)")
    }
    
    
    func load(url : URL,progressly : Bool,completed:((Bool,Error?) ->Void)? = nil) {
        key = url.absoluteString
        image = nil
        
        let imageSourceOptions = [kCGImageSourceShouldCache : false] as CFDictionary
        increatementallyImageSource = CGImageSourceCreateIncremental(imageSourceOptions)
        receiveData = Data()
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url)
        task.resume()
    }
}

extension URLImageView : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        totalSize = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let urlString = dataTask.currentRequest?.url?.absoluteString,urlString == self.key else {
            return
        }
        
        imageDecodeQueue.async {
            self.receiveData!.append(data)
            
            let loadFinished = self.receiveData!.count == self.totalSize
            
            CGImageSourceUpdateData(self.increatementallyImageSource!, self.receiveData! as CFData, loadFinished)
            
            let downSampleOptions = [
                kCGImageSourceShouldCacheImmediately : true,
            ] as CFDictionary
            
            if let imageRef = CGImageSourceCreateImageAtIndex(self.increatementallyImageSource!, 0, downSampleOptions) {
                DispatchQueue.main.async {
                    self.image = UIImage(cgImage: imageRef)
                }
            }
        }
        
    }
}

/// https://stackoverflow.com/questions/4147311/finding-image-type-from-nsdata-or-uiimage
extension Data {
    enum ImageContentType: String {
        case jpg, png, gif, tiff, unknown

        var fileExtension: String {
            return self.rawValue
        }
    }

    var imageContentType: ImageContentType {

        var values = [UInt8](repeating: 0, count: 1)

        self.copyBytes(to: &values, count: 1)

        switch (values[0]) {
        case 0xFF:
            return .jpg
        case 0x89:
            return .png
        case 0x47:
           return .gif
        case 0x49, 0x4D :
           return .tiff
        default:
            return .unknown
        }
    }
}
