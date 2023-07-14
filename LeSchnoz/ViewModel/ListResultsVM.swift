//
//  ListResultsVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import SwiftUI


class ListResultsVM: ObservableObject {
    static let instance = ListResultsVM()
    
    @Published var selectedPlace: SchnozPlace?
    @Published var searchRegion = ""
    @Published var searchType: SearchType?
    @Published var isLoading = false
    @Published var shouldShowPlaceDetails = false
    @Published var showSearchTableView = false
    @Published var latestReview: ReviewModel?
    @Published var currentLocationChanged = false
    @Published var loadMoreButtonIsVisible = false
    
    @Published var schnozPlaces: [SchnozPlace] = []
    @Published var breakfastPlaces: [SchnozPlace] = []
    @Published var lunchPlaces: [SchnozPlace] = []
    @Published var dinnerPlaces: [SchnozPlace] = []
    @Published var nearbyPlaces: [SchnozPlace] = []
    
    @Published var searchBarTapped = false
    
    @Published var placeImage: Image = K.Images.placeholder

    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance

    //MARK: - Refresh Data in Places Buckets
    
    func refreshData(review: ReviewModel, averageRating: AverageRating?, placeID: String, refreshType: RefreshType) {
        updateReviewBuckets(&userStore.reviews)
        updateReviewInPlaces(&nearbyPlaces)
        updateReviewInPlaces(&schnozPlaces)
        updateReviewInPlaces(&breakfastPlaces)
        updateReviewInPlaces(&lunchPlaces)
        updateReviewInPlaces(&dinnerPlaces)
        
      
        func updateReviewInPlaces(_ places: inout [SchnozPlace]) {
            if let index = places.firstIndex(where: { $0.placeID == placeID }) {
                places[index].averageRating = averageRating

                switch refreshType {
                case .add:
                    if !places[index].schnozReviews.contains(review) {
                        places[index].schnozReviews.append(review)
                    }
                case .remove:
                    if let oldReviewIndex = places[index].schnozReviews.firstIndex(where: { $0.id == review.id }) {
                        places[index].schnozReviews.remove(at: oldReviewIndex)
                    }
                case .update:
                    if let oldReviewIndex = places[index].schnozReviews.firstIndex(where: { $0.id == review.id }) {
                        places[index].schnozReviews[oldReviewIndex] = review
                    }
                }
            }
        }
    
        
        func updateReviewBuckets(_ reviews: inout [ReviewModel]) {
            switch refreshType {
            case .add:
                reviews.append(review)
            case .remove:
                if let oldReviewIndex = reviews.firstIndex(where: { $0.id == review.id }) {
                    reviews.remove(at: oldReviewIndex)
                }
            case .update:
                if let oldReviewIndex = reviews.firstIndex(where: { $0.id == review.id }) {
                    reviews[oldReviewIndex] = review
                }
            }
        }
        
    }
    
    func getPlaceImage(_ place: SchnozPlace, withCompletion completion: @escaping(Image?, Error?) -> Void) {
        GooglePlacesManager.instance.getPhotoForPlaceID(place.placeID) { uiImage, error in
            if let error = error {
                completion(nil, error)
//                self.errorManager.message = error.localizedDescription
//                self.errorManager.shouldDisplay = true
            }
                if let uiImage = uiImage {
                    completion(Image(uiImage: uiImage), nil)
//                    self.placeImage = Image(uiImage: uiImage)
                }

        }
    }
    
    func resetPlaceImage() {
        self.placeImage =  K.Images.placeholder
    }
    
    func locServiceIsEnabled() -> Bool {
        userLocManager.locationServicesEnabled
    }
    
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
    
    enum RefreshType {
        case add, remove, update
    }
}
