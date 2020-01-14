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
    
    func load(url : URL,animated : Bool,completed:((Bool,Error?) ->Void)? = nil) {
        key = url.absoluteString
        self.animated = animated
        image = nil
        
        if let image = memoryCache.object(forKey: key as NSString) {
            self.image = image
            print("memory")
            return
        }

        /// sync
        if let image = diskCache.object(forKey: key) {
            self.image = image
            memoryCache.setObject(image, forKey: key as NSString)
            print("disk")
            return
        }
        
        let size = CGSize(width: 375, height: 250)

        /// cancel default cache
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
                
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                completed?(false,error!)
                return
            }
            if self.key == url.absoluteString {
                if let imageData = data {
                    let image = downsample(imageAt: imageData, to: size, scale: 1)!
                    DispatchQueue.main.async {
                        if self.animated {
                            UIView.transition(with: self, duration: 0.25, options: [.curveEaseIn,.transitionCrossDissolve], animations: {
                                self.image = image
                            }, completion: nil)
                        } else {
                            self.image = image
                        }
                        
                        self.memoryCache.setObject(image, forKey: self.key as NSString)
                        self.diskCache.setObject(imageData, forKey: self.key)
                        
                        completed?(true,nil)
                    }
                }
            }else {
                print("loading failed")
                completed?(false,nil)
            }
        }
        
        task.resume()
        
//        /// async
//        diskCache.object(forKey: key) { (image) in
//            if let image = image {
//                self.memoryCache.setObject(image, forKey: self.key as NSString)
//                task.cancel()
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//            }
//        }
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
