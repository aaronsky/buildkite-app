import APIClient
import AppFeature
import ComposableArchitecture
import SwiftUI

@main struct BuildkiteApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(
                    initialState: .init(),
                    reducer: AppReducer()
                )
            )
        }
    }
}
