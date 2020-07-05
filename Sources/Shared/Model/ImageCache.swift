//
//  AsyncImage.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import SwiftUI
import Combine

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
