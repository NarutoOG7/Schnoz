//
//  NewsFeedVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/22/23.
//

import SwiftUI
import Firebase
import GooglePlaces

class NewsFeedVM: ObservableObject {
    
    static let instance = NewsFeedVM()
    
    @Published var isFetchInProgress = false
    @Published var reviews: [ReviewModel] = []
    
    @Published var errorMessage = ""
    @Published var shouldShowError = false
   
    @Published var lastDocumentOfAllReviewsBatchRequest: DocumentSnapshot?

    
    @Published var sortingOption: ReviewSortingOption = .newest {
        didSet {
            if oldValue != sortingOption {
                self.reviews = []
                self.batchFirstCall()
            } 
        }
    }
    
    @Published var listHasScrolledToBottom = false {
        willSet {
            if newValue == true {
                self.batchSubsequentCall()
            }
        }
    }
    
 
    
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
//    func batchFirstCall() {
////        let group = DispatchGroup()
//        self.reviews = []
//        var newReviews: [ReviewModel] = []
////        group.enter()
//        firebaseManager.batchFirstAllUsersReviews(sortingOption) { reviews, error in
//
//            if let reviews = reviews {
//                for rev in reviews {
////                    group.enter()
//                    GooglePlacesManager.instance.getPlaceDetails(rev.locationID) { place, error in
//                        if let place = place {
//                            var newReview = rev
//                            var address = Address()
//                            if let addressComponents = place.addressComponents {
//                                for comp in addressComponents {
//                                    print(comp.types)
//                                    for type in (comp.types) {
//
//                                        switch(type) {
//
//                                        case "street_number":
//                                            address.address = comp.name
//
//                                        case "route":
//                                            address.address += " " + comp.name
//
//                                        case "locality":
//                                            address.city = comp.name
//
//                                        case "administrative_area_level_1":
//                                            address.state = comp.name
//
//                                        case "country":
//                                            address.country = comp.name
//
//                                        case "postal_code":
//                                            address.zipCode = comp.name
//
//                                        default:
//                                            break
//                                        }

//                                    }
//                                }
//                                //                                let st = place.addressComponents?.first(where: { $0.types == ["street"]})?.name ?? "no st"
//
//                            }
//
//                            let ct = place.addressComponents?[2].name ?? "no ct"
//
//                            newReview.address = address
//                            //                            newReview.address = place.formattedAddress ?? "No address from google place: on NewsFeedVM"
//                            //                            newReview.address = place. ?? "No address from google place: on NewsFeedVM"
//
//                            //                            newReview.address = street + ", " + city + ", " + state
//                            newReviews.append(newReview)
////                            group.enter()
//                            FirebaseManager.instance.updateReviewInFirestore(newReview) { error in
//                                print(error?.rawValue)
//
////                                group.leave()
//
//                            }
//                            self.handleReviewsCompletionWithError(reviews: newReviews)
//
//                        }
////                        group.leave()
//                        }
//                    }
//
//            }
////            group.leave()
//        }
////        group.notify(queue: .main) {
////            self.handleReviewsCompletionWithError(reviews: newReviews)
////        }
//    }
//
    
    func batchFirstCall() {
        self.reviews = []
        firebaseManager.batchFirstAllUsersReviews(sortingOption) { reviews, error in
            self.handleReviewsCompletionWithError(reviews: reviews, error: error)
        }
    }
    
    func batchSubsequentCall() {
        firebaseManager.nextPageAllUsersReviews(sortingOption) { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            
        }
    }

    func handleReviewsCompletionWithError(reviews: [ReviewModel]?, error: Error?) {
        DispatchQueue.main.async {
            if let reviews = reviews {
                for review in reviews {
                    if !self.reviews.contains(review) {
                        self.reviews.append(review)
                    }
                }
            }
            if let error = error {
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.shouldShowError = true
    }
     
}
