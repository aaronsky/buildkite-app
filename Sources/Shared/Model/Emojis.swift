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
    
    func formatEmojis(in text: String, idealHeight: CGFloat, capHeight: CGFloat) -> NSAttributedString {
        let fullString = NSMutableAttributedString()
        let components = text.split(separator: " ")
        for (index, str) in components.enumerated() {
            if str.hasPrefix(":") && str.hasSuffix(":") {
                let name = str.dropFirst().dropLast().trimmingCharacters(in: .whitespaces)
                
                switch emojiState(for: name) {
                case .none:
                    fullString.append(NSAttributedString(string: String(str)))
                case .loading:
                    break
                case let .image(image):
                    let aspectRatio = image.size.width / image.size.height
                    let icon = NSTextAttachment()
                    icon.image = image
                    icon.bounds = CGRect(x: 0,
                                         y: capHeight - idealHeight / 2,
                                         width: aspectRatio * idealHeight,
                                         height: idealHeight)
                    fullString.append(NSAttributedString(attachment: icon))
                }
            } else {
                fullString.append(NSAttributedString(string: String(str)))
            }
            
            if index != components.endIndex {
                fullString.append(NSAttributedString(string: " "))
            }
        }
        return fullString
    }
    
    func replacingEmojiIdentifiers(in text: String, with replacement: String = "") -> String {
        var text = text
        let range = NSRange(text.startIndex..., in: text)
        let matches = Emojis.regexp.matches(in: text, range: range).reversed()
        for match in matches {
            guard let matchRange = Range(match.range, in: text) else {
                continue
            }
            let name = text[matchRange].trimmingCharacters(in: [":"])
            guard let _ = emojis[name] else {
                continue
            }
            text.replaceSubrange(matchRange, with: replacement)
        }
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    enum EmojiState {
        case none
        case loading
        case image(CrossPlatformImage)
    }
    
    func emojiState(for name: String) -> EmojiState {
        guard let url = emojis[name] else {
            return .none
        }
        if let image = cache[url] {
            return .image(image)
        }
        loadEmoji(at: url)
        return .loading
    }
    
    private func loadEmoji(at url: URL, session: URLSession = .shared) {
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
}
