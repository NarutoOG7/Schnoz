//
//  Address.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation
import GooglePlaces

struct Address: Codable, Hashable {
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    
    init(address: String = "", city: String = "", state: String = "", zipCode: String = "", country: String = "") {
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
    
    init(dictionary: [String:Any]) {
        let street = dictionary["addressComp_street"] as? String ?? ""
        let city = dictionary["addressComp_city"] as? String ?? ""
        let state = dictionary["addressComp_state"] as? String ?? ""
        let country = dictionary["addressComp_country"] as? String ?? ""
        let zip = dictionary["addressComp_zip"] as? String ?? ""
        
        self.address = street
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zip
    }
  
//
//    init(addressComponents: [GMSAddressComponent]) {
//            for comp in addressComponents {
//                for type in comp.types {
//                    var streetNumber = ""
//                    switch type {
//
//                    case "street_number":
//                        streetNumber = comp.name
//
//                    case "route":
//                        self.address = streetNumber + " " + comp.name
//
//                    case "locality":
//                        self.city = comp.name
//
//                    case "administrative_area_level_1":
//                        self.state = comp.name
//
//                    case "country":
//                        self.country = comp.name
//
//                    case "postal_code":
//                        self.zipCode = comp.name
//
//                    default:
//                        self.address = ""
//                        self.city = ""
//                        self.state = ""
//                        self.country = ""
//                        self.zipCode = ""
//                    }
//                }
//            }
//        }
    
    
    
    
    init(addressComponents: [GMSAddressComponent]) {
        var updatedAddress = Address()
        
        for comp in addressComponents {
            for type in comp.types {
                let value = comp.name
                
                if type == "street_number" {
                    updatedAddress.address = value
                } else if type == "route" {
                    updatedAddress.address += " " + value
                } else if type == "locality" {
                    updatedAddress.city = value
                } else if type == "administrative_area_level_1" {
                    updatedAddress.state = value
                } else if type == "country" {
                    updatedAddress.country = value
                } else if type == "postal_code" {
                    updatedAddress.zipCode = value
                }
            }
        }
        
        self = updatedAddress 
    }


    
    
    

    
    func streetCity() -> String {
        address + ", " + city
    }
    
    func streetCityState() -> String {
        address + ", " + city + ", " + state
    }
    
    func cityState() -> String {
        city + ", " + state
    }
    
    func fullAddress() -> String {
        address + ", " + city + ", " + state + " " + zipCode + " " + country
    }
    
    func geoCodeAddress() -> String {
        address + ", " + city + ", " + state
    }
    
    
    func abbreviated(_ text: String) -> String {
        let prepositionsAndConjunctions = ["and", "of"]
        guard case let wordList = text.components(separatedBy: " ")
            .filter({ !prepositionsAndConjunctions.contains($0.lowercased()) }),
            wordList.count > 1 else {
            return text }
        
        let last = (wordList.last?.first ?? Character("")).uppercased()
        return wordList.dropLast()
            .reduce("") { $0 + String($1.first ?? Character("")).uppercased() } + last
    }
}

extension String {
    func withOnlyFirstLetterUppercased() -> String {
        guard case let chars = self,
            !chars.isEmpty else { return self }
        return String(chars.first!).uppercased() +
            String(chars.dropFirst()).lowercased()
    }
}

