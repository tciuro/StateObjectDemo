import SwiftUI

struct ContentView: View {
    @StateObject private var aboutModel = AboutModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: AboutView(aboutModel: aboutModel)) {
                        Text("About...")
                    }
                } footer: {
                    Text("The 'About' info should be loaded once, no matter how many times it's visited.")
                }
                
                Section  {
                    Button {
                        aboutModel.displayMode = .loading
                    } label: {
                        Text("Reset Model")
                    }
                } footer: {
                    Text("Reset the model as if it had never been loaded before.")
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct AboutView: View {
    @ObservedObject var aboutModel: AboutModel
    
    var body: some View {
        Group {
            switch aboutModel.displayMode {
                case .loading:
                    VStack {
                        Text("Loading about info...")
                    }
                case .readyToLoad:
                    Text("About: \(aboutModel.info ?? "<about info should not be nil!>")")
                case .error:
                    Text("Error: \(aboutModel.error?.description ?? "<error hould not be nil!>")")
            }
        }
        .onAppear() {
            aboutModel.loadAboutInfo()
        }
    }
}
