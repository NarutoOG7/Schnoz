//
//  ExploreByListVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit
import Contacts

class ExploreViewModel: ObservableObject {
    
    static let instance = ExploreViewModel()
    
    @Published var isShowingMap = false
    @Published var showingLocationList = false
    @Published var showingSearchLocations = false
    
    @Published var searchedLocations: [LocationModel] = []
    @Published var searchRegion = MapDetails.defaultRegion
    @Published var highlightedAnnotation: LocationAnnotationModel?
    
    @Published var displayedLocation: LocationModel? {
        didSet {
            if let displayedLocation = displayedLocation {
                setRegion(location: displayedLocation)
            }
        }
    }
    
    @Published var searchText = "" {
        willSet {
            self.searchedLocations = []
            // TODO: Google Places API
        }
    }

    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func locServiceIsEnabled() -> Bool {
        userLocManager.locationServicesEnabled
    }
    
    func setCurrentLocRegion(_ currentLoc: CLLocation) {
        self.searchRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MapDetails.defaultSpan)
    }
    
    func setRegion(location: LocationModel) {
        
        FirebaseManager.instance.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
            
            let region = MKCoordinateRegion(
                center: cloc.coordinate,
                span: MapDetails.defaultSpan)
            
            withAnimation(.easeInOut) {
                self.searchRegion = region
            }
        }
    }
    
    func setRegion(destination: Destination) {
        
        let center = CLLocationCoordinate2D(latitude: destination.lat,
                                            longitude: destination.lon)
        let region = MKCoordinateRegion(
            center: center,
            span: MapDetails.defaultSpan)
        
        withAnimation(.easeInOut) {
            self.searchRegion = region
        }
    }
    
    //MARK: - Greeting Logic
    
    func greetingLogic() -> String {
        
      let hour = Calendar.current.component(.hour, from: Date())
      
      let morning = 0
      let noon = 12
      let sunset = 18
      let midnight = 24
      
      var greetingText = "Hello"
        
      switch hour {
          
      case morning..<noon:
          greetingText = "Good Morning"
          
      case noon..<sunset:
          greetingText = "Good Afternoon"
          
      case sunset..<midnight:
          greetingText = "Good Evening"

      default:
          _ = "Hello"
      }
      
      return greetingText
    }
    
    //MARK: - Swipe Locations List
    
    enum SwipeDirection {
        case backward, forward
    }
}

struct ImageView<Placeholder>: View where Placeholder: View {

    // MARK: - Value
    // MARK: Private
    @State private var image: Image? = nil
    @State private var task: Task<(), Never>? = nil
    @State private var isProgressing = false

    private let url: URL?
    private let placeholder: () -> Placeholder?


    // MARK: - Initializer
    init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
    }

    init(url: URL?) where Placeholder == Color {
        self.init(url: url, placeholder: { Color("neutral9") })
    }
    
    
    // MARK: - View
    // MARK: Public
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                placholderView
                imageView
                progressView
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .task {
                task?.cancel()
                task = Task.detached(priority: .background) {
                    await MainActor.run { isProgressing = true }
                
                    do {
                        let image = try await ImageManager.shared.download(url: url)
                    
                        await MainActor.run {
                            isProgressing = false
                            self.image = image
                        }
                    
                    } catch {
                        await MainActor.run { isProgressing = false }
                    }
                }
            }
            .onDisappear {
                task?.cancel()
            }
        }
    }
    
    // MARK: Private
    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            image
                .resizable()
                .scaledToFill()
        }
    }

    @ViewBuilder
    private var placholderView: some View {
        if !isProgressing, image == nil {
            placeholder()
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        if isProgressing {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}



import SwiftUI
import Combine
import Photos

final class ImageManager {
    
    // MARK: - Singleton
    static let shared = ImageManager()
    
    
    // MARK: - Value
    // MARK: Private
    private lazy var imageCache = NSCache<NSString, UIImage>()
    private var loadTasks = [PHAsset: PHImageRequestID]()
    
    private let queue = DispatchQueue(label: "ImageDataManagerQueue")
    
    private lazy var imageManager: PHCachingImageManager = {
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        return imageManager
    }()

    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 90
        configuration.timeoutIntervalForRequest     = 90
        configuration.timeoutIntervalForResource    = 90
        return URLSession(configuration: configuration)
    }()
    
    
    // MARK: - Initializer
    private init() {}
    
    
    // MARK: - Function
    // MARK: Public
    func download(url: URL?) async throws -> Image {
        guard let url = url else { throw URLError(.badURL) }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return Image(uiImage: cachedImage)
        }
    
        let data = (try await downloadSession.data(from: url)).0
        
        guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
            queue.async { self.imageCache.setObject(image, forKey: url.absoluteString as NSString) }
    
        return Image(uiImage: image)
    }
}
