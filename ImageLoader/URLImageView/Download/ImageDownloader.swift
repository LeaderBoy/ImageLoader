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
//  ImageDownloader.swift
//  ImageLoader
//
//  Created by 杨志远 on 2020/1/14.
//

import Foundation

public protocol Downloader {
    var completeHandler : Result<Data,Error>? {get set}
    var progressHandler : ((Double) ->Void)? {get set}
    
    func resume()
    func suspend()
    func cancel()
}


public struct ImageDownloadTask {
    let task : URLSessionDataTask
    let url : URL
}

public class ImageDownloader : NSObject {
    
    static let shared = ImageDownloader()
    
    typealias DownloadCompletionHandler = (Result<Data,Error>) -> Void
    
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "image.download.queue"
        return queue
    }()
        
    let downloadTimeout : TimeInterval = 60
    
    lazy var serialAccessQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "image.serialAccess.queue"
        return queue
    }()
    
    var tasks : [URL : [DownloadCompletionHandler]] = [:]
    
    lazy var downloadSession: URLSession = {
        return URLSession(configuration: .default)
    }()
        
    func download(from url : URL,complete :@escaping DownloadCompletionHandler) {
        
        
        serialAccessQueue.addOperation {
            let handlers = self.tasks[url,default:[]]
            self.tasks[url] = handlers + [complete]
            self.fetchImages(from: url)
        }
    }
    
    func fetchImages(from url : URL) {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: self.downloadTimeout)
        let task = self.downloadSession.dataTask(with: request) { (data, response, error) in
            if let data = data,let url = response?.url {
                self.serialAccessQueue.addOperation {
                    self.invokeCompleteHandlers(with: url, data: data)
                }
            }
        }
        task.resume()
    }
    
    func invokeCompleteHandlers(with url : URL,data : Data) {
        let handlers = tasks[url,default:[]]
        tasks[url] = nil
        for handler in handlers {
            handler(.success(data))
        }
    }
}

//extension ImageDownloader : URLSessionDataDelegate {
//    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        completionHandler(.allow)
//    }
//
//    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//
//    }
//}
