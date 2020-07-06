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
    private var loader: ImageLoader
    
    init(cache: ImageCache = ImageMemoryCache(), session: URLSession = .shared) {
        self.loader = ImageLoader(cache: cache, session: session)
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
    
    func formatEmojis(in string: String, idealHeight: CGFloat, capHeight: CGFloat) -> NSAttributedString {
        let fullAttributed = NSMutableAttributedString()
        var lastEndIndex = string.startIndex
        
        let matches = Emojis.regexp
            .matches(in: string, range: NSRange(string.startIndex..., in: string))
            .compactMap { Range($0.range, in: string) }
        
        for range in matches {
            fullAttributed.append(string: string[lastEndIndex..<range.lowerBound])
            lastEndIndex = range.upperBound
            
            let match = string[range]
            let name = match.trimmingCharacters(in: [":"])
            switch emojiState(for: name) {
            case .none:
                fullAttributed.append(string: match)
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
                fullAttributed.append(NSAttributedString(attachment: icon))
            }
        }
        
        fullAttributed.append(string: string[lastEndIndex...])
        
        return fullAttributed
    }
    
    func replacingEmojiIdentifiers(in string: String, with replacement: String = "") -> String {
        var string = string
        let matches = Emojis.regexp.matches(in: string, range: NSRange(string.startIndex..., in: string))
        for match in matches.reversed() {
            guard let matchRange = Range(match.range, in: string) else {
                continue
            }
            let name = string[matchRange].trimmingCharacters(in: [":"])
            guard let _ = emojis[name] else {
                continue
            }
            string.replaceSubrange(matchRange, with: replacement)
        }
        return string.trimmingCharacters(in: .whitespaces)
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
        if let image = loader.loadFromCache(url: url) {
            return .image(image)
        }
        loader.load(url: url) { [weak self] _ in
            self?.objectWillChange.send()
        }
        return .loading
    }
}

private extension NSMutableAttributedString {
    func append<S: StringProtocol>(string str: S) {
        append(NSAttributedString(string: String(str)))
    }
}
