import ComposableArchitecture
import LocationManagerFeature
import SwiftUI

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

      VStack(alignment: .center) {
        Spacer()

        HStack(spacing: 16) {
          ForEach(PointOfInterestCategory.allCases) { category in
            Button(category.displayName) {
              store.send(.view(.categoryButtonTapped(category)))
            }
            .buttonStyle(.plain)
            .padding(12)
            .background(
              category == store.pointOfInterestCategory ? Color.blue : Color.secondary
            )
            .foregroundColor(.white)
            .cornerRadius(8)
          }

          Spacer()

          Button {
            store.send(.view(.currentLocationButtonTapped))
          } label: {
            Image(systemName: "location")
              .font(.body)
              .foregroundColor(.white)
              .frame(width: 44, height: 44)
              .background(Color.secondary)
              .clipShape(Circle())
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
      }
    }
    .alert($store.scope(\.alert, action: \.alert))
    .task {
      await store.send(.view(.runLocationManager)).finish()
    }
  }
}

#if DEBUG
  struct LocationManagerView_Previews: PreviewProvider {
    static var previews: some View {
      LocationManagerView(
        store: Store(
          initialState: AppFeature.State()
        ) {
          AppFeature()
        }
      )
    }
  }
#endif
