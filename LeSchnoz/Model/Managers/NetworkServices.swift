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
    
    private var keys: NSDictionary?
    
    init() {
        if let path = Bundle.main.path(forResource: K.GhostKeys.file, ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            
            if let placesAPI = dict["placesAPIKey"] as? String {
                self.apiKey = placesAPI
            }
        }
    }
    
//https://maps.googleapis.com/maps/api/place/queryautocomplete/json
//  ?input=pizza%20near%20par
//  &key=AIzaSyCaqdMVqLmooHNH4Fpc53t3eEh-2YNPVHA
//    
//https://maps.googleapis.com/maps/api/place/qeuryautocomplete/json?input=Sim&key=AIzaSyCaqdMVqLmooHNH4Fpc53t3eEh-2YNPVHA
//
//https://maps.googleapis.com/maps/api/place/autocomplete/json?input=fort%collins&location=37.76999%2C-122.44696&radius=500&types=food&key=AIzaSyCaqdMVqLmooHNH4Fpc53t3eEh-2YNPVHA
//    
//https://maps.googleapis.com/maps/api/place/textsearch/json?query=sim%city%20in%20Westbrook&key=AIzaSyCaqdMVqLmooHNH4Fpc53t3eEh-2YNPVHA
//    
    func getFullURL(_ keyword: String, withCompletion completion: @escaping(URL?, Error?) -> Void) {
        print(listResultsVM.searchRegion)
        if let currentLoc = UserStore.instance.currentLocation?.coordinate {
            let keyword = "keyword=\(keyword)"
            let location = "&location=\(currentLoc.asStringForURL())"
            let radius = "&radius=2500"
            let api = "&key=\(apiKey)"
            let type = "&type=food"
            let stringURL = (baseURL?.absoluteString ?? "") + keyword + location + radius + type + api
            print(stringURL)
            if let fullURL = URL(string: stringURL) {
                print(fullURL.absoluteString)
                completion(fullURL, nil)
            }
        } else if ListResultsVM.instance.searchRegion != "" {
            FirebaseManager.instance.getCoordinatesFromAddress(address: ListResultsVM.instance.searchRegion) { cloc in
                let fullURL = self.baseURL?.appending(queryItems: [URLQueryItem(name: "keyword", value: keyword),
                                                                   URLQueryItem(name: "location", value: cloc.coordinate.asStringForURL()),
                                                                   URLQueryItem(name: "radius", value: "1500"),
                                                                   URLQueryItem(name: "type", value: "food"),
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
                print(url)
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
//                        GooglePlacesManager.instance.getPlaceFromID(placeID) { gmsPlace, error in
//                            if let error = error {
//                                completion(nil, error)
//                            }
//                            if let gmsPlace = gmsPlace {
//                                schnozPlace.gmsPlace = gmsPlace
//                            }
//                            group.leave()
//                        }
                    
                    GooglePlacesManager.instance.getPlaceDetails(placeID) { gmsPlace, error in
                        if let error = error {
                            print(error.localizedDescription)
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
            GooglePlacesManager.instance.getPlaceDetails(placeID) { gmsPlace, error in
                if let error = error {
                    print(error.localizedDescription)
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


