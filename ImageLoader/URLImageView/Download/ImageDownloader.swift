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


struct ImageDownloadTask {
    
    typealias TaskCompleteHandler = (Result<Data,Error>) -> Void
    
    let url : URL
    var progress : Progress
    var data : Data
    let task : URLSessionTask
    var observation: NSKeyValueObservation?
    var handlers : [TaskCompleteHandler]
}

public class ImageDownloader : NSObject {
    
    static let shared = ImageDownloader()
    
    typealias DownloadCompletionHandler = (Result<Data,Error>) -> Void
    
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 6
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
        
    let barrierTasksQueue = DispatchQueue(label: "image.barrierTasks.queue",attributes: .concurrent)
        
    var downloadTasks : [URL : ImageDownloadTask] = [:]
    
    lazy var downloadSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
        
    func download(from url : URL,progressHandler : ((Progress) -> Void)? = nil ,complete :@escaping DownloadCompletionHandler) {
        shouledRequest(url: url, complete: complete) { (should) in
            if should {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
                let task = self.downloadSession.dataTask(with: request)
                let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                    progressHandler?(progress)
                }
                task.resume()
                
                let downloadTask = ImageDownloadTask(url: url, progress: task.progress, data: Data(), task: task,observation: observation, handlers: [complete])
                self.downloadTasks[url] = downloadTask
            }
        }
    }
    
    /// prevent request repeatily
    func shouledRequest(url : URL,complete:@escaping DownloadCompletionHandler,downloadCallback:@escaping (Bool) -> Void) {
        barrierTasksQueue.sync(flags:.barrier) {
            if var downloadTask = self.downloadTasks[url] {
                let handlers = downloadTask.handlers
                downloadTask.handlers = handlers + [complete]
                self.downloadTasks[url] = downloadTask
                downloadCallback(handlers.isEmpty)
            } else {
                downloadCallback(true)
            }
        }
    }
    
    func invokeCompleteHandlers(task : URLSessionTask) {
        
        guard let url = task.response?.url else { return }
        
        barrierTasksQueue.sync(flags : .barrier) {
            if let downloadTask = self.downloadTasks[url] {
                let handlers = downloadTask.handlers
                self.downloadTasks.removeValue(forKey: url)
                if let error = task.error {
                    for handler in handlers {
                        handler(.failure(error))
                    }
                } else {
                    for handler in handlers {
                        handler(.success(downloadTask.data))
                    }
                }
            }
        }
    }
    
    func cancelTask(for url : URL) {
        /// cancel must sync
        /// to prevent again request has been cancelled
        barrierTasksQueue.sync(flags : .barrier) {
            if let downloadTask = self.downloadTasks[url] {
                /// if image is downloading
                /// cancel dataTask
                if downloadTask.progress.fractionCompleted < 1.0 {
                    let task = downloadTask.task
                    task.cancel()
                }
                /// remove cached ImageDownloadTask
                self.downloadTasks.removeValue(forKey: url)
            }
        }
    }
    
    /// https://stackoverflow.com/questions/40662007/nsurlsessiontask-suspend-does-not-work
    
    /// suspendTask not work for data task
    /// - Parameter url: url
//    func suspendTask(for url : URL) {
//        barrierTasksQueue.sync(flags : .barrier) {
//            if let downloadTask = self.downloadTasks[url] {
//                /// if image is downloading
//                /// suspend dataTask
//                let task = downloadTask.task
//                if task.state == .running  {
//                    task.suspend()
//                }
//            }
//        }
//    }
    
//    func resumeTask(for url : URL) {
//        barrierTasksQueue.sync(flags : .barrier) {
//            if let downloadTask = self.downloadTasks[url] {
//                /// if image is downloading
//                /// resume dataTask
//                let task = downloadTask.task
//                if task.state == .suspended {
//                    task.resume()
//                }
//            }
//        }
//    }
    
    
}

extension ImageDownloader : URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        barrierTasksQueue.sync {
            guard let url = dataTask.response?.url else { return }
            if var downloadTask = self.downloadTasks[url] {
                downloadTask.data.append(data)
                self.downloadTasks[url] = downloadTask
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        invokeCompleteHandlers(task: task)
    }
    
}
