import Foundation
import Security

public struct Keychain: Sendable {
    public enum Error: Swift.Error, Equatable, Sendable {
        case noCredential
        case unexpectedCredentialData
        case unhandledError(status: OSStatus)
    }

    enum ItemClass {
        case internetPassword
        var kSecClass: CFString {
            switch self {
            case .internetPassword:
                return kSecClassInternetPassword
            }
        }
    }

    enum MatchLimit { case one }

    struct ItemAttributes {
        var creationDate: Date
        var modificationDate: Date
        var description: String
        var comment: String
        var creator: UInt
        var type: UInt
        var label: String
        var isInvisible: Bool
        var isNegative: Bool
        var account: String
        var synchronizable: Bool
        var data: Data

        init?(
            _ item: [String: Any]
        ) {
            guard let creationDate = item[kSecAttrCreationDate as String] as? Date else { return nil }
            self.creationDate = creationDate

            guard let modificationDate = item[kSecAttrModificationDate as String] as? Date else { return nil }
            self.modificationDate = modificationDate

            guard let description = item[kSecAttrDescription as String] as? String else { return nil }
            self.description = description

            guard let comment = item[kSecAttrComment as String] as? String else { return nil }
            self.comment = comment

            guard let creator = item[kSecAttrCreator as String] as? UInt else { return nil }
            self.creator = creator

            guard let type = item[kSecAttrType as String] as? UInt else { return nil }
            self.type = type

            guard let label = item[kSecAttrLabel as String] as? String else { return nil }
            self.label = label

            guard let isInvisible = item[kSecAttrIsInvisible as String] as? Bool else { return nil }
            self.isInvisible = isInvisible

            guard let isNegative = item[kSecAttrIsNegative as String] as? Bool else { return nil }
            self.isNegative = isNegative

            guard let account = item[kSecAttrAccount as String] as? String else { return nil }
            self.account = account

            guard let synchronizable = item[kSecAttrSynchronizable as String] as? Bool else { return nil }
            self.synchronizable = synchronizable

            guard let data = item[kSecValueData as String] as? Data else { return nil }
            self.data = data
        }
    }

    private var domain: String

    public init(
        domain: String = "api.buildkite.com"
    ) {
        self.domain = domain
    }

    func credential(
        class itemClass: ItemClass,
        domain: String? = nil,
        limit: MatchLimit = .one
    ) throws -> ItemAttributes {
        let query: [String: Any] = [
            kSecClass as String: itemClass.kSecClass,
            kSecAttrServer as String: domain ?? self.domain,
            kSecMatchLimit as String: limit == .one ? kSecMatchLimitOne : kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let existingItem = item as? [String: Any],
                let attrs = ItemAttributes(existingItem)
            else { throw Error.unexpectedCredentialData }

            return attrs
        case errSecItemNotFound:
            throw Error.noCredential
        default:
            throw Error.unhandledError(status: status)
        }
    }

    func add(
        _ credential: Data,
        for account: String,
        class itemClass: ItemClass,
        domain: String? = nil
    ) throws {
        let attributes: [String: Any] = [
            kSecClass as String: itemClass.kSecClass,
            kSecAttrServer as String: domain ?? self.domain,
            kSecAttrAccount as String: account,
            kSecValueData as String: credential,
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            return try update(
                credential,
                for: account,
                class: itemClass,
                domain: domain
            )
        default:
            throw Error.unhandledError(status: status)
        }
    }

    func update(
        _ credential: Data,
        for account: String,
        class itemClass: ItemClass,
        domain: String? = nil
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: itemClass.kSecClass,
            kSecAttrServer as String: domain ?? self.domain,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: credential
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        switch status {
        case errSecSuccess:
            return
        default:
            throw Error.unhandledError(status: status)
        }
    }

    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: domain,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw Error.unhandledError(status: status)
        }
    }
}
