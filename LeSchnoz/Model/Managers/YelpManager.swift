//
//  YelpManager.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 9/17/23.
//

import Foundation


class YelpManager: ObservableObject {
    
    static let instance = YelpManager()
    
    private var apiKey = ""
    private var keys: NSDictionary?
    
    init() {
        if let path = Bundle.main.path(forResource: K.GhostKeys.file, ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            
            if let yelpAPI = dict["yelpKey"] as? String {
                self.apiKey = yelpAPI
            }
        }
    }
 
    
    func getYelpFromSchnozPlace(_ schnozPlace: SchnozPlace, withCompletion completion: @escaping(YelpLocationDetailsModel?, Error?) -> Void) {
        let group = DispatchGroup()
        var yelpModel: YelpLocationDetailsModel?
        group.enter()
        matchLocationToYelp(schnozPlace: schnozPlace) { match, error in
            if let error = error {
                completion(nil, error)
                group.leave()
            }
            if let match =  match {
                group.enter()
                self.getYelpPlaceDetailsFromYelpID(match.id) { yelp, error in
                    if let error = error {
                        completion(nil, error)
                    }
                    if let yelp = yelp {
                        yelpModel = yelp
                    }
                    group.leave()
                }
            } 
                group.leave()
            
        }
            
            
            group.notify(queue: .main) {
                completion(yelpModel, nil)
            }
    }
    
    
    private func getYelpPlaceDetailsFromYelpID(_ yelpID: String, withCompletion completion: @escaping(YelpLocationDetailsModel?, Error?) -> Void) {
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        let urlString = "https://api.yelp.com/v3/businesses/\(yelpID)"
        
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(url: url as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        guard let dict = json as? NSDictionary else {
                            completion(nil, error)
                            return
                            
                        }
                            let details = YelpLocationDetailsModel(dict: dict)
                            completion(details, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
                
            })
            dataTask.resume()
        }
    }
    
    private func matchLocationToYelp(schnozPlace: SchnozPlace, withCompletion completion: @escaping(YelpLocationMatch?, Error?) -> Void) {
        
        if let url = buildURLFromSchnozPlace(schnozPlace) {
            
            let headers = [
                "accept": "application/json",
                "Authorization": "Bearer \(apiKey)"
            ]
        
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
                        guard let businesses = dict.value(forKey: "businesses") as? [NSDictionary] else {
                            completion(nil, error)
                            return
                        }
                        for business in businesses {
                            let alias = business.value(forKey: "alias") as? String ?? ""
                            let id = business.value(forKey: "id") as? String ?? ""
                            
                            let match = YelpLocationMatch(id: id, alias: alias)
                            completion(match, nil)
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
        let basic = "https://api.yelp.com/v3/businesses/matches"
        if var urlComp = URLComponents(string: basic) {
            let queryItems = queryItemsFromSchnoz(schnozPlace)
            
            urlComp.percentEncodedQueryItems = queryItems
            if let url = urlComp.url {
                print(url)
                return url
            }
        }
        return nil
    }
    
    private func queryItemsFromSchnoz(_ schnozPlace: SchnozPlace) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        let nameEncoded = (schnozPlace.gmsPlace?.name ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let name = URLQueryItem(name: "name", value: nameEncoded)
        queryItems.append(name)
        
        let newAddressComponents = schnozPlace.secondaryText?.components(separatedBy: ",")
        let street = newAddressComponents?.first ?? ""
        let addrEncoded = (street).addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let address = URLQueryItem(name: "address1", value: addrEncoded)
        queryItems.append(address)
        
        let cityEncoded = (schnozPlace.address?.city ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let city = URLQueryItem(name: "city", value: cityEncoded)
        queryItems.append(city)
        
        let newStateComp = newAddressComponents?[2].components(separatedBy: " ")
        let newState = newStateComp?[1] ?? ""
        let stateEncoded = (newState).addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let state = URLQueryItem(name: "state", value: stateEncoded)
        queryItems.append(state)
        
        let countryCode = locale(for: (schnozPlace.address?.country ?? ""))
        let countryEncoded = countryCode.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let country = URLQueryItem(name: "country", value: locale(for: schnozPlace.address?.country ?? ""))
        queryItems.append(country)
        
        let limit = URLQueryItem(name: "limit", value: "1")
        queryItems.append(limit)
        
        let threshold = URLQueryItem(name: "match_threshold", value: "default")
        queryItems.append(threshold)
        
        return queryItems
    }
    
    private func locale(for fullCountryName : String) -> String {
        var locales : String = ""
        for localeCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale(localeIdentifier: localeCode)
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
            if fullCountryName.lowercased() == countryName?.lowercased() {
                return localeCode
            }
        }
        return locales
    }
}
