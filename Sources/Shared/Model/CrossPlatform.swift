//
//  CrossPlatform.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/5/20.
//

import SwiftUI

#if canImport(AppKit)
import AppKit

public typealias CrossPlatformFont = NSFont
public typealias CrossPlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit

public typealias CrossPlatformFont = UIFont
public typealias CrossPlatformImage = UIImage
#endif

extension Image {
    init(crossPlatformImage: CrossPlatformImage) {
        #if os(macOS)
        self.init(nsImage: crossPlatformImage)
        #else
        self.init(uiImage: crossPlatformImage)
        #endif
    }
}
