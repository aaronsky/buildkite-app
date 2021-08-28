//
//  BuildkiteIcon.swift
//  Shared
//
//  Created by Aaron Sky on 5/25/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import SwiftUI
import DeveloperToolsSupport

struct BuildkiteIcon: View {
    static let brightGreen = Color(red: 0.1882352941, green: 0.9490196078, blue: 0.6352941176)
    static let deepGreen = Color(red: 0.07843137255, green: 0.8, blue: 0.5019607843)

    var body: some View {
        ZStack {
            Shape1()
                .fill(BuildkiteIcon.brightGreen)
            Shape2()
                .fill(BuildkiteIcon.deepGreen)
                .animation(Animation.default, value: false)
        }
        .aspectRatio(contentMode: .fit)
    }

    struct Shape1: Shape {
        func path(in rect: CGRect) -> Path {
            let xUnit = rect.width / 6
            let yUnit = rect.height / 4
            return Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: xUnit * 2, y: yUnit))
                path.addLine(to: CGPoint(x: xUnit * 2, y: yUnit * 3))
                path.addLine(to: CGPoint(x: 0, y: yUnit * 2))
                path.move(to: CGPoint(x: xUnit * 4, y: 0))
                path.addLine(to: CGPoint(x: xUnit * 6, y: yUnit))
                path.addLine(to: CGPoint(x: xUnit * 4, y: yUnit * 2))
            }
        }
    }

    struct Shape2: Shape {
        func path(in rect: CGRect) -> Path {
            let xUnit = rect.width / 6
            let yUnit = rect.height / 4
            return Path { path in
                path.move(to: CGPoint(x: xUnit * 4, y: 0))
                path.addLine(to: CGPoint(x: xUnit * 2, y: yUnit))
                path.addLine(to: CGPoint(x: xUnit * 2, y: yUnit * 3))
                path.addLine(to: CGPoint(x: xUnit * 4, y: yUnit * 2))
                path.move(to: CGPoint(x: xUnit * 6, y: yUnit))
                path.addLine(to: CGPoint(x: xUnit * 4, y: yUnit * 2))
                path.addLine(to: CGPoint(x: xUnit * 4, y: yUnit * 4))
                path.addLine(to: CGPoint(x: xUnit * 6, y: yUnit * 3))
            }
        }
    }
}

struct AnimatedBuildkiteLogo_Previews: PreviewProvider {
    static var previews: some View {
        BuildkiteIcon()
    }
}

// MARK: - Library Integration

struct BuildkiteIconLibraryContent: LibraryContentProvider {
    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(
            BuildkiteIcon(),
            title: "Buildkite Icon"
        )
    }
}
