//
//  EmojiLabel.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/4/20.
//

import SwiftUI

struct EmojiLabel: View {
    @EnvironmentObject var emojis: Emojis
    
    var text: String
    var font: CrossPlatformFont = CrossPlatformFont.preferredFont(forTextStyle: .body)
    
    init<S: StringProtocol>(_ text: S) {
        self.text = String(text)
    }
    
    var body: some View {
        Representable(attributed: emojis.formatEmojis(in: text,
                                                      idealHeight: font.lineHeight,
                                                      capHeight: font.capHeight),
                      font: font)
    }
    
    struct Representable {
        var attributedText: NSAttributedString?
        private var font: CrossPlatformFont
        
        fileprivate init(attributed text: NSAttributedString, font: CrossPlatformFont) {
            self.attributedText = text
            self.font = font
        }
    }
}

#if canImport(UIKit)
import UIKit

extension EmojiLabel.Representable: UIViewRepresentable {
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
    }
}
#elseif canImport(AppKit)
import AppKit

extension EmojiLabel.Representable: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSTextField {
        let label = NSTextField(frame: .zero)
        label.font = NSFont.preferredFont(forTextStyle: .body)
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        return label
    }
    
    func updateNSView(_ nsView: NSTextField, context: Self.Context) {
//        nsView.attributedText = attributedText
    }
}
#endif

struct EmojiLabel_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmojiLabel("App Platforms :darwin: :android:")
                .environmentObject(Emojis())
        }
    }
}
