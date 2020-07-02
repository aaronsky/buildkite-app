//
//  Emojis.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//


import Foundation
import Buildkite
import SwiftUI

class Emojis: ObservableObject {
    @Published var emojis: [String: URL] = [:]
    static let regexp = try! NSRegularExpression(pattern: ":[^\\s:]+:(?::skin-tone-[2-6]:)?")
    
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
}

extension String {
    
    /// Returns a new string with all instances of recognized emoji replaced with remote images.
    func replacingEmojis(using emojis: Emojis) -> String {
        var str = self
        let range = NSRange(str.startIndex..., in: str)
        let matches = Emojis.regexp.matches(in: str, range: range).reversed()
        for match in matches {
            guard let matchRange = Range(match.range, in: str) else {
                continue
            }
            let name = str[matchRange].trimmingCharacters(in: [":"])
            guard let _ = emojis.emojis[name] else {
                continue
            }
            // TODO: Fix embedding emoji in Text
            // let image = AsyncImage(url: url)
            //     .aspectRatio(contentMode: .fit)
            //     .accessibility(label: Text(name))
            //
            // str.replaceSubrange(matchRange, with: "\(image)")
            str.replaceSubrange(matchRange, with: "🤬")
        }
        return str.trimmingCharacters(in: .whitespaces)
    }
}
