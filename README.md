# StateObjectDemo

StackOverflow reference post: https://stackoverflow.com/questions/62635914/initialize-stateobject-with-a-parameter-in-swiftui

Really good answers. Now, I found that in some cases, getting `@StateObject` right can be tricky, like handling network requests needed to retrieve information lazily, as the user navigates the UI..

Here's a pattern I like to use, especially when a screen (or hierarchy of screens) should present data lazily due to its associated retrieval cost.

It goes like this:

- the main screen holds the model(s) for the child screen(s).
- each model keeps track of its display state and whether it has already loaded the info. This helps avoid repeating costly ops, like network calls.
- the child screen relies on the model and checks the display state to show a loading view or present the final information/error.

Here's the screen breakdown:

[![enter image description here][1]][1]

Main screen (ContentView):

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

Supporting datatypes:

    enum ViewDisplayState {
        case loading
        case readyToLoad
        case error
    }
    
    enum MyError: Error, CustomStringConvertible {
        case loadingError
        
        var description: String {
            switch self {
                case .loadingError:
                    return "about info failed to load... don't ask."
            }
        }
    }

About Screen (AboutView):

    import SwiftUI

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

The AboutView model:

    import SwiftUI
    
    final class AboutModel: ObservableObject {
        private(set) var info: String?
        private(set) var error: MyError?
        
        @Published var displayMode: ViewDisplayState = .loading
        
        func loadAboutInfo() {
            /**
            If we have loaded the about info already, we're set.
            */
            
            if displayMode == .readyToLoad {
                return
            }
            
            /**
            Load the info (e.g. network call)
            */
            
            loadAbout() { result in
                /**
                Make sure we assign the 'displayMode' in the main queue
                (otherwise you'll see an Xcode warning about this.)
                */
                
                DispatchQueue.main.async {
                    switch result {
                        case let .success(someAboutInfo):
                            self.info = someAboutInfo
                            self.displayMode = .readyToLoad
                        case let .failure(someError):
                            self.info = nil
                            self.error = someError
                            self.displayMode = .error
                    }
                }
            }
        }
        
        /**
        Dummy function; for illustration purposes. It's just a placeholder function
        that demonstrates what the real app would do.
        */
        
        private func loadAbout(completion: @escaping (Result<String, MyError>) -> Void) {
            /**
            Gather the info somehow and return it.
            Wait a couple secs to make it feel a bit more 'real'...
            */
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if Bool.random() {
                    completion(.success("the info is ready"))
                } else {
                    completion(.failure(MyError.loadingError))
                }
            }
        }
    }


  [1]: https://i.stack.imgur.com/jAmFm.png

In short, I found that for this lazy loading pattern, placing the `@StateObject` in the main screen instead of the child screen avoids potentially unnecessary code re-executions.

In addition, using `ViewDisplayState` allows me to control whether a loading view should be shown or not, solving the common UI flickering issue that occurs when the data is already cached locally making the UI loading view not worth presenting.

Of course, this is not a silver bullet. But depending on your workflow it might be useful.

If you want to see this project in action, feel free to download it to see how it works.

Cheers! 🤙🏻
