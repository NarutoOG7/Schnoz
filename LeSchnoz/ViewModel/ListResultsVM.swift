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
    
    func refreshData(review: ReviewModel, averageRating: AverageRating?, placeID: String, isRemoving: Bool, isAddingNew: Bool) {
        updateReviewBuckets(&userStore.reviews)
        updateReviewInPlaces(&nearbyPlaces)
        updateReviewInPlaces(&schnozPlaces)
        updateReviewInPlaces(&breakfastPlaces)
        updateReviewInPlaces(&lunchPlaces)
        updateReviewInPlaces(&dinnerPlaces)

        
        func updateReviewInPlaces(_ places: inout [SchnozPlace]) {

            if let index = places.firstIndex(where: { $0.placeID == placeID }) {
                if isAddingNew {
                    // Adding new review to all buckets where place exists
                    if !places[index].schnozReviews.contains(review) {
                        places[index].schnozReviews.append(review)
                    }
                    places[index].averageRating = averageRating
                } else
                if let oldReviewIndex = places[index].schnozReviews.firstIndex(where: { $0.id == review.id }) {
                    if isRemoving {
                        // Removing review from all buckets
                        places[index].schnozReviews.remove(at: oldReviewIndex)
                    } else {
                        // Updating old review in all buckets
                        places[index].schnozReviews[oldReviewIndex] = review
                    }
                    places[index].averageRating = averageRating
                }
            }
        }
        
        func updateReviewBuckets(_ reviews: inout [ReviewModel]) {
            if isAddingNew {
                reviews.append(review)
            } else
            if let oldReviewIndex = reviews.firstIndex(where: { $0.id == review.id }) {
                if isRemoving {
                    reviews.remove(at: oldReviewIndex)
                } else {
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
}
