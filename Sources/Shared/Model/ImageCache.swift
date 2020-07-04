//
//  AsyncImage.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import SwiftUI
import Combine

#if os(macOS)
import AppKit
public typealias CrossPlatformImage = NSImage
#else
import UIKit
public typealias CrossPlatformImage = UIImage
#endif

extension Image {
    init(crossPlatformImage: CrossPlatformImage) {
        #if os(macOS)
        self.init(nsImage: crossPlatformImage)
        #else
        self.init(uiImage: crossPlatformImage)
        #endif
    }
}

protocol ImageCache {
    subscript(_ url: URL) -> CrossPlatformImage? { get set }
}

struct ImageMemoryCache: ImageCache {
    private let cache = NSCache<NSURL, CrossPlatformImage>()
    
    subscript(_ key: URL) -> CrossPlatformImage? {
        get {
            cache.object(forKey: key as NSURL)
        }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: key as NSURL)
            } else {
                cache.removeObject(forKey: key as NSURL)
            }
        }
    }
}
