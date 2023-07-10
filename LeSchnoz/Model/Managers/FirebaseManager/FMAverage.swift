//
//  FMAverage.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/28/23.
//

import Foundation

extension FirebaseManager {
    
    //MARK: - Average Rating
    
    func getAverageRatingForLocation(_ placeID: String, withCompletion completion: @escaping (AverageRating?) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("AverageRatings")
            .whereField("id", isEqualTo: placeID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                } else if let snapshot = snapshot {
                                        
                    guard let doc = snapshot.documents.first else { return completion(nil) }
                        let avgRating = AverageRating(dictionary: doc.data())
                        completion(avgRating)
                }
            }
    }
    
    func getAllAverageRatings(withCompletion completion: @escaping ([AverageRating]?) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("AverageRatings")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                } else if let snapshot = snapshot {
                    
                    var averages: [AverageRating] = []
                    for doc in snapshot.documents {
                        
                        let dict = doc.data()
                        
                        let average = AverageRating(dictionary: dict)
                        averages.append(average)
                    }
                    completion(averages)
                }
            }
    }
    
    
    func addAverageRating(_ averageRating: AverageRating, withcCompletion completion: @escaping (K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
                
        let data: [String:Any] = [ "id" : averageRating.id,
                       "avgRating" : averageRating.avgRating,
                       "totalStarCount" : averageRating.totalStarCount,
                       "numberOfReviews" : averageRating.numberOfReviews
        ]
        
        db.collection("AverageRatings").document(averageRating.id).setData(data, merge: true) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(.savingReview)
            } else {
                completion(nil)
            }
        }
    }
    
    func removeAverageRating(_ averageRating: AverageRating, withcCompletion completion: @escaping (K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        db.collection("AverageRatings").document(averageRating.id).delete { error in
            if let error = error {
                print(error.localizedDescription)
                completion(.savingReview)
            } else {
                completion(nil)
            }
        }
    }

}
