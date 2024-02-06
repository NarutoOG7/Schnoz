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
//    let api_Key = "AIzaSyAGCA2wJquQ5rECUYoMQWRBNHLD0T-3zgE"
    let api_Key = "AIzaSyC_KQ2JYEuka7IVvakx4DgjSNvtu0yG4qw"
    
    @Published var searchTypeLocations: [SchnozPlace] = []
    
    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    func getFullURL(_ searchType: SearchType, withCompletion completion: @escaping(URL?, Error?) -> Void) {
        if let currentLoc = UserStore.instance.currentLocation?.coordinate {
            let keyword = "keyword=\(searchType.rawValue)"
            let location = "&location=\(currentLoc.asStringForURL())"
            let radius = "&radius=2500"
            let type = "&type=restaraunt"
            let apiKey = "&key=\(api_Key)"
            let stringURL = (baseURL?.absoluteString ?? "") + keyword + location + radius + type + apiKey
            if let fullURL = URL(string: stringURL) {
                //            let fullURL = baseURL?.appendingPathExtension(keyword+location+radius+type+apiKey)
                //            let fullURL = baseURL?.absoluteURL
                //                .appending(queryItems: [URLQueryItem(name: "keyword", value: searchType.rawValue),
                //                                                          URLQueryItem(name: "location", value: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
                //                                                         URLQueryItem(name: "radius", value: "1500"),
                //                                                         URLQueryItem(name: "type", value: "restaraunt"),
                //                                                         URLQueryItem(name: "key", value: api_Key)])
                completion(fullURL, nil)
            }
        } else if ListResultsVM.instance.searchRegion != "" {
            FirebaseManager.instance.getCoordinatesFromAddress(address: ListResultsVM.instance.searchRegion) { cloc in
                let fullURL = self.baseURL?.appending(queryItems: [URLQueryItem(name: "keyword", value: searchType.rawValue),
                                                                   URLQueryItem(name: "location", value: cloc.coordinate.asStringForURL()),
                                                                   URLQueryItem(name: "radius", value: "1500"),
                                                                   URLQueryItem(name: "type", value: "restaraunt"),
                                                                   URLQueryItem(name: "key", value: self.api_Key)])
                completion(fullURL, nil)
            }
        } else {
            print("no go")
        }

    }
    
    func getNearbyLocationsBySearchType(_ searchType: SearchType) {
        self.listResultsVM.schnozPlaces = []
        getFullURL(searchType) { url, error in
            if let error = error {
                // TODO: HAndle Error
                print(error.localizedDescription)
            }
            if let url = url {
                print(url)
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        // TODO: Handle Error
                        print(error.localizedDescription)
                    }
                    if let data = data {
                        if let places = self.parseJSONTres(data) {
                            for place in places {
                                let schnozPlace = self.schnozModelToPlace(place)
                                self.listResultsVM.schnozPlaces.append(schnozPlace)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func process(_ items: [SchnozModel]) {
        listResultsVM.schnozPlaces = []
        for item in items {
            let schnozPlace = schnozModelToPlace(item)
            listResultsVM.schnozPlaces.append(schnozPlace)
        }
    }
    
    func schnozModelToPlace(_ schnozModel: SchnozModel) -> SchnozPlace {
        let schnozPlace = SchnozPlace(placeID: schnozModel.placeID ?? "")
        schnozPlace.primaryText = schnozModel.name
//        schnozPlace.secondaryText = schnozModel.formattedAddress
        
        return schnozPlace
    }

    func parseJSONTres(_ data: Data) -> [SchnozModel]? {
               do {
                   let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                   if let places = result?["results"] as? [[String: Any]] {
                       
                       var schnozModels = [SchnozModel]()
                       // Loop through each place and extract the information you need
                       for place in places {
                           let name = place["name"] as? String ?? ""
                           let placeID = place["place_id"] as? String ?? ""
                           // Address
                           let addressComp = place["address_components"] as? [String:Any] ?? [:]
                           let addressLong = addressComp["long_name"] as? String ?? ""
                           let addressShort = addressComp["short_name"] as? String ?? ""
                           let addressTypes = addressComp["types"] as? [String] ?? []
                           let adrComp = AddressComponents(longName: addressLong, shortName: addressShort, types: addressTypes)

                           // Serves ...
                           let servesBfast = place["serves_breakfast"] as? Bool ?? false
                           let servesLunch = place["serves_lunch"] as? Bool ?? false
                           let servesDinner = place["serves_dinner"] as? Bool ?? false

                           
                           print(adrComp.shortName)
                           // Add the place information to an array or other data structure
                           let newPlace = SchnozModel(addressComponents: adrComp, name: name, placeID: placeID, servesBreakfast: servesBfast, servesLunch: servesLunch, servesDinner: servesDinner)
                           schnozModels.append(newPlace)
                       }
                       return schnozModels
                   }
               } catch let error {
                   print("Error parsing JSON: \(error)")
               }
        return nil
    }
}

extension CLLocationCoordinate2D {
    func asStringForURL() -> String {
        let lat = self.latitude.formatted()
        let lon = self.longitude.formatted()
        let comma = ","
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.-_~")
        let encodedComma = comma.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "nil"
        print(encodedComma)
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
    
    var addressComponents: AddressComponents
    var name: String
    var placeID: String
    var servesBreakfast: Bool
    var servesLunch: Bool
    var servesDinner: Bool

    
    private enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case name
        case placeID = "place_id"
        case servesBreakfast = "serves_breakfast"
        case servesLunch = "serves_lunch"
        case servesDinner = "serves_dinner"

    }
}

//struct Places: Codable {
//    let items: [SchnozModel]
//}

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
