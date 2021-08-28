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
    fileprivate static let regexp = try! NSRegularExpression(pattern: ":([\\w+-]+):")

    private var emojis: [String: URL] = [:]

    init() {}

    func load(service: BuildkiteService) async {
        do {
            let emojis = try await service.send(resource: .emojis(in: service.organization))
            self.emojis = emojis.reduce(into: [String: URL]()) { acc, emoji in
                acc[emoji.name] = emoji.url
                emoji.aliases?.forEach { acc[$0] = emoji.url }
            }
        } catch {
            print(error)
        }
    }

    subscript(_ name: String) -> URL? {
        emojis[name]
    }
}

extension Text {
    init<S>(_ content: S, emojis: Emojis) where S: StringProtocol {
        self.init(String(content).attributed(emojis: emojis))
    }
}

extension String {
    func attributed(emojis: Emojis) -> AttributedString {
        let matches = Emojis.regexp
            .matches(in: self, range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }

        var lastEndIndex = startIndex
        var attr = AttributedString()

        for range in matches {
            attr.append(AttributedString(self[lastEndIndex..<range.lowerBound]))
            lastEndIndex = range.upperBound

            let match = self[range]
            let name = match.trimmingCharacters(in: [":"])

            guard let url = emojis[name], let emojiAttr = try? AttributedString(markdown: "![\(name)](\(url.absoluteString))") else {
                attr.append(AttributedString(match))
                continue
            }

            attr.append(emojiAttr)
        }

        attr.append(AttributedString(self[lastEndIndex...]))

        return attr
    }

    mutating func replacingEmojis(_ emojis: Emojis, with replacement: String = "") -> Self {
        let matches = Emojis.regexp
            .matches(in: self, range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }

        for match in matches.reversed() {
            let name = self[match].trimmingCharacters(in: [":"])
            guard emojis[name] != nil else {
                continue
            }
            replaceSubrange(match, with: replacement)
        }

        return trimmingCharacters(in: .whitespaces)
    }
}
