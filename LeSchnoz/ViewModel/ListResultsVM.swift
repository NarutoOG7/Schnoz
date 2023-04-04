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
    
    @Published var schnozPlaces: [SchnozPlace] = []
    @Published var breakfastPlaces: [SchnozPlace] = []
    @Published var lunchPlaces: [SchnozPlace] = []
    @Published var dinnerPlaces: [SchnozPlace] = []
    @Published var nearbyPlaces: [SchnozPlace] = []
    

    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var userLocManager = UserLocationManager.instance

    //MARK: - Refresh Data in Places Buckets
    
    func refreshData(_ review: ReviewModel, placeID: String, isRemoving: Bool, isAddingNew: Bool) {
        updateReviewInArray(&nearbyPlaces)
        updateReviewInArray(&schnozPlaces)
        updateReviewInArray(&breakfastPlaces)
        updateReviewInArray(&lunchPlaces)
        updateReviewInArray(&dinnerPlaces)

        
        func updateReviewInArray(_ array: inout [SchnozPlace]) {
            if let index = array.firstIndex(where: { $0.placeID == placeID }) {
                if isAddingNew {
                    // Adding new review to all buckets where place exists
                    array[index].schnozReviews.append(review)
                } else
                if let oldReviewIndex = array[index].schnozReviews.firstIndex(where: { $0.id == review.id }) {
                    if isRemoving {
                        // Removing review from all buckets
                        array[index].schnozReviews.remove(at: oldReviewIndex)
                    } else {
                        // Updating old review in all buckets
                        array[index].schnozReviews[oldReviewIndex] = review
                    }
                                    self.objectWillChange.send()

                }
            }
        }
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
