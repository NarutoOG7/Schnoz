//
//  TripAdvisorManger.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 9/19/23.
//

import Foundation

struct TAMatchInfo {
    let id: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "location_id"
    }
}

struct TALocationDetails {
    
    let id: String
    let url: String
    let rating: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "location_id"
        case url = "web_url"
        case rating
    }

    init(dict: NSDictionary) {
        
        let id = dict.value(forKey: "location_id") as? String ?? ""
        let url = dict.value(forKey: "web_url") as? String ?? ""
        let rating = dict.value(forKey: "rating") as? String ?? ""
        
        self.id = id
        self.url = url
        self.rating = rating
    }
}

class TripAdvisorManger {
    static let instance = TripAdvisorManger()
    
    let headers = ["accept": "application/json"]
    
    private var apiKey = ""
    private var keys: NSDictionary?
    
    init() {
        if let path = Bundle.main.path(forResource: K.GhostKeys.file, ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            
            if let taKey = dict["tripAdvisorsKey"] as? String {
                self.apiKey = taKey
            }
        }
    }
    
    func getTAFromSchnozPlace(_ schnozPlace: SchnozPlace, withCompletion completion: @escaping(TALocationDetails?, Error?) -> Void) {
        var taModel: TALocationDetails?
        let group = DispatchGroup()
        group.enter()
        
        matchLocation(schnozPlace: schnozPlace) { match, error in
            if let error = error {
                completion(nil, error)
                group.leave()
            }
            if let match = match {
                group.enter()
                self.locationDetails(match) { details, error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil, error)
                    }
                    if let details = details {
                        taModel = details
                    }
                    group.leave()
                }
            }
            group.leave()
        }
        group.notify(queue: .main) {
            completion(taModel, nil)
        }
    }
    
    private func locationDetails(_ match: TAMatchInfo, withCompletion completion: @escaping(TALocationDetails?, Error?) -> Void) {
                
        let locale = Locale()
        let language = locale.language.languageCode?.identifier ?? ""
        let currency = locale.currency?.identifier ?? ""
        
        if let url = NSURL(string: "https://api.content.tripadvisor.com/api/v1/location/\(match.id)/details?key=\(apiKey)&language=\(language)&currency=\(currency)") {
                        
            print(url)
            let request = NSMutableURLRequest(url: url as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    completion(nil, error)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        
                        guard let dict = json as? NSDictionary else {
                            completion(nil, error)
                            return
                        }
                        let details = TALocationDetails(dict: dict)
                        completion(details, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
                   
            })
            
            dataTask.resume()
        }
    }
    
    
    private func matchLocation(schnozPlace: SchnozPlace, withCompletion completion: @escaping(TAMatchInfo?, Error?) -> Void) {
        
        if let url = buildURLFromSchnozPlace(schnozPlace) {
            print(url)
            
            let request = NSMutableURLRequest(url: url,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    completion(nil, error)
                }
                if let data = data {
                    do {
                         let json = try JSONSerialization.jsonObject(with: data)
                            guard let dict = json as? NSDictionary else {
                                completion(nil, error)
                                return
                            }
                            guard let businesses = dict.value(forKey: "data") as? [NSDictionary] else {
                                completion(nil, error)
                                return
                            }
                            for business in businesses {
                                let id = business.value(forKey: "location_id") as? String ?? ""
                                let taMatch = TAMatchInfo(id: id)
                                completion(taMatch, nil)
                            }
                        
                    } catch {
                        completion(nil, error)
                    }
                }
            })
            
            dataTask.resume()
            
        }
    }

    
    private func buildURLFromSchnozPlace(_ schnozPlace: SchnozPlace) -> URL? {
        
        let basic = "https://api.content.tripadvisor.com/api/v1/location/search?"
        
        if var urlComp = URLComponents(string: basic) {
            let queryItems = queryItems(schnozPlace)
            
            urlComp.percentEncodedQueryItems = queryItems
            
            if let url = urlComp.url {
                print(url)
                return url
            }
        }
        return nil
    }
    
    private func queryItems(_ schnozPlace: SchnozPlace) -> [URLQueryItem] {
                
        var queryItems = [URLQueryItem]()
        
        let api = URLQueryItem(name: "key", value: apiKey)
        queryItems.append(api)
        
        let nameEncoded = (schnozPlace.gmsPlace?.name ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let name = URLQueryItem(name: "searchQuery", value: nameEncoded)
        queryItems.append(name)
        
        let adressComponents = schnozPlace.secondaryText?.components(separatedBy: ",")
        let street = adressComponents?.first ?? ""
        let city = schnozPlace.address?.city ?? ""
        let addressEncoded = (street + " " + city).addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let address = URLQueryItem(name: "address", value: addressEncoded)
        queryItems.append(address)
        
        let locale = Locale().language.languageCode?.identifier
        let language = URLQueryItem(name: "language", value: locale)
        queryItems.append(language)
        
        return queryItems
    }
}
