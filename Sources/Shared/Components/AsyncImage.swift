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

struct AsyncImage: View {
    @ObservedObject private var coordinator: Coordinator
    
    init(url: URL, cache: AsyncImageCache? = nil) {
        self.coordinator = Coordinator(url: url, cache: cache)
    }
    
    var body: some View {
        image
            .onAppear(perform: coordinator.load)
            .onDisappear(perform: coordinator.cancel)
    }
    
    private var image: some View {
        Group {
            if let image = coordinator.image {
                Image(crossPlatformImage: image)
                    .resizable()
            }
        }
    }
    
    private class Coordinator: ObservableObject {
        @Published var image: CrossPlatformImage?
        
        private let url: URL
        private let session: URLSession
        private var cache: AsyncImageCache?
        private var cancellable: AnyCancellable?
        
        init(url: URL, session: URLSession = .shared, cache: AsyncImageCache? = nil) {
            self.url = url
            self.session = session
            self.cache = cache
        }
        
        func load() {
            cancellable = session.dataTaskPublisher(for: url)
                .map { CrossPlatformImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveOutput: { [weak self] in self?.setCache($0) })
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        
        func cancel() {
            cancellable?.cancel()
        }
        
        private func setCache(_ image: CrossPlatformImage?) {
            image.map { cache?[url] = $0 }
        }
    }
}

extension Image {
    init(crossPlatformImage: CrossPlatformImage) {
        #if os(macOS)
        self.init(nsImage: crossPlatformImage)
        #else
        self.init(uiImage: crossPlatformImage)
        #endif
    }
}

protocol AsyncImageCache {
    subscript(_ url: URL) -> CrossPlatformImage? { get set }
}

struct ImageMemoryCache: AsyncImageCache {
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

struct AsyncImageCacheKey: EnvironmentKey {
    static let defaultValue: AsyncImageCache = ImageMemoryCache()
}

extension EnvironmentValues {
    var imageCache: AsyncImageCache {
        get { self[AsyncImageCacheKey.self] }
        set { self[AsyncImageCacheKey.self] = newValue }
    }
}

struct AsyncImage_Previews: PreviewProvider {
    static let url = URL(string: "https://buildkiteassets.com/emojis/img-apple-64/1f45e.png")!
    
    static var previews: some View {
        AsyncImage(url: url)
    }
}
