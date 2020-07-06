//
//  RemoteImage.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/5/20.
//

import SwiftUI
import Combine

struct RemoteImage: View {
    @ObservedObject var store: Store
    
    init(url: URL, cache: ImageCache? = nil) {
        self.store = Store(url: url, cache: cache)
    }
    
    var body: some View {
        image
            .onAppear(perform: store.load)
            .onDisappear(perform: store.cancel)
    }
    
    private var image: some View {
        Group {
            if let image = store.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Image("AvatarDefault")
                    .resizable()
            }
        }
    }
    
    class Store: ObservableObject {
        @Published var image: CrossPlatformImage?
        var url: URL
        var loader: ImageLoader
        
        init(url: URL, cache: ImageCache? = nil) {
            self.url = url
            self.loader = ImageLoader(cache: cache)
        }
        
        func load() {
            loader.load(url: url) { [weak self] image in
                self?.image = image
            }
        }
        
        func cancel() {
            loader.cancel()
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: URL(string: "https://buildkite.com/_next/static/assets/assets/images/brand/mark-538711bd.svg")!)
    }
}
