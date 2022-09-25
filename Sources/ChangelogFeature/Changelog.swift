import ComposableArchitecture
import SwiftUI

public struct ChangelogView: View {
    var changelog: ListQuery.Response.Changelog

    public init(
        changelog: ListQuery.Response.Changelog
    ) {
        self.changelog = changelog
    }

    public var body: some View {
        ScrollView {
            Text(changelog.title)
                .font(.headline)
            Text(
                "Posted \(changelog.publishedAt.formatted(.dateTime.month().day().year())) by \(changelog.author.name)"
            )
            .font(.subheadline)
            Text(try! AttributedString(markdown: changelog.body))
                .font(.body)
            Text(changelog.tag)
                .font(.callout)
                .padding(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red)
                )
        }
    }
}
