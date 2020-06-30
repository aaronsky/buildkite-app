//
//  BuildState.swift
//  Shared
//
//  Created by Aaron Sky on 5/15/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import SwiftUI

struct BuildState: View {
    var state: String
    var strokeWidth: CGFloat = 2
    
    var isRunningState: Bool {
        state == "scheduled"
            || state == "running"
            || state == "canceling"
    }
    
    var body: some View {
        ZStack {
            Circle()
                .offset(x: 1, y: 1)
                .size(CGSize(width: 30, height: 30))
                .stroke(Colors.color(for: state), lineWidth: strokeWidth * 2)
            Icon(state: state)
                .stroke(Colors.color(for: state), lineWidth: strokeWidth)
                .modifier(SpinnerMask(enabled: isRunningState))
        }
        .frame(width: 32, height: 32)
        .fixedSize()
    }
    
    private struct Icon: Shape {
        var state: String
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            switch state.lowercased() {
            case "failed", "canceled":
                let xUnit = rect.width / 3
                let yUnit = rect.height / 3
                path.move(to: .init(x: xUnit, y: yUnit))
                path.addLine(to: .init(x: xUnit * 2, y: yUnit * 2))
                path.move(to: .init(x: xUnit * 2, y: yUnit))
                path.addLine(to: .init(x: xUnit, y: yUnit * 2))
            case "passed":
                path.addLines([
                    .init(x: 10, y: 17.61),
                    .init(x: 14.38, y: 20.81),
                    .init(x: 21, y: 11.41),
                ])
            case "blocked":
                path.move(to: .init(x: 13, y: 21))
                path.addLine(to: .init(x: 13, y: 11))
                path.move(to: .init(x: 19, y: 21))
                path.addLine(to: .init(x: 19, y: 11))
            case "scheduled", "running", "canceling":
                path.addEllipse(in: .init(x: 10, y: 10, width: 12, height: 12))
            default:
                path.move(to: .init(x: 11, y: 16))
                path.addLine(to: .init(x: 21, y: 16))
            }
            return path
        }
    }
    
    private struct SpinnerMask: ViewModifier {
        var enabled: Bool
        @State var rotation: Double = 0
        
        private var animation: Animation {
            Animation
                .linear(duration: 1.05)
                .repeatForever(autoreverses: false)
        }
        
        var mask: some View {
            Path { path in
                path.addLines([
                    .init(x: 16, y: 16),
                    .init(x: 9, y: 16),
                    .init(x: 9, y: 9),
                    .init(x: 16, y: 9),
                    .init(x: 16, y: 16),
                    .init(x: 23, y: 16),
                    .init(x: 23, y: 23),
                    .init(x: 16, y: 23),
                    .init(x: 16, y: 16),
                ])
            }
            .size(width: 14, height: 14)
            .fill(Color.black)
            .rotationEffect(.degrees(rotation))
            .animation(animation)
            .onAppear {
                self.rotation = 360
            }
        }
        
        func body(content: Content) -> some View {
            Group {
                if enabled {
                    content.mask(mask)
                } else {
                    content
                }
            }
        }
    }
    
    enum Colors {
        static let `default` = Color(red: 0.8039215686, green: 0.8, blue: 0.8)
        static let scheduled = Color(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333)
        static let running = Color(red: 0.9921568627, green: 0.7294117647, blue: 0.07058823529)
        static let passed = Color(red: 0.5647058824, green: 0.7803921569, blue: 0.2431372549)
        static let failed = Color(red: 0.9725490196, green: 0.2470588235, blue: 0.137254902)
        static let notRun = Color(red: 0.5137254902, green: 0.6901960784, blue: 0.8941176471)
        
        static func color(for string: String) -> Color {
            switch string.lowercased() {
            case "skipped", "not_run":
                return notRun
            case "scheduled":
                return scheduled
            case "running":
                return running
            case "passed", "blocked":
                return passed
            case "soft_failed", "failed", "canceling", "canceled":
                return failed
            default:
                return `default`
            }
        }
    }
}

struct BuildState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                BuildState(state: "skipped")
                BuildState(state: "not_run")
            }
            BuildState(state: "scheduled")
            BuildState(state: "running")
            HStack {
                BuildState(state: "passed")
                BuildState(state: "blocked")
            }
            HStack {
                BuildState(state: "soft_failed")
                BuildState(state: "failed")
                BuildState(state: "canceling")
                BuildState(state: "canceled")
            }
            BuildState(state: "anything else")
        }
    }
}
