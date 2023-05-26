//
//  NetworkServices.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/14/23.
//

import SwiftUI
import CoreLocation
import GooglePlaces

class NetworkServices: ObservableObject {
    static let instance = NetworkServices()
    
    let baseURL = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?")
    @Published var apiKey: String = ""
    
    @Published var searchTypeLocations: [SchnozPlace] = []
    
    @ObservedObject var listResultsVM = ListResultsVM.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func getFullURL(_ keyword: String, withCompletion completion: @escaping(URL?, Error?) -> Void) {
        if let currentLoc = UserStore.instance.currentLocation?.coordinate {
            let keyword = "keyword=\(keyword)"
            let location = "&location=\(currentLoc.asStringForURL())"
            let radius = "&radius=2500"
            let type = "&type=restaraunt"
            let apiKey = "&key=AIzaSyCNe9u8z93wHJy2RNT8Ro46LhToyCG1jQE"
            let stringURL = (baseURL?.absoluteString ?? "") + keyword + location + radius + type + apiKey
            if let fullURL = URL(string: stringURL) {
                completion(fullURL, nil)
            }
        } else if ListResultsVM.instance.searchRegion != "" {
            FirebaseManager.instance.getCoordinatesFromAddress(address: ListResultsVM.instance.searchRegion) { cloc in
                let fullURL = self.baseURL?.appending(queryItems: [URLQueryItem(name: "keyword", value: keyword),
                                                                   URLQueryItem(name: "location", value: cloc.coordinate.asStringForURL()),
                                                                   URLQueryItem(name: "radius", value: "1500"),
                                                                   URLQueryItem(name: "type", value: "restaraunt"),
                                                                   URLQueryItem(name: "key", value: self.apiKey)])
                completion(fullURL, nil)
            }
        } else {
            errorManager.shouldDisplay = true
            errorManager.message = "Error connecting to Google"
        }

    }
    
    func getNearbyLocationsWithKeyword(_ keyword: String, withCompletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
        self.listResultsVM.isLoading = true
        self.listResultsVM.schnozPlaces = []
        getFullURL(keyword) { url, error in
            if let error = error {
                completion(nil, error)
            }
            if let url = url {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        completion(nil, error)
                    }
                    if let data = data {
                        self.parseJSONTres(data) { schnozPlaces, error in
                            if let error = error {
                                completion(nil, error)
                            }
                            if let schnozPlaces = schnozPlaces {
                                completion(schnozPlaces, nil)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func parseJSONTres(_ data: Data, withCompletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            if let places = result?["results"] as? [[String: Any]] {
                
                var schnozPlaces = [SchnozPlace]()
                let group = DispatchGroup()
                
                for place in places {
                    let placeID = place["place_id"] as? String ?? ""
                    
                    let schnozPlace = SchnozPlace(placeID: placeID)
                    
                    
                    group.enter()
                        GooglePlacesManager.instance.getPlaceFromID(placeID) { gmsPlace, error in
                            if let error = error {
                                completion(nil, error)
                            }
                            if let gmsPlace = gmsPlace {
                                schnozPlace.gmsPlace = gmsPlace
                            }
                            group.leave()
                        }

                    group.enter()
                    FirebaseManager.instance.getAverageRatingForLocation(placeID) { averageRating in
                        schnozPlace.averageRating = averageRating

//                    FirebaseManager.instance.getReviewsForLocation(placeID) { reviews in
//                        schnozPlace.schnozReviews = reviews
                        group.leave()
                    }
                    
                    schnozPlaces.append(schnozPlace)

                }
                
                group.notify(queue: .main) {
                    completion(schnozPlaces, nil)
                }
            }
        } catch let error {
            completion(nil, error)
        }
    }
    
    func getGMSPlaceAndAvgRatingFromPlaceID(_ placeID: String, withCompletion completion: @escaping(SchnozPlace?, Error?) -> Void) {
        let group = DispatchGroup()
        
        let schnozPlace = SchnozPlace(placeID: placeID)

        group.enter()
            GooglePlacesManager.instance.getPlaceFromID(placeID) { gmsPlace, error in
                if let error = error {
                    completion(nil, error)
                }
                if let gmsPlace = gmsPlace {
                    schnozPlace.gmsPlace = gmsPlace
                }
                group.leave()
            }
        
        group.enter()
        FirebaseManager.instance.getAverageRatingForLocation(placeID) { averageRating in
            schnozPlace.averageRating = averageRating
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(schnozPlace, nil)
        }
    }
}

extension CLLocationCoordinate2D {
    func asStringForURL() -> String {
        let lat = self.latitude.formatted()
        let lon = self.longitude.formatted()
        let comma = ","
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.-_~")
        let encodedComma = comma.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "nil"
        let str = lat + encodedComma + lon
        return str
    }
}


