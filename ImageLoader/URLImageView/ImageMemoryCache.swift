//
//  ImageMemoryCache.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

public class ImageMemoryCache {
    public static let shared = ImageMemoryCache()
    lazy var cache = NSCache<NSString, UIImage>()
    
    public func setObject(_ obj: UIImage, forKey key: NSString) {
        cache.setObject(obj, forKey: md5Key(for: key))
    }
    
    public func object(forKey key: NSString) -> UIImage? {
        return cache.object(forKey: md5Key(for: key))
    }
    
    public func removeObject(for key: NSString) {
        cache.removeObject(forKey: md5Key(for: key))
    }
    
    public func removeAll() {
        cache.removeAllObjects()
    }
    
    private func md5Key(for key : NSString) -> NSString {
        let newKey = key as String
        return newKey.md5Value as NSString
    }
}
