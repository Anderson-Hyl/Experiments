import SwiftUI
import TipKit

// Define your tip's content.
struct FavoriteLandmarkTip: Tip {
    var title: Text {
        Text("Save as a Favorite")
    }
    
    var message: Text? {
        Text("Your favorite landmarks always appear at the top of the list.")
    }
    
    var image: Image? {
        Image(systemName: "star")
    }
}

struct LandmarkTipsView: View {
    // Create an instance of your tip.
    var favoriteLandmarkTip = FavoriteLandmarkTip()
    var body: some View {
        VStack {
            // Place the tip view near the feature you want to highlight.
            TipView(favoriteLandmarkTip, arrowEdge: .bottom)


            Image(systemName: "star")
                .imageScale(.large)
            Spacer()
        }
        .padding()
        .task {
            // Configure and load your tips at app launch.
            do {
                try Tips.resetDatastore()
                try Tips.configure()
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }
}
