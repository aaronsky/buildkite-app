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

class ImageLoader {
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    private var cache: ImageCache?
    private var session: URLSession
    private var cancellables: Set<AnyCancellable> = []
    
    init(cache: ImageCache? = nil, session: URLSession = .shared) {
        self.cache = cache
        self.session = session
    }
    
    func load(url: URL, completion: @escaping (CrossPlatformImage?) -> Void) {
        if let image = loadFromCache(url: url) {
            completion(image)
            return
        }
        
        session
            .dataTaskPublisher(for: url)
            .map { CrossPlatformImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in
                self?.cacheImage($0, keyedBy: url)
            })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }
    
    /// Do not fetch over the wire, only remove from cache if present
    func loadFromCache(url: URL) -> CrossPlatformImage? {
        cache?[url]
    }
    
    func cancel() {
        cancellables.removeAll()
    }
    
    private func cacheImage(_ image: CrossPlatformImage?, keyedBy url: URL) {
        image.map { cache?[url] = $0 }
    }
}
