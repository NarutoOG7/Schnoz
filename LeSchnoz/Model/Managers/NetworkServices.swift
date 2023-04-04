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
    @Published var apiKey = "AIzaSyC_KQ2JYEuka7IVvakx4DgjSNvtu0yG4qw"
    
    @Published var searchTypeLocations: [SchnozPlace] = []
    
    @ObservedObject var listResultsVM = ListResultsVM.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func getFullURL(_ keyword: String, withCompletion completion: @escaping(URL?, Error?) -> Void) {
        if let currentLoc = UserStore.instance.currentLocation?.coordinate {
            let keyword = "keyword=\(keyword)"
            let location = "&location=\(currentLoc.asStringForURL())"
            let radius = "&radius=2500"
            let rankby = "&rankby=distance"
            let type = "&type=restaraunt"
            let apiKey = "&key=\(apiKey)"
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
                    FirebaseManager.instance.getReviewsForLocation(placeID) { reviews in
                        schnozPlace.schnozReviews = reviews
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

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

struct SchnozModel: Codable {
    
//    var addressComponents: AddressComponents
    var formattedAddress: String
    var name: String
    var placeID: String
    
    private enum CodingKeys: String, CodingKey {
//        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case name
        case placeID = "place_id"
    }
}



struct NearbyResponse: Codable {
    
    var htmlAttributions: [String]
    var results: [SchnozModel]
    var status: String
//    var errorMessage: String?
    
    private enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case results
        case status
//        case errorMessage = "error_message"
    }
}

//    "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=breakfast&location=40.54111%2C-105.09218&radius=1500&type=restaurant&key=AIzaSyAGCA2wJquQ5rECUYoMQWRBNHLD0T-3zgE"
    
//https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=breakfast&location=40.5853%2C-105.0844%20&radius=1500&type=restaraunt&key=AIzaSyC_KQ2JYEuka7IVvakx4DgjSNvtu0yG4qw

struct AddressComponents: Codable {
    
    var longName: String
    var shortName: String
    var types: [String]
    
    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}
