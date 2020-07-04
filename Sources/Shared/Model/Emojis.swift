//
//  Emojis.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//


import Foundation
import Buildkite
import Combine
import SwiftUI

class Emojis: ObservableObject {
    static let regexp = try! NSRegularExpression(pattern: ":[^\\s:]+:(?::skin-tone-[2-6]:)?")
    
    private var emojis: [String: URL] = [:]
    private var cache: ImageCache
    private var cancellables: Set<AnyCancellable> = []
    
    init(cache: ImageCache) {
        self.cache = cache
    }
    
    func emoji(for name: String) -> EmojiState {
        guard let url = emojis[name] else {
            return .none
        }
        if let image = cache[url] {
            return .image(image)
        }
        loadEmoji(at: url)
        return .loading
    }
    
    func loadEmojis(service: BuildkiteService) {
        service
            .sendPublisher(resource: Emoji.Resources.List(organization: service.organization))
            .map { emojis in
                emojis.reduce(into: [String: URL]()) { acc, emoji in
                    acc[emoji.name] = emoji.url
                    emoji.aliases?.forEach { acc[$0] = emoji.url }
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.emojis = $0 })
    }
    
    func loadEmoji(at url: URL, session: URLSession = .shared) {
        session
            .dataTaskPublisher(for: url)
            .map { CrossPlatformImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.cache[url] = $0
                self.objectWillChange.send()
            })
            .store(in: &cancellables)
    }
    
    enum EmojiState {
        case none
        case loading
        case image(CrossPlatformImage)
    }
}
