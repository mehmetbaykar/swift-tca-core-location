import ComposableArchitecture
import LocationManagerFeature
import SwiftUI

private let readMe = """
  This application demonstrates how to work with CLLocationManager for getting the user's current \
  location, and MKLocalSearch for searching points of interest on the map.

  Zoom into any part of the map and tap a category to search for points of interest nearby. The \
  markers are also updated live if you drag the map around.
  """

struct LocationManagerView: View {
  @Environment(\.colorScheme) var colorScheme
  @Perception.Bindable var store: StoreOf<AppFeature>

  var body: some View {
    ZStack {
      MapView(
        pointsOfInterest: store.pointsOfInterest,
        region: Binding(
          get: { store.region },
          set: { store.send(.view(.regionChanged($0))) }
        )
      )
      .ignoresSafeArea()

      VStack(alignment: .trailing) {
        Spacer()

        Button {
          store.send(.view(.currentLocationButtonTapped))
        } label: {
          Image(systemName: "location")
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(Color.secondary)
            .clipShape(Circle())
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(PointOfInterestCategory.allCases) { category in
              Button(category.displayName) {
                store.send(.view(.categoryButtonTapped(category)))
              }
              .padding(16)
              .background(
                category == store.pointOfInterestCategory ? Color.blue : Color.secondary
              )
              .foregroundColor(.white)
              .cornerRadius(8)
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 32)
        }
      }
    }
    .alert($store.scope(\.alert, action: \.alert))
    .task {
      await store.send(.view(.runLocationManager)).finish()
    }
  }
}

struct ContentView: View {
  var body: some View {
    NavigationView {
      Form {
        Section(
          header: Text(readMe)
            .font(.body)
            .padding([.bottom])
        ) {
          NavigationLink(
            "Go to demo",
            destination: LocationManagerView(
              store: Store(
                initialState: AppFeature.State()
              ) {
                AppFeature()
              }
            )
          )
        }
      }
      .navigationBarTitle("Location Manager")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

#if DEBUG
  struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
  }
#endif
