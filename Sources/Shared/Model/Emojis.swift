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

// MARK: - Emojis

class Emojis {
    fileprivate static let regexp = try! NSRegularExpression(pattern: ":([\\w+-]+):")

    private var emojis: [String: URL] = [:]

    init() {}

    subscript(_ name: String) -> URL? {
        emojis[name]
    }

    func load(service: BuildkiteService) async {
        do {
            let emojis = try await service.send(resource: .emojis(in: service.organization))
            self.emojis = emojis.reduce(into: [:]) { acc, emoji in
                acc[emoji.name] = emoji.url
                emoji.aliases?.forEach { acc[$0] = emoji.url }
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - String

extension String {
    func attributed(emojis: Emojis) -> AttributedString {
        var lastEndIndex = startIndex
        var attr = AttributedString()

        for match in emojiMatches() {
            attr.append(AttributedString(self[lastEndIndex..<match.lowerBound]))
            lastEndIndex = match.upperBound

            let name = self[match].trimmingCharacters(in: [":"])

            guard let url = emojis[name], let emojiAttr = try? AttributedString(markdown: "![\(name)](\(url.absoluteString))") else {
                attr.append(AttributedString(self[match]))
                continue
            }

            attr.append(emojiAttr)
        }

        attr.append(AttributedString(self[lastEndIndex...]))

        return attr
    }

    mutating func replacingEmojis(_ emojis: Emojis, with replacement: String = "") -> Self {
        for match in emojiMatches().reversed() {
            let name = self[match].trimmingCharacters(in: [":"])
            guard emojis[name] != nil else {
                continue
            }
            replaceSubrange(match, with: replacement)
        }

        return trimmingCharacters(in: .whitespaces)
    }

    private func emojiMatches() -> [Range<Index>] {
        Emojis.regexp
            .matches(in: self, range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }
    }
}

// MARK: - SwiftUI

private struct EmojisKey: EnvironmentKey {
    static let defaultValue: Emojis = Emojis()
}

extension EnvironmentValues {
    var emojis: Emojis {
        get { self[EmojisKey.self] }
        set { self[EmojisKey.self] = newValue }
    }
}

extension Text {
    init<S>(_ content: S, emojis: Emojis) where S: StringProtocol {
        self.init(String(content).attributed(emojis: emojis))
    }
}

