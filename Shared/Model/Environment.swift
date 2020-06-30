//
//  Environment.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import SwiftUI

struct AsyncImageCacheKey: EnvironmentKey {
    static let defaultValue: AsyncImageCache = ImageMemoryCache()
}

extension EnvironmentValues {
    var imageCache: AsyncImageCache {
        get { self[AsyncImageCacheKey.self] }
        set { self[AsyncImageCacheKey.self] = newValue }
    }
}
