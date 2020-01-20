//
//  ImageDiskCache.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

public class ImageDiskCache {
    public static let shared = ImageDiskCache()
    
    let imageQueue = DispatchQueue(label: "com.disk.queue")
    
    lazy var path: URL? = {
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first,var urlPath = URL(string: path) {
            urlPath.appendPathComponent("com.disk.images")
            let file = URL(fileURLWithPath: urlPath.path)
            if !FileManager.default.fileExists(atPath: file.path) {
                try! FileManager.default.createDirectory(at: file, withIntermediateDirectories: false, attributes: [:])
            }
            
            return urlPath
        }
        return nil
    }()
    
    public func setObject(_ obj: Data, forKey key: String) {
        
        if var fileName = fileURL(for: key) {
            do {
                try obj.write(to: fileName)
                do {
                    /// prevent backup
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = false
                    try fileName.setResourceValues(resourceValues)
                } catch let e {
                    print("disable backup failed:\(e)")
                }
            } catch let e {
                print("file write to disk failed:\(e)")
            }
        }
    }
    
    public func object(forKey key: String) -> UIImage? {
        if let data = dataObject(forKey: key) {
            return UIImage(data: data)
        }
        return nil
    }
    
    public func dataObject(forKey key: String) -> Data? {
        if let fileName = fileURL(for: key) {
            if FileManager.default.fileExists(atPath: fileName.path) {
                do {
                    let data = try Data(contentsOf: fileName)
                    return data
                } catch let e {
                    print("file search failed:\(e)")
                    return nil
                }
            }
            return nil
        }
        return nil
    }
    
    public func object(forKey key: String,completed:@escaping (UIImage?) ->Void) {
        imageQueue.async {
            if let fileName = self.fileURL(for: key) {
                if FileManager.default.fileExists(atPath: fileName.path) {
                    do {
                        let data = try Data(contentsOf: fileName)
                        completed(UIImage(data: data))
                    } catch let e {
                        print("file search failed:\(e)")
                        completed(nil)
                    }
                }
                completed(nil)
            }
        }
//        DispatchQueue.global(qos: .userInteractive).async {
//
//        }
    }
    
    public func removeObject(for key: NSString) {
        
    }
    
    public func removeAll() {
        
    }
    
    func fileURL(for key : String) -> URL? {
        if let path = self.path {
            let md5Key = key.md5Value
            let file = URL(fileURLWithPath: path.appendingPathComponent(md5Key).path)
            return file
        }
        return nil
    }
}
