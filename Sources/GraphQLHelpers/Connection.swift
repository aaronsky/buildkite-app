import Foundation

public struct Connection<Node: Decodable>: Decodable, RandomAccessCollection, MutableCollection,
    RangeReplaceableCollection
{
    public typealias Element = Node
    public typealias Index = Array<Element>.Index

    public var totalCount: Int
    public var pageInfo: PageInfo?
    private var edges: [Edge] = []

    public var startIndex: Index { edges.startIndex }
    public var endIndex: Index { edges.endIndex }

    public init() {
        self.init(
            nodes: [],
            totalCount: 0,
            pageInfo: nil
        )
    }

    public init(
        nodes: [Node],
        totalCount: Int,
        pageInfo: PageInfo? = nil
    ) {
        self.edges = nodes.map(Edge.init(node:))
        self.totalCount = totalCount
        self.pageInfo = pageInfo
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalCount = try container.decode(Int.self, forKey: .count)
        self.pageInfo = try container.decodeIfPresent(PageInfo.self, forKey: .pageInfo)
        self.edges = try container.decodeIfPresent([Edge].self, forKey: .edges) ?? []
    }

    public subscript(index: Index) -> Element {
        get { edges[index].node }
        set { edges[index].node = newValue }
    }

    public func index(after i: Index) -> Index {
        edges.index(after: i)
    }

    public func cursor(at i: Index) -> String? {
        edges[i].cursor
    }

    public mutating func replaceSubrange<C>(_ subrange: Range<Array<Element>.Index>, with newElements: C)
    where C: Collection, Node == C.Element {
        edges.replaceSubrange(subrange, with: newElements.map(Edge.init(node:)))
    }

    public struct PageInfo: Decodable, Equatable, Hashable, Sendable {
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String?
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String?
    }

    fileprivate struct Edge: Decodable {
        var node: Node
        var cursor: String?

        init(
            node: Node
        ) {
            self.init(node: node, cursor: nil)
        }

        init(
            node: Node,
            cursor: String?
        ) {
            self.node = node
            self.cursor = cursor
        }
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case pageInfo
        case edges
    }
}

extension Connection.Edge: Equatable where Node: Equatable {}
extension Connection.Edge: Hashable where Node: Hashable {}
extension Connection.Edge: Sendable where Node: Sendable {}

extension Connection: Equatable where Node: Equatable {}
extension Connection: Hashable where Node: Hashable {}
extension Connection: Sendable where Node: Sendable {}

extension Connection: ExpressibleByArrayLiteral {
    public init(
        arrayLiteral elements: Node...
    ) {
        self.init(
            nodes: elements,
            totalCount: elements.count,
            pageInfo: nil
        )
    }
}
