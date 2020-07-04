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
    private var font = CrossPlatformFont.preferredFont(forTextStyle: .body)
    
    init<S: StringProtocol>(_ text: S) {
        self.text = String(text)
    }
    
    var body: some View {
        Representable(attributed: emojified(text),
                      font: font)
    }
    
    func emojified(_ text: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString()
        let components = text.split(separator: " ")
        for (index, str) in components.enumerated() {
            if str.hasPrefix(":") && str.hasSuffix(":") {
                let name = str.dropFirst().dropLast().trimmingCharacters(in: .whitespaces)
                
                switch emojis.emoji(for: name) {
                case .none:
                    fullString.append(NSAttributedString(string: String(str)))
                case .loading:
                    break
                case let .image(image):
                    let aspectRatio = image.size.width / image.size.height
                    let newHeight = font.lineHeight
                    let icon = NSTextAttachment()
                    icon.image = image
                    icon.bounds = CGRect(x: 0,
                                         y: font.capHeight - newHeight / 2,
                                         width: aspectRatio * newHeight,
                                         height: newHeight)
                    fullString.append(NSAttributedString(attachment: icon))
                }
            } else {
                fullString.append(NSAttributedString(string: String(str)))
            }
            
            if index != components.endIndex {
                fullString.append(NSAttributedString(string: " "))
            }
        }
        return fullString
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

private typealias CrossPlatformFont = UIFont

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

private typealias CrossPlatformFont = NSFont

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
                .environmentObject(Emojis(cache: ImageMemoryCache()))
        }
    }
}
