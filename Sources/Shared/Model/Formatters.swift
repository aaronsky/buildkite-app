//
//  Formatters.swift
//  Shared
//
//  Created by Aaron Sky on 5/20/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

enum Formatters {
    static let friendlyRelativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter: ISO8601DateFormatter
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            formatter = Formatters.iso8601WithoutFractionalSeconds
        }
        return formatter
    }()

    static let iso8601WithoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func dateIfPossible(fromISO8601 string: String) -> Date? {
        if let date = iso8601WithFractionalSeconds.date(from: string) {
            return date
        } else if let date = iso8601WithoutFractionalSeconds.date(from: string) {
            return date
        }
        return nil
    }

    static func decodeISO8601(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = dateIfPossible(fromISO8601: dateString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Expected date string to be ISO8601-formatted."))
        }
        return date
    }
}
