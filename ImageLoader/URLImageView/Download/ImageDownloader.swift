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

public class ImageDownloader : NSObject {
    
    typealias TaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    let downloadQueue = OperationQueue()
    
    let downloadTimeout : TimeInterval = 60
    
    var tasks : [URL : [TaskCompletionHandler]] = [:]
    
    lazy var downloadSession: URLSession = {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        return session
    }()
        
    func download(from url : URL,complete : TaskCompletionHandler?) {
        
        if !tasks.keys.contains(url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: downloadTimeout)
            let task = downloadSession.dataTask(with: request)
            task.resume()
        }
        
        if let complete = complete {
            let handlers = tasks[url,default:[]]
            tasks[url] = handlers + [complete]
        }        
    }
}

extension ImageDownloader : URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
}
