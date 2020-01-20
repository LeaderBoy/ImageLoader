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
//  ImageDownloadOperation.swift
//  ImageLoader
//
//  Created by 杨志远 on 2020/1/17.
//

import Foundation

class ImageDownloadOperation : Operation {
    
    @objc enum State : Int {
        case pending
        case ready
        case excuting
        case finished
    }
    
    var statLock = NSLock()
    
    var _state : State = .pending
    
    @objc dynamic var state : State {
        set {
            statLock.withScope {
                _state = newValue
            }
        }
        
        get {
            return statLock.withScope {
                _state
            }
        }
    }
    
    override var isReady: Bool {
        return state == .ready && super.isReady
    }
    
    override var isExecuting: Bool {
        return state == .excuting
    }
    
    override var isFinished: Bool {
        return state == .finished
    }

    var session : URLSession
    var request : URLRequest
    var dataTask : URLSessionDataTask?
    var imageData : Data = Data()
    
    init(request :URLRequest,session : URLSession) {
        self.request = request
        self.session = session
        super.init()
        self.state = .ready
    }
    
    override func start() {
        if isCancelled {
            state = .finished
        } else {
            state = .excuting
            main()
        }
    }
    
    override func main() {
        let task = session.dataTask(with: request)
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let keyPaths : [String] = [#keyPath(ImageDownloadOperation.isReady),#keyPath(ImageDownloadOperation.isExecuting),#keyPath(ImageDownloadOperation.isFinished)]

        if keyPaths.contains(key) {
            return [#keyPath(state)]
        } else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}

extension NSLock {
    func withScope<T>(block:() -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
