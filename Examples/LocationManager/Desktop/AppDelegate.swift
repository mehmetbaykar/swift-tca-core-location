import ComposableArchitecture
import LocationManagerFeature
import SwiftUI

@main
struct LocationManagerDesktopApp: App {
  var body: some Scene {
    WindowGroup {
      LocationManagerView(
        store: Store(
          initialState: AppFeature.State()
        ) {
          AppFeature()
        }
      )
    }
  }
}
