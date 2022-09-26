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

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView(
            changelog: .init(
                id: "0",
                title: "Change",
                body: "A change occurred on this day",
                publishedAt: .now,
                tag: "work",
                author: .init(
                    name: "Preview Man",
                    avatar: .init(
                        url: URL(string: "https://buildkite.com")!
                    )
                )
            )
        )
    }
}
