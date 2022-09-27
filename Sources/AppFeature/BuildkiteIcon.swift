//
//  BuildkiteIcon.swift
//  Shared
//
//  Created by Aaron Sky on 5/25/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Styling
import DeveloperToolsSupport
import SwiftUI

/*
 <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 667">
 <path fill="gold" d="m0 0 333.3 165.3v333.4L0 333.3M669.3 0 1000 165.3l-330.7 168"/>
 <path fill="#0057b7" d="m669.3 0-336 165.3v333.4l336-165.4m330.7-168-330.7 168v333.4l330.7-168"/>
 </svg>
 */

public struct BuildkiteIcon: View {
    var primaryColor: Color
    var secondaryColor: Color

    init(
        primaryColor: Color = .buildkite.brightGreen,
        secondaryColor: Color = .buildkite.deepGreen
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    public var body: some View {
        Path { path in

        }
        .fill(primaryColor)
        Path { path in

        }
        .fill(secondaryColor)
    }
}

/*
public struct BuildkiteIconOLD: View {

    public var body: some View {
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
            let xUnit = rect.width / 8
            let yUnit = rect.height / 8
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
            let xUnit = rect.width / 8
            let yUnit = rect.height / 8
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
*/

struct BuildkiteLogo_Previews: PreviewProvider {
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
