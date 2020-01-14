//
//  String + MD5.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import Foundation

/// crash : yld: Library not loaded: /System/Library/Frameworks/Combine.framework/Combine
/// https://stackoverflow.com/questions/57168931/optional-linking-for-swift-combine-framework-in-xcode-11

#if canImport(CryptoKit)
  import CryptoKit
#endif

import CommonCrypto


extension String {
    var md5Value: String {
        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        } else {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)

            if let d = self.data(using: .utf8) {
                _ = d.withUnsafeBytes { body -> String in
                    CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)

                    return ""
                }
            }
            return (0 ..< length).reduce("") {
                $0 + String(format: "%02x", digest[$1])
            }
        }
    }
}
