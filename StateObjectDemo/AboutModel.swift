import SwiftUI

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
